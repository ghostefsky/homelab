#!/bin/bash
echo "=========================================="
echo "      HOMELAB SECURITY AUDIT REPORT      "
echo "=========================================="
echo "[+] NVIDIA GPU:"
nvidia-smi --query-gpu=name,driver_version --format=csv,noheader
echo ""
echo "[+] Listening Ports:"
sudo ss -tlnp | grep LISTEN
echo ""
echo "[+] Firewall Status:"
sudo ufw status
echo ""
echo "[+] Fail2ban SSH Protection:"
sudo fail2ban-client status sshd
echo "=========================================="
EOF
