# 🏷️ Compare Versions

**Compare Version** is a GitHub Actions script that operates on branches and commits to extract and compare the current and previous versions of a repository's code.

## Usage

```yaml
- uses: yaroslavzghoba/compare-versions@0.1.6
  with:
    # The URL of the repository to clone.
    #
    # If the repository is private, the URL must include a private access token.
    # For example: `https://<token>@github.com/user/repo.git`
    repo-clone-url: ''

    # Bash commands that should extract the version from the code.
    # For example: |
    #   chmod u+x ./gradlew
    #   ./gradlew printVersion
    versions-extractor: ''
```