# Partages SMB — SRV-FILES (continuité fichiers / accès commerciaux)

## Structure et permissions (moindre privilège, alignées AD)
| Partage | Groupe AD | Droits |
|---|---|---|
| `\\SRV-FILES\Commerciaux` | GG_Commerciaux | Modifier |
| `\\SRV-FILES\ERP-Donnees` | GG_ERP | Modifier |
| `\\SRV-FILES\Direction` | GG_Direction | Modifier |
| `\\SRV-FILES\Public` | Utilisateurs du domaine | Lecture |

## Bonnes pratiques
- Permissions **NTFS** maîtresses ; permissions de partage larges (Utilisateurs authentifiés : Modifier) et NTFS restrictives.
- **Access-Based Enumeration** activé : on ne voit que ce à quoi on a droit.
- SMB **signé** et **SMBv1 désactivé**.
- Lecteurs réseau déployés par **GPO** (ex. Z: -> Commerciaux).

## Lien avec le reste
- **Source** des sauvegardes Robocopy -> NAS-MAIN (docs/06).
- **Cible** du VPN nomades (docs/07).
- **Répliqué** vers l'entrepôt en phase 2 (docs/08).
