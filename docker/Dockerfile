# Dockerfile for AI Workflow Agents
# Base: ghcr.io/nam20485/agents-prebuild:main-latest
# Includes: Claude CLI, UV, Node.js, Git

FROM ghcr.io/nam20485/agents-prebuild:main-latest

# Metadata
LABEL org.opencontainers.image.title="AI New App Template - Dockerized Workflow Agent"
LABEL org.opencontainers.image.description="Containerized AI workflow orchestration with Claude CLI"
LABEL org.opencontainers.image.version="1.0.0"
LABEL org.opencontainers.image.authors="nam20485"

# Set working directory
WORKDIR /workspace

# Copy workspace files
# Note: We copy everything except what's in .dockerignore
COPY --chmod=755 .workflow/prompt.sh /workspace/.workflow/prompt.sh
COPY . /workspace/

# Create necessary config directories
RUN mkdir -p \
    /home/vscode/.config/anthropic \
    /home/vscode/.config/opencode

# Optional: Pre-install OpenCode if it becomes available
# Uncomment when OpenCode installation method is confirmed
# RUN uv tool install opencode || echo "OpenCode installation skipped (not available)"

# Set environment defaults
ENV WORKFLOW_NAME="project-setup-upgraded"
ENV LOG_FORMAT="json"
ENV DEBUG="false"

# Health check (future enhancement - currently commented out)
# HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
#   CMD test -f /tmp/workflow.lock || exit 1

# Set entrypoint to the hardened prompt script
ENTRYPOINT ["/workspace/.workflow/prompt.sh"]

# Default command (can be overridden)
CMD []
