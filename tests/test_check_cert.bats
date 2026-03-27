#!/usr/bin/env bats
# Tests for check-cert
# Run with: bats tests/test_check_cert.bats

SCRIPT="./check_cert_key_match"
FIXTURES="tests/fixtures"

# ── helpers ────────────────────────────────────────────────────────────────────
setup() {
    mkdir -p "$FIXTURES"
    # CA
    openssl genrsa -out "$FIXTURES/ca.key" 2048 2>/dev/null
    openssl req -new -x509 -days 3650 -key "$FIXTURES/ca.key" \
        -out "$FIXTURES/ca.crt" \
        -subj "/CN=Test CA/O=TestOrg/C=MA" 2>/dev/null
    # Server cert signed by CA
    openssl genrsa -out "$FIXTURES/server.key" 2048 2>/dev/null
    openssl req -new -key "$FIXTURES/server.key" \
        -out "$FIXTURES/server.csr" \
        -subj "/CN=example.com/O=TestOrg/C=MA" 2>/dev/null
    openssl x509 -req -days 365 \
        -in "$FIXTURES/server.csr" \
        -CA "$FIXTURES/ca.crt" \
        -CAkey "$FIXTURES/ca.key" \
        -CAcreateserial \
        -out "$FIXTURES/server.crt" 2>/dev/null
    # Mismatched key
    openssl genrsa -out "$FIXTURES/wrong.key" 2048 2>/dev/null
    # Self-signed cert
    openssl req -new -x509 -days 365 -key "$FIXTURES/server.key" \
        -out "$FIXTURES/self.crt" \
        -subj "/CN=self.example.com/O=TestOrg/C=MA" 2>/dev/null
}

teardown() {
    rm -rf "$FIXTURES"
}

# ── tests ──────────────────────────────────────────────────────────────────────

@test "shows help with no arguments" {
    run "$SCRIPT"
    [ "$status" -eq 0 ]
    [[ "$output" == *"Usage"* ]]
}

@test "shows version" {
    run "$SCRIPT" --version
    [ "$status" -eq 0 ]
    [[ "$output" == *"check-cert v"* ]]
}

@test "cert and key match — exits 0" {
    run "$SCRIPT" -c "$FIXTURES/server.crt" -k "$FIXTURES/server.key"
    [ "$status" -eq 0 ]
    [[ "$output" == *"match"* ]]
}

@test "cert and wrong key — exits 2" {
    run "$SCRIPT" -c "$FIXTURES/server.crt" -k "$FIXTURES/wrong.key"
    [ "$status" -eq 2 ]
    [[ "$output" == *"do NOT match"* ]]
}

@test "detects self-signed certificate" {
    run "$SCRIPT" -c "$FIXTURES/self.crt" -k "$FIXTURES/server.key"
    [[ "$output" == *"self-signed"* ]]
}

@test "intermediate match passes" {
    run "$SCRIPT" -c "$FIXTURES/server.crt" -k "$FIXTURES/server.key" -i "$FIXTURES/ca.crt"
    [ "$status" -eq 0 ]
}

@test "missing cert file exits with error" {
    run "$SCRIPT" -c "/nonexistent/cert.pem" -k "$FIXTURES/server.key"
    [ "$status" -eq 1 ]
    [[ "$output" == *"not found"* ]]
}

@test "missing key file exits with error" {
    run "$SCRIPT" -c "$FIXTURES/server.crt" -k "/nonexistent/key.pem"
    [ "$status" -eq 1 ]
    [[ "$output" == *"not found"* ]]
}

@test "JSON output is valid JSON" {
    run "$SCRIPT" -c "$FIXTURES/server.crt" -k "$FIXTURES/server.key" -j
    [ "$status" -eq 0 ]
    echo "$output" | python3 -m json.tool > /dev/null
}

@test "verbose mode shows extra output" {
    run "$SCRIPT" -c "$FIXTURES/server.crt" -k "$FIXTURES/server.key" -v
    [ "$status" -eq 0 ]
    [[ "$output" == *"SHA256"* ]]
}
