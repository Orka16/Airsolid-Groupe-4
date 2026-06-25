#!/usr/bin/env bash
# init-pki.sh — PKI OpenVPN (CA + GW-MAIN serveur + WH2 client) sur GW-MAIN
set -euo pipefail
sudo apt-get update && sudo apt-get install -y openvpn easy-rsa
D="$HOME/easyrsa"; make-cadir "$D"; cd "$D"
./easyrsa init-pki
EASYRSA_BATCH=1 ./easyrsa build-ca nopass
EASYRSA_BATCH=1 ./easyrsa gen-req gw-main nopass
EASYRSA_BATCH=1 ./easyrsa sign-req server gw-main
EASYRSA_BATCH=1 ./easyrsa gen-req wh2 nopass
EASYRSA_BATCH=1 ./easyrsa sign-req client wh2
./easyrsa gen-dh
openvpn --genkey secret ta.key
echo "PKI prête dans $D/pki  (distribuer ca.crt + ta.key + cert/key propres)"
