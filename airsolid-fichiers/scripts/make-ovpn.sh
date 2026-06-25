#!/usr/bin/env bash
# make-ovpn.sh <utilisateur> — certificat + profil .ovpn d'un commercial nomade
set -euo pipefail
U="${1:?Usage: make-ovpn.sh <utilisateur>  (ex: com-dupont)}"
D="$HOME/easyrsa"; OUT="$HOME/profils-ovpn"; mkdir -p "$OUT"; cd "$D"
EASYRSA_BATCH=1 ./easyrsa gen-req "$U" nopass
EASYRSA_BATCH=1 ./easyrsa sign-req client "$U"
P="$D/pki"
{
  cat <<TPL
client
dev tun
proto udp
remote 203.0.113.11 1194
remote 198.51.100.11 1194
remote-random
resolv-retry infinite
nobind
remote-cert-tls server
cipher AES-256-GCM
auth SHA256
tls-version-min 1.2
persist-key
persist-tun
verb 3
key-direction 1
TPL
  echo "<ca>";       cat "$P/ca.crt";           echo "</ca>"
  echo "<cert>";     cat "$P/issued/$U.crt";    echo "</cert>"
  echo "<key>";      cat "$P/private/$U.key";    echo "</key>"
  echo "<tls-auth>"; cat "$D/ta.key";            echo "</tls-auth>"
} > "$OUT/$U.ovpn"
echo "Profil prêt : $OUT/$U.ovpn"
