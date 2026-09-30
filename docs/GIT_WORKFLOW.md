# Git Workflow

We use a standard branching strategy for development and releases.

## Branches
- `dev`: Active development. All feature branches and bug fixes must be merged here.
- `production`: Stable releases. Code from `dev` is promoted here when tested and ready for app stores.

## Making Changes
1. Branch off `dev`: `git checkout -b feature/my-new-feature`
2. Commit your work.
3. Open a Pull Request against `dev`.
4. Once reviewed and tested, it will be merged into `dev`.
