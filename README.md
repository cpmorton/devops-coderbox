# Coderbox 📦

A batteries-included development environment for DevOps engineers and systems administrators who want to learn modern development practices. Coderbox gives you a fully configured browser-based IDE (code-server) with Go, kubectl, GitHub CLI, Claude CLI, and a beautiful terminal experience - all running in a container.

## What's Inside

Coderbox is built on Ubuntu 24.04 and includes everything you need to start learning web development with a DevOps mindset. The container comes pre-configured with sensible defaults, but it's designed to be forked and customized to match your preferences.

**Development Tools:** Go 1.23, Node.js, Python 3, and all the build essentials you need for compiling and running code.

**IDE:** code-server (VS Code in your browser) with pre-installed extensions for Go development, Docker, GitLens, and vim keybindings for those who prefer modal editing.

**Shell Experience:** zsh with oh-my-zsh and Starship prompt. The prompt shows your git branch, kubernetes context, and other contextual information that's useful when you're deep in the terminal. Vim keybindings are enabled in the shell by default.

**DevOps Utilities:** kubectl for Kubernetes, gh for GitHub, and the Claude CLI for interacting with Anthropic's API from the command line.

**Philosophy:** Everything in devops-coderbox is designed to be understandable and modifiable. The Dockerfile is heavily commented to explain what each piece does and why. This isn't just a dev environment, it's a teaching tool. When you read the code, you should learn how things work.

## Quick Start

The fastest way to get started is to use the pre-built container from GitHub Container Registry. This works on any machine with Docker installed.

```bash
docker run -it -p 8080:8080 \
  -v $(pwd):/home/coder/workspace \
  -e GIT_USER_NAME="Your Name" \
  -e GIT_USER_EMAIL="your.email@example.com" \
  ghcr.io/cpmorton/devops-coderbox:latest
```

Once the container starts, you'll see a welcome message with connection information. Open your browser to http://localhost:8080 and log in with the default password `devops-coderbox`. You're now running VS Code in your browser, connected to a fully configured development environment.

The `-v $(pwd):/home/coder/workspace` flag mounts your current directory into the container so any files you create or edit will persist on your local machine. The git configuration environment variables set your identity for commits.

## Platform-Specific Setup

### Windows with WSL2

Windows users get the best experience by running Docker Desktop with WSL2 as the backend. This gives you native Linux containers with excellent performance.

**Step 1: Install WSL2**

Open PowerShell as Administrator and run:

```powershell
wsl --install -d Ubuntu-24.04
```

This installs WSL2 and Ubuntu 24.04. After installation completes, reboot your machine. When you log back in, Ubuntu will finish setting up and ask you to create a username and password.

**Step 2: Install Docker Desktop**

Download Docker Desktop from https://www.docker.com/products/docker-desktop and install it. During installation, make sure the "Use WSL 2 instead of Hyper-V" option is selected.

After installation, open Docker Desktop and go to Settings > General. Verify that "Use the WSL 2 based engine" is checked. Then go to Settings > Resources > WSL Integration and enable integration with your Ubuntu distro.

**Step 3: Run Coderbox**

Open your Ubuntu terminal (you can find it in the Start menu as "Ubuntu"). Navigate to where you want to create projects and run:

```bash
docker run -it -p 8080:8080 \
  -v $(pwd):/home/coder/workspace \
  -e GIT_USER_NAME="Your Name" \
  -e GIT_USER_EMAIL="your.email@example.com" \
  ghcr.io/cpmorton/devops-coderbox:latest
```

Open http://localhost:8080 in your Windows browser (Chrome, Edge, or Firefox). The password is `devops-coderbox`.

**Important Windows Note:** Your files are stored in the WSL2 filesystem, which is separate from your Windows filesystem. To access your project files from Windows Explorer, type `\\wsl$\Ubuntu-24.04\home\yourusername` in the address bar. You can also right-click on any folder in Ubuntu and select "Open in Windows Explorer" if you have the WSL integration properly configured.

### Linux

If you're on Linux, you're in your natural habitat. Install Docker using your distribution's package manager.

**For Ubuntu/Debian:**

```bash
sudo apt-get update
sudo apt-get install docker.io docker-compose
sudo usermod -aG docker $USER
```

Log out and back in for the group membership to take effect.

**For RHEL/Fedora/Rocky:**

```bash
sudo dnf install docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
```

Again, log out and back in.

**Run Coderbox:**

```bash
docker run -it -p 8080:8080 \
  -v $(pwd):/home/coder/workspace \
  -e GIT_USER_NAME="Your Name" \
  -e GIT_USER_EMAIL="your.email@example.com" \
  ghcr.io/cpmorton/devops-coderbox:latest
```

Open http://localhost:8080 in your browser.

### macOS

macOS users should install Docker Desktop, which provides a nice integration with the Mac environment.

**Step 1: Install Docker Desktop**

Download Docker Desktop from https://www.docker.com/products/docker-desktop and drag it to your Applications folder. Launch Docker Desktop and follow the setup wizard. You may be prompted to install additional components or enter your password to complete the installation.

**Step 2: Run Coderbox**

Open Terminal.app and navigate to your projects directory:

```bash
docker run -it -p 8080:8080 \
  -v $(pwd):/home/coder/workspace \
  -e GIT_USER_NAME="Your Name" \
  -e GIT_USER_EMAIL="your.email@example.com" \
  ghcr.io/cpmorton/devops-coderbox:latest
```

