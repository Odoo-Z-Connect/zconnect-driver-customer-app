# Security Guidelines

## Secrets Management
- NEVER commit secrets, API keys, keystores, or `.env` files to the repository.
- Our `.gitignore` explicitly blocks `.env` and `.keystore` files.
- If the app requires API keys (e.g., Google Maps if added later), use an `.env` file via `flutter_dotenv` or inject them at build time. See `.env.example` for required keys.

## Accidental Commits
If a secret is accidentally committed:
1. DO NOT simply delete it in a new commit. The secret is still in the git history.
2. Immediately revoke/rotate the compromised credential in the external provider's dashboard.
3. Use a tool like `git-filter-repo` or BFG to strip it from history if necessary.
