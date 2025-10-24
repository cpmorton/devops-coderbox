# Using Claude CLI in Coderbox

The Claude CLI is pre-installed in devops-coderbox and provides a powerful way to interact with Anthropic's Claude API directly from your terminal. This document explains how to get started with the Claude CLI and some useful patterns for integrating it into your development workflow.

## Initial Setup

Before you can use the Claude CLI, you need to provide your Anthropic API key. There are a few ways to do this depending on how you're running devops-coderbox.

### Option 1: Environment Variable (Recommended for local development)

When starting your devops-coderbox container, pass your API key as an environment variable:

```bash
docker run -it -p 8080:8080 \
  -v $(pwd):/home/coder/workspace \
  -e GIT_USER_NAME="Your Name" \
  -e GIT_USER_EMAIL="your.email@example.com" \
  -e ANTHROPIC_API_KEY="your-api-key-here" \
  ghcr.io/cpmorton/devops-coderbox:latest
```

This makes the API key available to all processes running inside the container without storing it in any files.

### Option 2: Configuration File

Inside the container, you can run the Claude CLI setup wizard:

```bash
claude configure
```

This will prompt you for your API key and save it to a configuration file. The key will be stored in the container's filesystem, so if you want this to persist across container restarts, make sure you're mounting a volume that includes the config directory.

### Getting Your API Key

If you don't already have an Anthropic API key, you can get one from the Anthropic Console at https://console.anthropic.com. You'll need to create an account and add credits to your account before you can use the API.

## Basic Usage

The simplest way to use Claude is with the interactive chat mode:

```bash
claude chat
```

This starts an interactive session where you can have a conversation with Claude. Everything you type is sent to the API and Claude responds. Type `exit` or press Ctrl+D to end the session.

For one-off questions, you can pass the prompt directly:

```bash
claude "Explain what a goroutine is in Go"
```

This sends the prompt to Claude, prints the response, and exits. It's useful for quick questions or for integrating Claude into shell scripts.

## Using Claude for Code Review

One of the most powerful uses of Claude in a development environment is asking it to review your code. From within your project directory, you can pipe code to Claude:

```bash
cat main.go | claude "Review this Go code and suggest improvements"
```

Or you can ask Claude to review multiple files:

```bash
claude "Review the code in this directory and look for potential bugs" --files "*.go"
```

The Claude CLI can read files and include them as context in your prompts, which makes it much more useful than just copying and pasting code into a chat interface.

## Debugging with Claude

When you encounter an error, you can ask Claude for help directly from the terminal:

```bash
go test 2>&1 | claude "These tests are failing. What's wrong and how do I fix it?"
```

This pipes the error output from your test command into Claude and asks for help. The `2>&1` redirects stderr to stdout so Claude sees all the error messages.

## Generating Code

Claude can help generate boilerplate code or implement specific functions. For example:

```bash
claude "Generate a Go HTTP handler that responds to /health with a 200 OK and a JSON body containing the current time"
```

You can redirect the output to a file:

```bash
claude "Generate a Dockerfile for a Go web application" > Dockerfile
```

Be careful with this pattern though. Always review generated code before using it. Claude is helpful but not infallible, and blindly running generated code is a security risk.

## Integrating with Your Development Workflow

Here are some patterns that work well for integrating Claude into your daily development:

### Pre-commit Review

Before committing code, ask Claude to review what you're about to commit:

```bash
git diff --staged | claude "Review this diff and check for potential issues"
```

This shows Claude exactly what you're about to commit and asks for feedback. You can make this a git hook if you want it to happen automatically.

### Documentation Generation

When you've written a function but haven't documented it yet:

```bash
cat myfile.go | claude "Generate documentation comments for all functions in this file"
```

Claude will suggest docstrings that you can copy into your code.

### Test Generation

After writing a function, ask Claude to generate tests:

```bash
cat handlers.go | claude "Generate unit tests for all functions in this file using Go's testing package"
```

### Understanding Unfamiliar Code

When you're working with a codebase you don't understand:

```bash
cat complex_logic.go | claude "Explain what this code does in simple terms"
```

## Cost Considerations

The Claude API is not free. Each time you send a prompt, you're charged based on the number of tokens in your prompt and the response. For typical usage (asking questions, reviewing small snippets of code), the costs are very reasonable, often just a few cents per session.

However, be careful about sending large files or entire directories to Claude. The API charges for every token in your prompt, so a 5000-line file will cost significantly more than a 50-line file. Use the `--max-tokens` flag to limit response length if you're concerned about costs.

You can monitor your usage and costs in the Anthropic Console.

## Advanced Usage

The Claude CLI supports many advanced features. Read the full documentation with:

```bash
claude --help
```

Some useful flags include:

`--model` to specify which Claude model to use (claude-opus-4, claude-sonnet-4-5, etc.). Sonnet is faster and cheaper, Opus is more capable but more expensive.

`--max-tokens` to limit the length of responses. This helps control costs and keeps responses focused.

`--temperature` to control randomness in responses. Lower values (0.0-0.5) make responses more deterministic, higher values (0.5-1.0) make them more creative.

`--system` to provide system instructions that affect how Claude behaves. For example: `--system "You are a code reviewer focused on security issues"`

## Security Best Practices

Your API key is sensitive. If someone gets access to your key, they can make API calls on your account and you'll be charged for their usage. Follow these practices:

Never commit your API key to git. Always use environment variables or configuration files that are gitignored.

If you're teaching a class, provide each student with their own API key. Don't share a single key among multiple people. Anthropic's terms of service prohibit this, and it makes usage tracking impossible.

Rotate your API keys periodically. You can generate new keys in the Anthropic Console and revoke old ones.

If you accidentally expose your API key (for example, by committing it to a public repository), revoke it immediately in the Anthropic Console and generate a new one.

## Examples for Learning Go

Here are some specific prompts that work well when you're learning Go in devops-coderbox:

"Explain the difference between a pointer receiver and a value receiver in Go methods"

"Show me an example of using goroutines and channels to implement a worker pool"

"What's the idiomatic way to handle errors in Go?"

"Review this HTTP handler and check if I'm handling errors correctly"

"Generate a complete example of a REST API in Go with proper routing and error handling"

"Explain what defer does and give me some practical examples"

The key to getting good responses from Claude is being specific about what you want. Instead of "help me with Go," try "I'm getting a nil pointer panic on line 42, here's the code, what's wrong?" The more context you provide, the better Claude can help.

## Conclusion

The Claude CLI transforms your terminal into a powerful learning and development environment. You have access to Claude's knowledge and reasoning abilities without leaving the command line. This integration is especially powerful in devops-coderbox because everything is already set up and configured for you.

As you become more comfortable with the CLI, you'll find more creative ways to integrate it into your workflow. The goal isn't to have Claude write all your code for you, but rather to use it as a tireless pair programmer who's always available to answer questions, review your work, and suggest improvements.
