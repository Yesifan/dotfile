# Global development preferences

- Use pnpm for Node.js projects unless the repository specifies otherwise.
- Prefer `rg` for text search and `fd` for file search.
- Do not modify lockfiles unless dependency changes are requested.
- Do not run `git push`, `git reset --hard`, `git clean`, or destructive filesystem commands without explicit approval.
- After modifying TypeScript or JavaScript code, run the relevant lint, type-check, or test command when the project provides one.
- Prefer existing project scripts and tooling over introducing new tooling.
- Never read or display `.env` files, private keys, tokens, or credentials.
