# Trivy: scanning & reporting cheatsheet

## Install

```bash
# macOS
brew install trivy

# Linux (one-liner)
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin

# No install — run via Docker
docker run --rm aquasec/trivy image nginx:latest
```

---

## Scan a remote image

```bash
# Basic scan (all severities)
trivy image nginx:latest

# Filter to HIGH and CRITICAL only
trivy image --severity HIGH,CRITICAL nginx:latest

# Ignore unfixed vulnerabilities
trivy image --ignore-unfixed nginx:latest
```

---

## Generate a report

```bash
# JSON — for automation / parsing
trivy image --format json --output report.json nginx:latest

# HTML — human-readable report you can open in a browser
trivy image --format template \
  --template "@contrib/html.tpl" \
  --output report.html \
  nginx:latest

# SARIF — upload to GitHub Security tab
trivy image --format sarif --output report.sarif nginx:latest

# SBOM (CycloneDX) — software bill of materials
trivy image --format cyclonedx --output sbom.json nginx:latest

# SBOM (SPDX)
trivy image --format spdx-json --output sbom.spdx.json nginx:latest
```

> **Tip:** The HTML template file (`html.tpl`) ships with Trivy.
> Find it at `$(brew --prefix trivy)/share/trivy/templates/` on macOS
> or clone it from the [Trivy contrib folder](https://github.com/aquasecurity/trivy/tree/main/contrib).

---

## Scan a local image (saved as a tar)

```bash
# Step 1 — save the image to a .tar file
docker save myapp:latest -o myapp.tar

# Step 2 — scan the tar directly
trivy image --input myapp.tar

# Step 2 (with report)
trivy image --input myapp.tar \
  --format json \
  --output myapp-report.json
```

> This is the workflow for air-gapped environments or scanning
> images that haven't been pushed to a registry yet.

---

## Useful flags

| Flag | What it does |
|---|---|
| `--severity HIGH,CRITICAL` | Only show high/critical CVEs |
| `--ignore-unfixed` | Skip CVEs with no fix available |
| `--exit-code 1` | Fail the command if vulnerabilities found (CI use) |
| `--timeout 5m` | Increase timeout for large images |
| `--skip-update` | Skip DB update (offline / faster) |
| `--scanners vuln,secret` | Also scan for hardcoded secrets |

---

## CI/CD — fail the build on critical CVEs

```bash
# Exits with code 1 if any CRITICAL CVE is found
trivy image --exit-code 1 --severity CRITICAL myapp:latest
```

```yaml
# GitHub Actions example
- name: Scan image
  uses: aquasecurity/trivy-action@master
  with:
    image-ref: myapp:latest
    format: sarif
    output: trivy-results.sarif
    severity: CRITICAL,HIGH

- name: Upload to GitHub Security tab
  uses: github/codeql-action/upload-sarif@v2
  with:
    sarif_file: trivy-results.sarif
```

---
