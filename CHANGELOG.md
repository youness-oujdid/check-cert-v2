# Changelog

All notable changes to check-cert will be documented here.

## [2.0.0] - 2026-03-27

### Added
- Remote host certificate fetching (`--host example.com:443`)
- JSON output mode (`-j / --json`) for CI/CD integration
- Configurable expiry warning threshold (`-w / --warn-days`)
- Full chain bundle verification (`-b / --chain`)
- Key algorithm and size validation (warns on RSA < 2048 bits)
- `--version` flag
- Proper exit codes (0 = pass, 1 = usage error, 2 = checks failed)
- bats test suite in `tests/`
- GitHub Actions CI workflow (ShellCheck + bats)
- MIT license
- `set -euo pipefail` for safer bash execution
- Auto-disable colors when output is piped (TTY detection)

### Fixed
- Self-signed detection was always returning true — now correctly compares issuer vs subject
- `rm -f "$CERT_HASH" "$KEY_HASH"` was trying to delete hash strings as files (no-op)
- Intermediate file existence check now happens before reading it
- Typo: `--verbos` → `--verbose`
- Misleading message "will not expire after" → "expires on $DATE ($N days left)"
- Hash comparison now uses SHA256 instead of MD5

## [1.0.0] - 2025-04-01

### Added
- Initial release
- Certificate validity check
- Private key validation
- Cert ↔ key public key match
- Optional intermediate CA comparison
- Verbose mode
- Man page and Makefile
