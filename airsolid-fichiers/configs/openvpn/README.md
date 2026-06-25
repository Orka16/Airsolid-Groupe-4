# Configurations OpenVPN — AIRSOLID

Certificats/clés **non versionnés** (cf. `.gitignore`). Génération via `scripts/init-pki.sh`
(site-à-site) et `scripts/make-ovpn.sh` (profils nomades).

| Fichier | Rôle | Déployé sur |
|---|---|---|
| `server-roadwarrior.conf` | VPN nomades (port 1194) | GW-MAIN |
| `server-site2site.conf` | VPN entrepôt (port 1195) | GW-MAIN |
| `ccd/wh2` | IP tunnel + iroute entrepôt | GW-MAIN |
| `client-wh2.conf` | Client site-à-site | GW-WH2 |
| `client-roadwarrior.ovpn` | Modèle profil nomade | postes commerciaux |

Les clients listent **deux `remote`** (fibre Orange + fibre SFR) pour suivre la bascule WAN.
