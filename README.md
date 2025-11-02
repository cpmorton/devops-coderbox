# devops-coderbox

A batteries-included development environment for DevOps engineers learning software development. Run a complete IDE in your browser with Go, kubectl, GitHub CLI, Claude Code, and a configured shell - all in a Docker container.

## Table of Contents

- [What Is This?](#what-is-this)
- [Quick Start](#quick-start)
- [Prerequisites](#prerequisites)
  - [Windows with WSL2](#windows-with-wsl2)
  - [Linux](#linux)
  - [macOS](#macos)
- [Using devops-coderbox](#using-devops-coderbox)
- [Customizing](#customizing)
- [Building Locally](#building-locally)
- [Common Commands](#common-commands)
- [Security Notes](#security-notes)
- [Troubleshooting](#troubleshooting)

## What Is This?

devops-coderbox gives you a fully configured development environment running in your browser. Inside the container you get:

- **code-server** - VS Code running in your browser at http://localhost:8080
- **Go 1.23** - Modern Go development tools
- **kubectl** - Kubernetes command line
- **GitHub CLI (gh)** - Interact with GitHub from terminal
- **Claude Code** - Anthropic's AI coding assistant
- **zsh + oh-my-zsh** - Beautiful, functional shell
- **Starship prompt** - Shows git status, k8s context, and more
- **Vim keybindings** - In both the shell and code-server

The environment is designed for DevOps engineers who want to learn development practices. Everything is pre-configured and heavily commented to explain not just what things do, but why they're structured that way.

## Quick Start

Pull and run the pre-built container:

```bash
docker run -it -p 8080:8080 \
  -v $(pwd):/home/coder/workspace \
  -e GIT_USER_NAME="Your Name" \
  -e GIT_USER_EMAIL="your.email@example.com" \
  ghcr.io/yourusername/devops-coderbox:latest
```

Open http://localhost:8080 in your browser. The default password is `devops-coderbox`.

The `-v $(pwd):/home/coder/workspace` mounts your current directory into the container, so any files you create persist on your local machine.

## Prerequisites

You need Docker to run devops-coderbox. Installation varies by platform.

### Windows with WSL2

**Install WSL2:**
```powershell
wsl --install -d Ubuntu-24.04
```

Restart when prompted. After restart, Ubuntu will finish setup and ask for a username and password.

**Install Docker Engine in WSL2:**

Open your Ubuntu terminal and run these commands:

```bash
# Update package index
sudo apt-get update

# Install prerequisites
sudo apt-get install -y ca-certificates curl gnupg lsb-release

# Add Docker's GPG key
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package index again
sudo apt-get update

# Install Docker Engine
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Start Docker
sudo service docker start

# Add yourself to docker group (then log out and back in)
sudo usermod -aG docker $USER
```

After running these commands, close your terminal completely and open a new one. Verify Docker works:

```bash
docker run hello-world
```

**Important:** You need to run `sudo service docker start` each time you open a new terminal in WSL2.

### Linux

**Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install docker.io docker-compose
sudo usermod -aG docker $USER
```

**RHEL/Fedora/Rocky:**
```bash
sudo dnf install docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
```

Log out and back in for group membership to take effect.

### macOS

Download and install [Docker Desktop for Mac](https://www.docker.com/products/docker-desktop). Follow the installation wizard. Once installed, Docker Desktop runs automatically and provides the docker command.

## Using devops-coderbox

Once you have Docker working, you can run devops-coderbox. The recommended way is through docker-compose in your project, but you can also run it standalone.

### With docker-compose (Recommended)

Most projects that use devops-coderbox will have a `docker-compose.yml` file configured. Set your environment variables in a `.env` file:

```bash
# Create .env file in your project directory
cat > .env << 'EOF'
GITHUB_USERNAME=yourusername
GIT_USER_NAME=Your Name
GIT_USER_EMAIL=your.email@example.com
ANTHROPIC_API_KEY=sk-ant-your-key-here
CODE_SERVER_PASSWORD=your-secure-password
EOF

# Start everything
docker compose up
```

Open http://localhost:8080 and use the password from your `.env` file.

### Standalone (Without docker-compose)

If running devops-coderbox by itself:

```bash
docker run -it -p 8080:8080 \
  -v $(pwd):/home/coder/workspace \
  -e GIT_USER_NAME="Your Name" \
  -e GIT_USER_EMAIL="your.email@example.com" \
  -e ANTHROPIC_API_KEY="sk-ant-your-key-here" \
  -e CODE_SERVER_PASSWORD="your-password" \
  ghcr.io/yourusername/devops-coderbox:latest
```

**Required environment variables:**
- `GIT_USER_NAME` - Your name for git commits
- `GIT_USER_EMAIL` - Your email for git commits  
- `ANTHROPIC_API_KEY` - API key from https://console.anthropic.com

**Optional environment variables:**
- `CODE_SERVER_PASSWORD` - IDE password (defaults to "devops-coderbox" if not set)

The container will display warnings if required variables are missing, but will still start. However, git and Claude Code won't work without proper configuration.

## Customizing

Fork this repository and modify the Dockerfile to match your preferences. Common customizations:

**Change the password:**
Find the line `password: devops-coderbox` in the Dockerfile and change it.

**Add more tools:**
Add RUN commands to install additional packages. For example, to add Python:
```dockerfile
RUN apt-get update && apt-get install -y python3 python3-pip
```

**Change the shell theme:**
Modify the Starship configuration section or switch to a different oh-my-zsh theme.

**Add VS Code extensions:**
Add more `code-server --install-extension` lines with the extension IDs you want.

After making changes, commit and push to your repository. GitHub Actions automatically builds and publishes your customized image to ghcr.io.

## Building Locally

To build the image on your own machine:

```bash
docker build -t devops-coderbox:local .
```

This takes 5-10 minutes the first time. Subsequent builds are faster thanks to Docker's layer caching.

Run your locally-built image:

```bash
docker run -it -p 8080:8080 \
  -v $(pwd):/home/coder/workspace \
  -e GIT_USER_NAME="Your Name" \
  -e GIT_USER_EMAIL="your.email@example.com" \
  devops-coderbox:local
```

## Common Commands

**Start the container:**
```bash
docker run -it -p 8080:8080 -v $(pwd):/home/coder/workspace ghcr.io/yourusername/devops-coderbox:latest
```

**Pull the latest version:**
```bash
docker pull ghcr.io/yourusername/devops-coderbox:latest
```

**Build locally:**
```bash
docker build -t devops-coderbox:local .
```

**Access the running container's shell:**
```bash
docker exec -it <container-name> /bin/zsh
```

**Remove stopped containers and free disk space:**
```bash
docker system prune
```

## Security Notes

The default password `devops-coderbox` is simple for convenience in local development. This is acceptable because code-server only listens on localhost by default, which means it's only accessible from your own machine.

**If you run this container on a cloud VM or expose it to the internet**, you MUST change the password to something secure. Better yet, use OAuth or other authentication methods. The simple password is only appropriate when the IDE is accessed via localhost.

The container runs as a non-root user (`coder`) for security. This limits the damage if something goes wrong inside the container.

## Troubleshooting

**Container won't start:**
- Check that Docker is running: `docker ps`
- On WSL2, did you run `sudo service docker start` this session?
- Is port 8080 already in use? Check with `netstat -an | grep 8080`

**Can't access IDE at localhost:8080:**
- Verify the container is running: `docker ps`
- Check you're using http://localhost:8080 not just localhost:8080
- Try 127.0.0.1:8080 instead of localhost:8080

**Permission errors running docker commands:**
- On Linux, did you add yourself to the docker group and log out/in?
- On WSL2, did you log out of your terminal session after adding to docker group?

**Changes to mounted files aren't appearing:**
- Make sure you're editing files in `/home/coder/workspace` inside the container
- Verify the volume mount is correct when you started the container

**Build fails:**
- Package names change. Verify all package names in the Dockerfile exist.
- Network issues. Wait and retry, or check if package repositories are accessible.
- Check the build logs carefully - they usually point to exactly what failed.

**GitHub Actions build fails:**
- Check the Actions tab on GitHub for detailed logs
- Common issue: package names that don't exist or have changed
- Verify all URLs and package names in the Dockerfile are current

---

## Questions or Issues?

Open an issue on GitHub if you encounter problems or have suggestions for improvements.

## License

MIT License - see LICENSE file for details.
