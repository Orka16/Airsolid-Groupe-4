#!/usr/bin/env bash
# provision-virtualbox.sh — réseaux + VM Ubuntu de la maquette AIRSOLID
# Prérequis : VirtualBox, ISO Ubuntu 24.04 / Windows dans ~/iso
set -euo pipefail
ISO="$HOME/iso"; VMDIR="$HOME/VirtualBox VMs"

# Réseaux "Internet" : deux opérateurs indépendants (+ 5G optionnel)
VBoxManage natnetwork add --netname inet-op-a --network "203.0.113.0/24" --enable --dhcp off || true
VBoxManage natnetwork add --netname inet-op-b --network "198.51.100.0/24" --enable --dhcp off || true
VBoxManage natnetwork add --netname inet-5g  --network "192.0.2.0/24"   --enable --dhcp off || true

new_ubuntu () { # <nom> <ram> <disqueMo>
  local VM="$1" RAM="$2" SZ="$3"
  VBoxManage createvm --name "$VM" --ostype Ubuntu24_LTS_64 --register
  VBoxManage modifyvm "$VM" --memory "$RAM" --cpus 1 --paravirtprovider default
  VBoxManage createhd --filename "$VMDIR/$VM/$VM.vdi" --size "$SZ" --variant Standard
  VBoxManage storagectl "$VM" --name SATA --add sata --controller IntelAhci
  VBoxManage storageattach "$VM" --storagectl SATA --port 0 --device 0 --type hdd --medium "$VMDIR/$VM/$VM.vdi"
  VBoxManage storageattach "$VM" --storagectl SATA --port 1 --device 0 --type dvddrive --medium "$ISO/ubuntu-24.04-live-server-amd64.iso"
}

# Passerelle principale : WAN-A, WAN-B, LAN, DMZ
new_ubuntu GW-MAIN 768 10000
VBoxManage modifyvm GW-MAIN --nic1 natnetwork --nat-network1 inet-op-a
VBoxManage modifyvm GW-MAIN --nic2 natnetwork --nat-network2 inet-op-b
VBoxManage modifyvm GW-MAIN --nic3 intnet --intnet3 lan-main
VBoxManage modifyvm GW-MAIN --nic4 intnet --intnet4 dmz-main

# Serveurs Linux LAN / DMZ
new_ubuntu SRV-ERP 2048 30000
VBoxManage modifyvm SRV-ERP --memory 2048 --nic1 intnet --intnet1 lan-main
new_ubuntu SRV-WEB 512 10000
VBoxManage modifyvm SRV-WEB --nic1 intnet --intnet1 dmz-main
new_ubuntu SRV-EDI 512 15000
VBoxManage modifyvm SRV-EDI --nic1 intnet --intnet1 dmz-main

# Entrepôt secondaire (phase 2)
new_ubuntu GW-WH2 512 10000
VBoxManage modifyvm GW-WH2 --nic1 natnetwork --nat-network1 inet-op-a
VBoxManage modifyvm GW-WH2 --nic2 intnet --intnet2 lan-wh2

echo "VM Ubuntu créées. VM Windows (SRV-AD1/AD2, SRV-FILES, PC-WH2) :"
echo "  --ostype Windows2022_64 (ou Windows11_64) + ISO correspondant, même schéma réseau."
echo "NAS-MAIN / NAS-WH2 : ISO TrueNAS SCALE, ou Ubuntu+Samba."
