# Coolify vs Vercel: The Self-Hosting Tax Nobody Warns You About

Companion code for the Autonoma blog post 'Coolify vs Vercel: The Self-Hosting Tax Nobody Warns You About'. Wires a Coolify branch deployment into a GitHub Actions workflow, posts the preview URL on the PR, and runs an Autonoma E2E suite against it so the PR status check reflects real end-to-end test results.

> Companion code for the Autonoma blog post: **[Coolify vs Vercel: The Self-Hosting Tax Nobody Warns You About](https://getautonoma.com/blog/coolify-vs-vercel)**

## Requirements

A Coolify instance with API access, a target application configured for branch deploys, an Autonoma account with a test suite, and a GitHub repository where the workflow will run.

## Quickstart

```bash
git clone https://github.com/Autonoma-Tools/coolify-vs-vercel.git
cd coolify-vs-vercel
1. Fork this repo. 2. Add secrets COOLIFY_TOKEN, COOLIFY_API_URL, COOLIFY_APPLICATION_UUID, AUTONOMA_API_KEY, AUTONOMA_SUITE_ID to your GitHub repo settings. 3. Open a PR — the workflow will deploy to Coolify, extract the preview URL, and run Autonoma E2E tests against it. 4. The PR status check will pass only if tests pass.
```

## Project structure

```
.
├── .github/
│   └── workflows/
│       └── deploy-and-test.yml
├── scripts/
│   └── trigger-autonoma.sh
├── examples/
│   └── run-autonoma-example.sh
├── .gitignore
├── LICENSE
└── README.md
```

- `.github/workflows/` — GitHub Actions workflow that orchestrates the Coolify deploy + Autonoma test run on every pull request.
- `scripts/` — the `trigger-autonoma.sh` helper the workflow shells out to. Also callable locally.
- `examples/` — runnable examples you can execute as-is to iterate on the Autonoma integration before wiring it into CI.

## About

This repository is maintained by [Autonoma](https://getautonoma.com) as reference material for the linked blog post. Autonoma builds autonomous AI agents that plan, execute, and maintain end-to-end tests directly from your codebase.

If something here is wrong, out of date, or unclear, please [open an issue](https://github.com/Autonoma-Tools/coolify-vs-vercel/issues/new).

## License

Released under the [MIT License](./LICENSE) © 2026 Autonoma Labs.
