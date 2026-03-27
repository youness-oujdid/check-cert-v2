# check-cert 🔐

![Version](https://img.shields.io/badge/version-2.0.0-blue)
![Shell](https://img.shields.io/badge/shell-bash-green)
![License](https://img.shields.io/badge/license-MIT-brightgreen)
![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20macOS-lightgrey)

> A lightweight, zero-dependency CLI tool to validate SSL certificate compatibility — check that your cert, private key, and intermediate CA all match before deploying.

---

## ✨ Features

- ✅ Validate certificate and private key match (via public key hash)
- ✅ Check certificate expiry with configurable warning threshold
- ✅ Self-signed detection (correctly compares issuer vs subject)
- ✅ Intermediate CA chain validation
- ✅ Full chain bundle verification
- ✅ Fetch and check certificates directly from remote hosts
- ✅ JSON output for CI/CD pipelines and scripting
- ✅ Verbose mode with algorithm and key size info
- ✅ Colored output (auto-disabled when piped)
- ✅ Proper exit codes for automation

---

## 📦 Installation

```bash
git clone https://github.com/youness-oujdid/check-cert.git
cd check-cert
make install
```

Or install manually:

```bash
sudo cp check_cert_key_match /usr/local/bin/check-cert
sudo chmod +x /usr/local/bin/check-cert
```

---

## 🚀 Usage

```bash
check-cert -c cert.pem -k key.pem
check-cert -c cert.pem -k key.pem -i intermediate.pem
check-cert -c cert.pem -k key.pem -b fullchain.pem
check-cert -c cert.pem -k key.pem --warn-days 60
check-cert --host example.com:443 -k key.pem
check-cert -c cert.pem -k key.pem -j > result.json
```

### Options

| Option             | Description                                         |
|--------------------|-----------------------------------------------------|
| `-c, --cert`       | Path to the certificate file (`.pem` / `.crt`)      |
| `-k, --key`        | Path to the private key file (`.pem` / `.key`)      |
| `-i, --intermediate` | Path to intermediate certificate (optional)       |
| `-b, --chain`      | Path to full chain bundle file (optional)           |
| `--host`           | Remote host to fetch cert from (e.g. `host:443`)   |
| `-w, --warn-days`  | Days before expiry to warn (default: `30`)          |
| `-v, --verbose`    | Show detailed OpenSSL output                        |
| `-j, --json`       | Output results in JSON format                       |
| `--version`        | Show version                                        |
| `-h, --help`       | Show help                                           |

---

## 🔢 Exit Codes

| Code | Meaning                          |
|------|----------------------------------|
| `0`  | All checks passed                |
| `1`  | Usage error / missing arguments  |
| `2`  | One or more checks failed        |

---

## 📤 JSON Output (for CI/CD)

```bash
check-cert -c cert.pem -k key.pem -j
```

```json
{
  "check_cert": {
    "version": "2.0.0",
    "status": "PASS",
    "cert_file": "cert.pem",
    "key_file": "key.pem",
    "cn": "example.com",
    "expiry": "Dec 31 23:59:59 2025 GMT",
    "intermediate": "null",
    "chain": "null",
    "errors_found": 0
  }
}
```

---

## 🧪 Running Tests

```bash
make test
```

Tests use [bats](https://github.com/bats-core/bats-core) (Bash Automated Testing System).

---

## 🗑️ Uninstall

```bash
make uninstall
```

---

## 🤝 Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) first.

1. Fork the repo
2. Create a feature branch: `git checkout -b feat/my-feature`
3. Commit your changes: `git commit -m 'feat: add my feature'`
4. Push and open a Pull Request

---

## 👤 Author

**Youness OUJDID** — Senior System / DevOps Engineer  
GitHub: [@youness-oujdid](https://github.com/youness-oujdid)

---

## 📄 License

MIT License — see [LICENSE](LICENSE) for details.
