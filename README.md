<p align="center">
  <img src="public/brand/bull-logo.svg" width="96" alt="Bull logo">
</p>

<h1 align="center">Bull docs</h1>

<p align="center">The landing page and documentation of <strong>Bull</strong>, the React bundler that refuses to build unless you respect MVVM.<br>
Built with <a href="https://astro.build">Astro</a> and <a href="https://starlight.astro.build">Starlight</a>, deployed to GitHub Pages.</p>

## What is here

```
src/pages/index.astro          the landing page
src/components/landing/        hero with the replayed build, layer diagram, tooling, code sample
src/content/docs/docs/         the documentation (Markdown, rendered by Starlight)
src/content/docs/docs/rules/   the rule reference, generated from Bull's rule catalog
scripts/setup.sh               build, test and run Bull from source (macOS, Linux, Git Bash)
scripts/setup.ps1              the same for Windows PowerShell
scripts/sync-rules.mjs         regenerates the rule reference
.github/workflows/deploy.yml   builds and deploys the site to GitHub Pages
```

## Develop the site

```bash
npm install
npm run dev        # http://localhost:4321
npm run build      # static site in dist/
npm run preview
```

## Run Bull itself

The setup scripts install, build and test the Bull monorepo, check the example app's architecture
and start it:

```bash
./scripts/setup.sh --repo ../bull              # a local clone, or a git URL
./scripts/setup.sh --repo ../bull --e2e --no-dev
```

```powershell
./scripts/setup.ps1 -Repo ..\bull
./scripts/setup.ps1 -Repo ..\bull -E2E -NoDev
```

Every option is listed with `--help` / `-Help`, and `--dry-run` / `-DryRun` prints the commands
without running them.

## Update the rule reference

The rule pages come from Bull's rule catalog. After changing rules in Bull, build it and run:

```bash
BULL_REPO=../bull npm run sync:rules
```

## Deploy

1. Push this repository to GitHub.
2. In **Settings → Pages**, set **Source** to **GitHub Actions**.
3. Optionally, add a repository variable `BULL_REPO_URL` (Settings → Secrets and variables →
   Actions → Variables) with the URL of the Bull repository, to show GitHub links in the site.

Every push to `main` builds the site with `BASE_PATH=/<repository>/` and deploys it to
`https://<owner>.github.io/<repository>/`. To build the same thing locally:

```bash
BASE_PATH=/bull-docs SITE_URL=https://<owner>.github.io npm run build
```

## License

MIT
