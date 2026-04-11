#!/usr/bin/env bats
#
# Simple Test - Bats Framework Validation
#

setup() {
    export PROJECT_ROOT="/Users/mac/cz_code/mactools"
    export TEST_TEMP_DIR="$(mktemp -d)"
}

teardown() {
    rm -rf "$TEST_TEMP_DIR"
}

@test "Bats framework is working" {
    [ true ]
}

@test "Basic assertion works" {
    [ "hello" = "hello" ]
}

@test "Project root exists" {
    [ -d "$PROJECT_ROOT" ]
}

@test "Installer directory exists" {
    [ -d "$PROJECT_ROOT/macclaw-installer" ]
}

@test "Install script exists" {
    [ -f "$PROJECT_ROOT/macclaw-installer/install.sh" ]
}

@test "Can create temp directory" {
    [ -d "$TEST_TEMP_DIR" ]
}

@test "Command exists - bash" {
    command -v bash
}

@test "Command exists - curl" {
    command -v curl
}
