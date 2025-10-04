# 🏷️ Compare Versions

**Compare Version** is a GitHub Actions script that operates on branches and сømmits to extract and compare the current and previous versions of a repository's code.

![docs/compare-versions.mp4](docs/compare-versions.mp4)

## Usage

```yaml
- uses: yaroslavzghoba/compare-versions@1.0.1
  with:
    # The URL of the repository to clone.
    # If the repository is private, the URL must include a private access token.
    # For example: `https://token@github.com/user/repo.git`
    repo-clone-url: ''

    # Bash commands that should extract the version from the code.
    # For example: |
    #   cat ./version.txt
    versions-extractor: ''

    # The shell to use for running the commands. By default, it is set to `bash`.
    shell: ''
```