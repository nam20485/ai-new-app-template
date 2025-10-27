#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(git rev-parse --show-toplevel 2>/dev/null || true)
if [[ -z "${ROOT_DIR}" ]]; then
  echo "Unable to determine repository root; are you inside a git repository?" >&2
  exit 2
fi

cd "${ROOT_DIR}"

if ! command -v trufflehog >/dev/null 2>&1; then
  echo "TruffleHog CLI is not installed. Install it with 'pipx install trufflehog' or 'pip install trufflehog'." >&2
  exit 2
fi

CI_MODE=false
STAGED_MODE=false
SINCE_COMMIT=""
BRANCH="HEAD"
JSON_OUTPUT=""
ALLOWLIST_FILE="${ROOT_DIR}/security/trufflehog-allowlist.yml"
ADDITIONAL_ARGS=()

usage() {
  cat <<'USAGE'
Usage: scripts/security/run-trufflehog.sh [options] [-- <extra trufflehog args>]

Options:
  --ci                     Enable CI defaults (sets --since-commit if not supplied).
  --staged                 Scan staged files (filesystem mode) for the pre-commit hook.
  --since-commit <ref>     Starting commit (passed to --since-commit when scanning git).
  --branch <ref>           Branch/commit ref supplied to --branch (default: HEAD).
  --json-output <path>     Write JSON output (ndjson) to the specified file.
  --allowlist <path>       Path to allowlist YAML (default: security/trufflehog-allowlist.yml).
  -h, --help               Display this help and exit.

Any arguments following "--" are passed verbatim to trufflehog.
USAGE
}

while (($#)); do
  case "$1" in
    --ci)
      CI_MODE=true
      ;;
    --staged)
      STAGED_MODE=true
      ;;
    --since-commit)
      shift || { echo "Missing value for --since-commit" >&2; exit 2; }
      SINCE_COMMIT="$1"
      ;;
    --branch)
      shift || { echo "Missing value for --branch" >&2; exit 2; }
      BRANCH="$1"
      ;;
    --json-output)
      shift || { echo "Missing value for --json-output" >&2; exit 2; }
      JSON_OUTPUT="$1"
      ;;
    --allowlist)
      shift || { echo "Missing value for --allowlist" >&2; exit 2; }
      ALLOWLIST_FILE="$1"
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      while (($#)); do
        ADDITIONAL_ARGS+=("$1")
        shift
      done
      break
      ;;
    *)
      ADDITIONAL_ARGS+=("$1")
      ;;
  esac
  shift || break
done

create_allowlist_flags() {
  local allowlist_path="$1"
  local temp_file
  local detectors
  ALLOWLIST_FLAGS=()

  if [[ ! -f "$allowlist_path" ]]; then
    return 0
  fi

    temp_file=$(mktemp)
    detectors=$(python - <<'PY' "$allowlist_path" "$temp_file"
  import sys
  from pathlib import Path

  allowlist_path = Path(sys.argv[1])
  output_path = Path(sys.argv[2])
  if not allowlist_path.exists():
    print()
    print()
    sys.exit(0)

  paths = []
  detectors = []
  current = None

  for raw_line in allowlist_path.read_text().splitlines():
    line = raw_line.strip()
    if not line or line.startswith('#'):
      continue
    if line.startswith('ignored_paths'):
      current = 'paths'
      continue
    if line.startswith('ignored_detectors'):
      current = 'detectors'
      continue
    if line.startswith('- '):
      value = line[2:].strip()
      if current == 'paths':
        paths.append(value)
      elif current == 'detectors':
        detectors.append(value)

  output_path.write_text("\n".join(paths))

  print('yes' if paths else '')
  print(','.join(detectors))
  PY
  )
  local has_paths
  local detector_list
  has_paths=$(echo "$detectors" | sed -n '1p')
  detector_list=$(echo "$detectors" | sed -n '2p')

  if [[ -n "$has_paths" ]]; then
    ALLOWLIST_FLAGS+=("--exclude-paths" "$temp_file")
  else
    rm -f "$temp_file"
    temp_file=""
  fi

  if [[ -n "$detector_list" ]]; then
    ALLOWLIST_FLAGS+=("--exclude-detectors" "$detector_list")
  fi

  if [[ -n "$temp_file" ]]; then
    CLEANUP_FILES+=("$temp_file")
  fi
}

CLEANUP_FILES=()
trap 'for f in "${CLEANUP_FILES[@]}"; do [[ -n "$f" && -f "$f" ]] && rm -f "$f"; done' EXIT

create_allowlist_flags "$ALLOWLIST_FILE"

if $CI_MODE && [[ -z "$SINCE_COMMIT" ]]; then
  if git rev-parse --verify origin/main >/dev/null 2>&1; then
    SINCE_COMMIT="origin/main"
  elif git rev-parse --verify main >/dev/null 2>&1; then
    SINCE_COMMIT="main"
  else
    SINCE_COMMIT=$(git rev-list --max-parents=0 HEAD | tail -n1)
  fi
fi

if $STAGED_MODE; then
  mapfile -t staged_files < <(git diff --cached --name-only --diff-filter=ACMR)
  if [[ ${#staged_files[@]} -eq 0 ]]; then
    echo "No staged files to scan; skipping TruffleHog." >&2
    exit 0
  fi

  mapfile -t scan_targets < <(
    printf '%s\n' "${staged_files[@]}" | python - <<'PY'
import os
import sys

files = sys.stdin.read().strip().splitlines()
for entry in files:
    if entry and os.path.isfile(entry):
        print(os.path.abspath(entry))
PY
  )

  if [[ ${#scan_targets[@]} -eq 0 ]]; then
    echo "Staged files are not regular files; skipping TruffleHog." >&2
    exit 0
  fi

  cmd=(trufflehog filesystem "${scan_targets[@]}" --results=verified,unknown --fail)
else
  cmd=(trufflehog git "file://${ROOT_DIR}" --results=verified,unknown --fail)
  if [[ -n "$SINCE_COMMIT" ]]; then
    cmd+=(--since-commit "$SINCE_COMMIT")
  fi
  if [[ -n "$BRANCH" ]]; then
    cmd+=(--branch "$BRANCH")
  fi
fi

if [[ ${#ALLOWLIST_FLAGS[@]} -gt 0 ]]; then
  cmd+=("${ALLOWLIST_FLAGS[@]}")
fi

if [[ ${#ADDITIONAL_ARGS[@]} -gt 0 ]]; then
  cmd+=("${ADDITIONAL_ARGS[@]}")
fi

if [[ -n "$JSON_OUTPUT" ]]; then
  mkdir -p "$(dirname "$JSON_OUTPUT")"
  cmd+=(--json)
  "${cmd[@]}" | tee "$JSON_OUTPUT"
  exit ${PIPESTATUS[0]}
else
  "${cmd[@]}"
fi
