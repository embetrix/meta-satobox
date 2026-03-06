#!/bin/bash
# SPDX-License-Identifier: MIT
#
# Generate signing keys for build.
#
# Three key pairs are created:
#   1. FIT image  : RSA-2048 / SHA-256  (required by U-Boot mkimage)
#   2. Kernel modules : ECDSA P-256 / SHA-256
#   3. IMA/EVM     : ECDSA P-256 / SHA-256  (PEM key + PEM cert + DER cert)
#
# The secure-boot key is NOT touched it is long-lived and should be
# managed separately (ideally in an HSM).
#
# Usage:
#   gen-keys.sh [output-dir]
#
# If output-dir is omitted, keys are written to
#   <meta-satobox>/conf/keys/devel/{fitimage,kmod,ima-evm}/

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
META_SATOBOX="$(dirname "${SCRIPT_DIR}")"
DEFAULT_KEY_BASE="${META_SATOBOX}/conf/keys/devel"

CERT_DAYS=1        # valid for a single day
CERT_ORG="Satobox"


KEY_BASE="${1:-${DEFAULT_KEY_BASE}}"

log()  { printf '> %s\n' "$*"; }
die()  { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

command -v openssl >/dev/null 2>&1 || die "openssl not found in PATH"

# -------------------------------------------------------------------
# 1. FIT image key  (RSA-2048)
# -------------------------------------------------------------------
FIT_DIR="${KEY_BASE}/fitimage"
mkdir -p "${FIT_DIR}"

log "Generating FIT image RSA-2048 key pair in ${FIT_DIR}"

openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 \
    -out "${FIT_DIR}/fitimage-sign.key" 2>/dev/null

openssl req -new -x509 -key "${FIT_DIR}/fitimage-sign.key" \
    -out "${FIT_DIR}/fitimage-sign.crt" \
    -days "${CERT_DAYS}" -batch \
    -subj "/O=${CERT_ORG}/CN=fitimage-sign"

# -------------------------------------------------------------------
# 2. Kernel module signing key  (ECDSA P-256)
# -------------------------------------------------------------------
KMOD_DIR="${KEY_BASE}/kmod"
mkdir -p "${KMOD_DIR}"

log "Generating kernel module ECDSA P-256 key pair in ${KMOD_DIR}"

openssl ecparam -genkey -name prime256v1 \
    -out "${KMOD_DIR}/kmod-sign.key" 2>/dev/null

openssl req -new -x509 -key "${KMOD_DIR}/kmod-sign.key" \
    -out "${KMOD_DIR}/kmod-sign.crt" \
    -days "${CERT_DAYS}" -batch \
    -subj "/O=${CERT_ORG}/CN=kmod-sign"

# -------------------------------------------------------------------
# 3. IMA/EVM signing key  (ECDSA P-256)
#    Produces .key (PEM), .crt (PEM) and .der (DER certificate)
# -------------------------------------------------------------------
IMA_DIR="${KEY_BASE}/ima-evm"
mkdir -p "${IMA_DIR}"

log "Generating IMA/EVM ECDSA P-256 key pair in ${IMA_DIR}"

openssl genpkey -algorithm EC -pkeyopt ec_paramgen_curve:prime256v1 \
    -out "${IMA_DIR}/ima-evm.key" 2>/dev/null

openssl req -new -x509 -key "${IMA_DIR}/ima-evm.key" \
    -out "${IMA_DIR}/ima-evm.crt" \
    -days "${CERT_DAYS}" -batch \
    -subj "/O=${CERT_ORG}/CN=ima-evm"

openssl x509 -in "${IMA_DIR}/ima-evm.crt" \
    -outform DER -out "${IMA_DIR}/ima-evm.der"

log "Ephemeral keys generated successfully:"
log "  FIT image : ${FIT_DIR}/fitimage-sign.{key,crt}"
log "  kmod      : ${KMOD_DIR}/kmod-sign.{key,crt}"
log "  IMA/EVM   : ${IMA_DIR}/ima-evm.{key,crt,der}"
