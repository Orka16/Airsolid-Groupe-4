#!/usr/bin/env bash
# /usr/local/sbin/wan-failover.sh — bascule double fibre + 5G (AIRSOLID)
# Garde comme route par défaut le premier lien sain dans l'ordre A -> B -> 5G.
set -uo pipefail
PROBE="1.1.1.1"

# interface => passerelle de l'opérateur
declare -A GW=(
  [enp0s3]="203.0.113.1"     # fibre A
  [enp0s8]="198.51.100.1"    # fibre B
  [enp0s16]="192.0.2.1"      # box 5G (si présente)
)
ORDER=(enp0s3 enp0s8 enp0s16)

healthy() {
  ip link show "$1" >/dev/null 2>&1 || return 1
  ping -c2 -W2 -I "$1" "$PROBE" >/dev/null 2>&1
}

current=""
while true; do
  for IF in "${ORDER[@]}"; do
    [ -n "${GW[$IF]:-}" ] || continue
    if healthy "$IF"; then
      if [ "$IF" != "$current" ]; then
        ip route replace default via "${GW[$IF]}" dev "$IF"
        logger -t wan-failover "Lien actif : $IF (gw ${GW[$IF]})"
        current="$IF"
      fi
      break
    fi
  done
  sleep 10
done
