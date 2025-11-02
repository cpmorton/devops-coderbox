# devops-coderbox - A batteries-included development environment for DevOps engineers
# Built on Ubuntu 24.04 with code-server, Go, and essential DevOps tools
FROM ubuntu:24.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Set up locale to avoid warnings
RUN apt-get update && apt-get install -y locales && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Install base system utilities and dependencies
# We install everything in logical groups to make it clear what each set of packages does
RUN apt-get update && apt-get install -y \
    # Essential build tools
    build-essential \
    # Version control
    git \
    # Network tools for debugging and API calls
    curl \
    wget \
    # Text processing utilities
    jq \
    # Archive handling
    unzip \
    # SSL certificates for HTTPS
    ca-certificates \
    # Modern editor (vim with more features)
    vim \
    # Shell utilities
    zsh \
    # Process management
    htop \
    # For code-server
    nodejs \
    npm \
    # Python (useful for quick scripts)
    python3 \
    python3-pip \
    # Clean up apt cache to keep image size down
    && rm -rf /var/lib/apt/lists/*

# Install Go - we use the official binary rather than apt to get the latest version
# This gives us better control over the Go version and ensures consistency
ENV GO_VERSION=1.23.2
RUN wget -q https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz && \
    rm go${GO_VERSION}.linux-amd64.tar.gz

# Set up Go environment variables
# GOPATH is where Go stores downloaded packages and compiled binaries
# We add both the system Go bin and the user's GOPATH bin to PATH
ENV PATH="/usr/local/go/bin:${PATH}"
ENV GOPATH="/home/coder/go"
ENV PATH="${GOPATH}/bin:${PATH}"

# Install code-server - this is VS Code running in a browser
# We install it globally so all users can access it
ENV CODE_SERVER_VERSION=4.96.2
RUN curl -fsSL https://code-server.dev/install.sh | sh -s -- --version=${CODE_SERVER_VERSION}

# Install GitHub CLI - essential for working with GitHub from the terminal
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | \
    dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && \
    chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | \
    tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
    apt-get update && \
    apt-get install -y gh && \
    rm -rf /var/lib/apt/lists/*

# Install kubectl - Kubernetes command line tool
# Even if students aren't using k8s yet, it's good to have it ready
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
    rm kubectl

# Install Claude CLI - Anthropic's official CLI for interacting with Claude
RUN npm install -g @anthropic-ai/claude-code

# Install Starship prompt - a fast, customizable prompt for any shell
RUN curl -sS https://starship.rs/install.sh | sh -s -- -y

# Create a non-root user called 'coder' for development work
# Running as non-root is a security best practice and matches how most developers work
RUN useradd -m -s /bin/zsh coder && \
    mkdir -p /home/coder/workspace && \
    chown -R coder:coder /home/coder

# Switch to the coder user for all subsequent operations
USER coder
WORKDIR /home/coder

# Install oh-my-zsh for the coder user
# oh-my-zsh provides a nice framework for managing zsh configuration
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Configure zsh with useful plugins and settings
# We're setting this up with some opinionated defaults that work well for DevOps work
RUN echo 'export ZSH="$HOME/.oh-my-zsh"' > /home/coder/.zshrc && \
    echo 'ZSH_THEME="robbyrussell"' >> /home/coder/.zshrc && \
    echo 'plugins=(git docker kubectl golang)' >> /home/coder/.zshrc && \
    echo 'source $ZSH/oh-my-zsh.sh' >> /home/coder/.zshrc && \
    echo '' >> /home/coder/.zshrc && \
    echo '# Initialize Starship prompt' >> /home/coder/.zshrc && \
    echo 'eval "$(starship init zsh)"' >> /home/coder/.zshrc && \
    echo '' >> /home/coder/.zshrc && \
    echo '# Vi mode in shell (can be disabled if you prefer)' >> /home/coder/.zshrc && \
    echo 'bindkey -v' >> /home/coder/.zshrc && \
    echo '' >> /home/coder/.zshrc && \
    echo '# Git configuration from environment variables' >> /home/coder/.zshrc && \
    echo '# Set these when running the container: GIT_USER_NAME and GIT_USER_EMAIL' >> /home/coder/.zshrc && \
    echo 'if [ ! -z "$GIT_USER_NAME" ]; then' >> /home/coder/.zshrc && \
    echo '  git config --global user.name "$GIT_USER_NAME"' >> /home/coder/.zshrc && \
    echo 'fi' >> /home/coder/.zshrc && \
    echo 'if [ ! -z "$GIT_USER_EMAIL" ]; then' >> /home/coder/.zshrc && \
    echo '  git config --global user.email "$GIT_USER_EMAIL"' >> /home/coder/.zshrc && \
    echo 'fi' >> /home/coder/.zshrc

# Configure Starship prompt with useful modules for DevOps work
# This shows git status, kubernetes context, and other useful info
RUN mkdir -p /home/coder/.config && \
    echo '[character]' > /home/coder/.config/starship.toml && \
    echo 'success_symbol = "[➜](bold green)"' >> /home/coder/.config/starship.toml && \
    echo 'error_symbol = "[➜](bold red)"' >> /home/coder/.config/starship.toml && \
    echo '' >> /home/coder/.config/starship.toml && \
    echo '[git_branch]' >> /home/coder/.config/starship.toml && \
    echo 'symbol = "🌱 "' >> /home/coder/.config/starship.toml && \
    echo '' >> /home/coder/.config/starship.toml && \
    echo '[git_status]' >> /home/coder/.config/starship.toml && \
    echo 'ahead = "⇡${count}"' >> /home/coder/.config/starship.toml && \
    echo 'diverged = "⇕⇡${ahead_count}⇣${behind_count}"' >> /home/coder/.config/starship.toml && \
    echo 'behind = "⇣${count}"' >> /home/coder/.config/starship.toml && \
    echo '' >> /home/coder/.config/starship.toml && \
    echo '[kubernetes]' >> /home/coder/.config/starship.toml && \
    echo 'disabled = false' >> /home/coder/.config/starship.toml && \
    echo 'format = "on [⎈ $context](bold blue) "' >> /home/coder/.config/starship.toml && \
    echo '' >> /home/coder/.config/starship.toml && \
    echo '[golang]' >> /home/coder/.config/starship.toml && \
    echo 'symbol = "🐹 "' >> /home/coder/.config/starship.toml

# Create code-server configuration directory
RUN mkdir -p /home/coder/.config/code-server

# Configure code-server settings
# The password is set via environment variable CODE_SERVER_PASSWORD
# which defaults to 'devops-coderbox' if not provided
RUN echo 'bind-addr: 0.0.0.0:8080' > /home/coder/.config/code-server/config.yaml && \
    echo 'auth: password' >> /home/coder/.config/code-server/config.yaml && \
    echo 'cert: false' >> /home/coder/.config/code-server/config.yaml

# Create a startup script that sets the password from environment variable
RUN echo '#!/bin/bash' > /home/coder/start-code-server.sh && \
    echo '# Set code-server password from environment variable' >> /home/coder/start-code-server.sh && \
    echo 'PASSWORD=${CODE_SERVER_PASSWORD:-devops-coderbox}' >> /home/coder/start-code-server.sh && \
    echo 'echo "password: $PASSWORD" >> /home/coder/.config/code-server/config.yaml' >> /home/coder/start-code-server.sh && \
    echo '/home/coder/welcome.sh' >> /home/coder/start-code-server.sh && \
    echo 'exec code-server --bind-addr 0.0.0.0:8080 /home/coder/workspace' >> /home/coder/start-code-server.sh && \
    chmod +x /home/coder/start-code-server.sh

# Update the welcome script to show the environment variable pattern
RUN echo '#!/bin/bash' > /home/coder/welcome.sh && \
    echo 'echo "╔═══════════════════════════════════════════════════════════════╗"' >> /home/coder/welcome.sh && \
    echo 'echo "║                  Welcome to devops-coderbox!                  ║"' >> /home/coder/welcome.sh && \
    echo 'echo "║          A DevOps-focused development environment            ║"' >> /home/coder/welcome.sh && \
    echo 'echo "╚═══════════════════════════════════════════════════════════════╝"' >> /home/coder/welcome.sh && \
    echo 'echo ""' >> /home/coder/welcome.sh && \
    echo 'echo "🌐 code-server is running at: http://localhost:8080"' >> /home/coder/welcome.sh && \
    echo 'echo "🔑 Password: ${CODE_SERVER_PASSWORD:-devops-coderbox}"' >> /home/coder/welcome.sh && \
    echo 'echo ""' >> /home/coder/welcome.sh && \
    echo 'echo "📁 Your workspace is mounted at: /home/coder/workspace"' >> /home/coder/welcome.sh && \
    echo 'echo "🐚 Shell: zsh with oh-my-zsh and Starship prompt"' >> /home/coder/welcome.sh && \
    echo 'echo "⌨️  Vim keybindings: enabled in code-server"' >> /home/coder/welcome.sh && \
    echo 'echo ""' >> /home/coder/welcome.sh && \
    echo 'echo "🔧 Installed tools:"' >> /home/coder/welcome.sh && \
    echo 'echo "   • Go $(go version | cut -d" " -f3)"' >> /home/coder/welcome.sh && \
    echo 'echo "   • kubectl $(kubectl version --client --short 2>/dev/null | cut -d" " -f3)"' >> /home/coder/welcome.sh && \
    echo 'echo "   • gh (GitHub CLI)"' >> /home/coder/welcome.sh && \
    echo 'echo "   • claude (Anthropic CLI)"' >> /home/coder/welcome.sh && \
    echo 'echo ""' >> /home/coder/welcome.sh && \
    echo '# Check for required environment variables' >> /home/coder/welcome.sh && \
    echo 'if [ -z "$GIT_USER_NAME" ] || [ -z "$GIT_USER_EMAIL" ]; then' >> /home/coder/welcome.sh && \
    echo '  echo "⚠️  WARNING: Git not configured!"' >> /home/coder/welcome.sh && \
    echo '  echo "   Set GIT_USER_NAME and GIT_USER_EMAIL environment variables"' >> /home/coder/welcome.sh && \
    echo '  echo ""' >> /home/coder/welcome.sh && \
    echo 'fi' >> /home/coder/welcome.sh && \
    echo 'if [ -z "$ANTHROPIC_API_KEY" ]; then' >> /home/coder/welcome.sh && \
    echo '  echo "⚠️  WARNING: Claude Code not configured!"' >> /home/coder/welcome.sh && \
    echo '  echo "   Set ANTHROPIC_API_KEY environment variable"' >> /home/coder/welcome.sh && \
    echo '  echo "   Get your key from: https://console.anthropic.com"' >> /home/coder/welcome.sh && \
    echo '  echo ""' >> /home/coder/welcome.sh && \
    echo 'fi' >> /home/coder/welcome.sh && \
    chmod +x /home/coder/welcome.sh

EXPOSE 8080
CMD ["/home/coder/start-code-server.sh"]