Open http://localhost:8080 in Safari, Chrome, or Firefox.

**macOS Performance Note:** Docker Desktop on Mac runs containers in a VM, which means there's a slight performance overhead compared to Linux. File I/O can be slower when mounting volumes from the Mac filesystem. For the best performance, keep your projects in the container's filesystem rather than mounting from your Mac, or use Docker's optimized volume mounts.

### Chromebook (Advanced)

Getting Docker running on a Chromebook requires enabling Linux support through Crostini, and then the experience is similar to the Linux instructions above. The details vary significantly by Chromebook model and Chrome OS version, so this is left as an exercise for the reader. As a hint, you'll want to enable Linux (Beta) in Settings, install Docker in the Linux container, and then you can run devops-coderbox just like on any other Linux system.

For teaching scenarios where students have Chromebooks, consider running devops-coderbox on a cloud VM and having students connect to it over HTTPS. This gives a consistent experience regardless of the student's hardware.

## Customizing Coderbox

One of the goals of devops-coderbox is to teach you how development environments work by encouraging you to modify and rebuild the container with your own preferences. The Dockerfile is your configuration file.

To customize devops-coderbox, fork this repository to your own GitHub account. Then clone your fork and make changes to the Dockerfile. You might want to:

- Add additional tools or programming languages
- Change the default shell theme or prompt
- Pre-install additional VS Code extensions
- Modify the default code-server settings
- Add your own dotfiles or configuration scripts

After making changes, commit and push to your repository. The GitHub Actions workflow will automatically build your customized container and publish it to ghcr.io under your username. You can then run your customized version with:

```bash
docker run -it -p 8080:8080 \
  -v $(pwd):/home/coder/workspace \
  -e GIT_USER_NAME="Your Name" \
  -e GIT_USER_EMAIL="your.email@example.com" \
  ghcr.io/yourusername/devops-coderbox:latest
```

This workflow of fork, modify, rebuild, and run is exactly how you'll manage development environments in a professional setting. Learning it now will serve you well.

## Building Locally

If you want to build the container on your own machine rather than using GitHub Actions, clone this repository and run:

```bash
docker build -t devops-coderbox:local .
```

This will take several minutes the first time as Docker downloads the base Ubuntu image and installs all the tools. Subsequent builds will be faster thanks to Docker's layer caching.

To run your locally built container:

```bash
docker run -it -p 8080:8080 \
  -v $(pwd):/home/coder/workspace \
  -e GIT_USER_NAME="Your Name" \
  -e GIT_USER_EMAIL="your.email@example.com" \
  devops-coderbox:local
```

## Security Notes

The default configuration uses a simple password (`devops-coderbox`) for code-server authentication. This is fine for local development where the IDE is only accessible from localhost. If you're running devops-coderbox on a server that's accessible from the internet, you should change the password in the Dockerfile or use proper authentication mechanisms.

The container runs as a non-root user (`coder`) for security. This is a best practice that limits the damage if something goes wrong inside the container.

## Teaching with Coderbox

Coderbox is designed for teaching DevOps engineers how to develop software. If you're an instructor, consider these teaching patterns:

**Day 1: Environment Setup.** Have students run the pre-built devops-coderbox container and verify they can access the IDE. Walk through the different tools available and explain what each one does. Show them how to customize their git configuration and explore the terminal.

**Week 1: Understanding the Container.** Have students read through the Dockerfile line by line. Explain what each instruction does and why it's there. Challenge them to add one new tool or change one configuration setting, then rebuild the container.

**Week 2-4: Development Basics.** Use devops-coderbox as the environment for teaching Go, Python, or whatever language you're focusing on. The consistent environment means you're not troubleshooting different setups for different students.

**Later Weeks: CI/CD and Deployment.** Show students how the GitHub Actions workflow builds and publishes containers. Have them build similar pipelines for their own projects. This bridges the gap between "I can write code" and "I can ship code."

## Troubleshooting

**The container starts but I can't access code-server in my browser.**

Check that you're using the `-p 8080:8080` flag to expose the port. Try accessing http://localhost:8080 instead of just localhost:8080. If you're on Windows with WSL2, make sure Docker Desktop is running and WSL integration is enabled.

**I get permission errors when running docker commands.**

On Linux, you need to add your user to the docker group with `sudo usermod -aG docker $USER` and then log out and back in. On Windows and Mac, make sure Docker Desktop is running.

**My files disappear when I stop the container.**

You need to mount a volume with `-v $(pwd):/home/coder/workspace` to persist files. Anything you create inside the container that's not in a mounted volume will be lost when the container stops.

**The build fails with network errors.**

Sometimes package repositories are temporarily unavailable. Wait a few minutes and try again. If the problem persists, check your internet connection and verify you can access the URLs mentioned in the Dockerfile.

**Code-server is slow or laggy.**

This can happen on Windows and Mac due to the virtualization layer Docker uses. For better performance, keep your project files inside the container rather than mounting them from the host filesystem. You can also allocate more CPU and memory to Docker in Docker Desktop's settings.

## Contributing

Contributions are welcome! If you've added something useful to your fork of devops-coderbox, consider opening a pull request to share it with others. Good contributions might include additional tool installations, better documentation, or fixes for issues you've encountered.

## License

MIT License - see LICENSE file for details. You're free to use, modify, and distribute devops-coderbox however you want.

## Author

Created by cpmorton for teaching DevOps engineers how to level up their development skills. Built with the help of Claude, because irony is fun.
