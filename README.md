# 🏷️ Compare Versions

**Compare Version** is a GitHub Actions script that operates on branches and сømmits to extract and compare the current and previous versions of a repository's code.

[▶️ Watch how it works on YouTube: https://youtu.be/KY7TzFc9Zgg?si=nNo4WTrYi5MtA8LF](https://github.com/user-attachments/assets/f1b01493-e64c-4f26-8a35-fc32d1093207)

## Usage

```yaml
- uses: yaroslavzghoba/compare-versions@1.0.2
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