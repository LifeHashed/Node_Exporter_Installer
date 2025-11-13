# Contributing to Node Exporter Installer

Thanks for your interest in contributing! This document explains how to report issues, propose changes, and submit pull requests for the Node Exporter Installer repository.

## Quick Start
- Fork the repository and create a feature branch: `git checkout -b my-feature`
- Make small, focused changes and include tests or manual test steps if applicable.
- Push your branch and open a Pull Request against `main` with a clear description.

## Reporting Issues
- Use the GitHub Issues page for bug reports and feature requests.
- Provide: steps to reproduce, expected vs actual behavior, OS/distro and version, and relevant logs or service output.

## Pull Request Process
1. Fork and branch from `main`.
2. Make your changes and ensure they are focused and well-documented.
3. Add a short description and motivation in the PR body; reference any related issue(s).
4. If your change affects runtime behavior, include upgrade notes and testing steps.
5. A maintainer will review; be responsive to review comments.

## Coding & Commit Style
- This project is a small Bash installer script. Keep shell changes:
  - Simple, readable, and safe (do not run privileged commands without clear checks).
  - Prefer `set -euo pipefail` where appropriate in new scripts.
  - Avoid changing unrelated files.
- Commit messages: use present-tense, short summary line, optional longer description. Example:

```
Add support for --version flag in installer

This adds parsing for the --version argument and documents usage in README.
```

## Local Testing
- The installer performs system-level changes and should be tested in an isolated environment (VM, container, or throwaway instance).
- Recommended workflow:
  - Test changes in a disposable VM (e.g., cloud instance or local VM) or a clean container that supports `systemd`.
  - Use `shellcheck` to lint Bash code: `shellcheck installer.sh`
  - Verify service creation: `sudo systemctl status node_exporter` and `sudo journalctl -u node_exporter -f`.

## Safety & Review Considerations
- The installer runs with elevated privileges; reviewers should be careful about commands that modify system users, remove files, or alter systemd units.
- Avoid destructive default behaviors without explicit confirmation in the UI or flags.

## PR Template (suggested)
Fill this in when creating a PR:

- **What**: Short summary of changes
- **Why**: Motivation / problem solved
- **How to test**: Steps to verify the change (include commands)
- **Notes**: Any backwards-incompatible changes, config updates, or important caveats

## Code of Conduct & License
- By contributing you agree to follow the repository's Code of Conduct (if present) and the terms of the project license (see `LICENSE`).

Thank you for helping improve this project!
