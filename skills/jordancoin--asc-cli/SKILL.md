---
name: asc-cli
description: App Store Connect CLI for managing builds, TestFlight, App Store submissions, metadata, signing, and pricing. Use when deploying iOS/macOS apps or managing App Store presence.
---

# App Store Connect CLI

Comprehensive guidance for using the `asc` CLI to interact with App Store Connect. Covers builds, TestFlight, submissions, metadata, signing, and pricing.

## Agent Behavior Contract

1. Always use `--help` to discover commands and flags before running.
2. Use explicit long flags (e.g., `--app`, `--output`).
3. No interactive prompts; destructive operations require `--confirm`.
4. Prefer keychain auth via `asc auth login`.
5. Use `--output table` or `--output markdown` only for human-readable output.
6. Use `--paginate` when the user wants all pages.

## Command Discovery

```bash
asc --help
asc builds --help
asc builds list --help
```

## Authentication

Prefer keychain auth:
```bash
asc auth login
```

Fallback env vars:
- `ASC_KEY_ID`, `ASC_ISSUER_ID`
- `ASC_PRIVATE_KEY_PATH` or `ASC_PRIVATE_KEY` or `ASC_PRIVATE_KEY_B64`
- `ASC_APP_ID` for default app ID

## Common Workflows

### Build Lifecycle
- Track build processing status
- Find latest builds for an app
- Clean up old builds

```bash
asc builds list --app <app-id> --limit 10
asc builds info <build-id>
```

### TestFlight Distribution
- Manage beta groups and testers
- Set "What to Test" notes
- Distribute builds to groups

```bash
asc testflight groups list --app <app-id>
asc testflight distribute <build-id> --groups "Internal Testers"
asc testflight notes set <build-id> --notes "Fixed login bug"
```

### App Store Submission
- Submit builds for review
- Check submission status
- Handle review feedback

```bash
asc submit <build-id> --app <app-id>
asc versions list --app <app-id>
```

### Metadata & Localization
- Sync app metadata
- Manage screenshots
- Handle localizations

```bash
asc metadata get --app <app-id> --locale en-US
asc metadata set --app <app-id> --locale en-US --field description --value "..."
```

### Signing & Provisioning
- Manage bundle IDs and capabilities
- Handle certificates
- Manage provisioning profiles

```bash
asc bundleids list
asc certificates list
asc profiles list
```

### Pricing
- Set base price
- Configure territory pricing
- Manage subscriptions

```bash
asc pricing set --app <app-id> --tier 1
```

## Output Formats

- Default: minified JSON
- `--output table` for human-readable tables
- `--output markdown` for markdown formatting
- `--pretty` for formatted JSON (only with JSON output)

## Timeouts

- `ASC_TIMEOUT` / `ASC_TIMEOUT_SECONDS` for request timeouts
- `ASC_UPLOAD_TIMEOUT` / `ASC_UPLOAD_TIMEOUT_SECONDS` for uploads

## Related Skills

For detailed workflows, see the specialized ASC skills:
- **asc-build-lifecycle** — Build processing and retention
- **asc-release-flow** — TestFlight and App Store release workflows
- **asc-testflight-orchestration** — Beta distribution management
- **asc-submission-health** — Submission preflight and review status
- **asc-metadata-sync** — Metadata and localization
- **asc-signing-setup** — Certificates and provisioning
- **asc-ppp-pricing** — Territory-specific pricing
- **asc-xcode-build** — Building with xcodebuild before upload
- **asc-notarization** — macOS notarization workflow
