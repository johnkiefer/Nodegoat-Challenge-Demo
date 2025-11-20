## Vorpal + reviewdog GitHub Action

This repository includes a CI workflow (`.github/workflows/vorpal-reviewdog.yml`) that runs the Vorpal GitHub Action together with reviewdog. The workflow performs automated static analysis for every push and pull request targeting `main`.

### What the workflow does

1. Checks out the current revision.
2. Sets up Node.js 20 with npm caching enabled.
3. Installs the Vorpal CLI globally and runs `vorpal analyze`, writing the JSON output to `vorpal-report.json`.
4. Installs reviewdog (`v0.20.3`) directly from the official install script and adds it to the runner `PATH`.
5. When the workflow runs on a pull request, reviewdog parses the Vorpal report and leaves inline comments via the default `${{ secrets.GITHUB_TOKEN }}`.
6. Uploads `vorpal-report.json` as an artifact so results can be downloaded from the workflow summary.

### Viewing the results

- Open the **Actions** tab in GitHub and select **Vorpal Code Analysis**.
- For pull requests, reviewdog will annotate the diff with any findings.
- Download the `vorpal-report` artifact to inspect the full JSON report locally.

### Security considerations

- Avoid elevating permissions; the workflow only requests read access to repo contents and write access to pull requests for reviewdog comments.
- Reviewdog previously experienced a supply-chain compromise (March 2025). Always pin to a known-good version (as this workflow does with `REVIEWDOG_VERSION`) and monitor the [StepSecurity advisory](https://www.stepsecurity.io/blog/reviewdog-github-actions-are-compromised) for updates.

### Troubleshooting

| Symptom | Resolution |
| --- | --- |
| Workflow cannot find `vorpal` | Ensure the npm install step succeeds; re-run the workflow if the npm registry was temporarily unavailable. |
| reviewdog fails because no PR context | This is expected on `push` events. The workflow only invokes reviewdog when `github.event_name == 'pull_request'`. |
| Missing annotations despite findings | Confirm the GitHub token has permission to comment on pull requests and that `reviewdog` runs without returning an error. |

### Running locally

```bash
# Install dependencies
npm install -g vorpal
curl -sfL https://raw.githubusercontent.com/reviewdog/reviewdog/master/install.sh | sh -s -- -b ./bin

# Run Vorpal
vorpal analyze --output=vorpal-report.json

# Run reviewdog in local (reporter=local)
cat vorpal-report.json | ./bin/reviewdog -f=vorpal -reporter=local
```

### Forcing a CI run

Open a short-lived branch, make any documentation-only tweak, and open a pull request. The `Vorpal Code Analysis` workflow triggers on every PR targeting `main`, so even a whitespace-only doc change is enough to kick off a fresh scan.

Keep the workflow updated if Vorpal changes its output format or if the reviewdog CLI requires different flags.

