#!/bin/bash
# ==============================================================================
# SRE Homelab Audit Script
# Phase 1 & Phase 2 System Status Check
# ==============================================================================

echo "=================================================="
echo "          SRE HOMELAB SYSTEM AUDIT                "
echo "=================================================="
echo "Date: $(date '+%Y-%m-%d %H:%M:%S')"
echo "Host: $(hostname)"
echo ""

echo "--- [ 1. SYSTEM & DISKS ] ---"
echo "Uptime: $(uptime -p)"
echo "Memory Usage:"
free -h | awk 'NR==2{printf "  Used: %s / Total: %s (%.2f%%)\n", $3, $2, $3/$2*100}'
echo "Storage /home (sda 3.6TB):"
df -h /home | awk 'NR==2{print "  Available: " $4 " / Total: " $2 " (" $5 " used)"}'
echo ""

echo "--- [ 2. SECURITY STATUS ] ---"
echo "UFW Status: $(sudo ufw status | head -n 1)"
echo "Fail2ban Status: $(sudo systemctl is-active fail2ban 2>/dev/null || echo 'inactive')"
echo "AppArmor Status: $(sudo aa-status --enabled 2>/dev/null && echo 'active' || echo 'inactive')"
echo "SSH Port Check:"
sudo ss -tulpn | grep ssh || echo "  SSH listening on non-standard port"
echo ""

echo "--- [ 3. DOCKER ENGINE ] ---"
if command -v docker &> /dev/null; then
    echo "Docker Version: $(docker --version | awk '{print $3}' | tr -d ',')"
    echo "Docker Status: $(systemctl is-active docker)"
    echo "Docker Root Dir: $(sudo docker info 2>/dev/null | grep 'Docker Root Dir' | awk -F': ' '{print $2}')"
    echo "Log Driver: $(sudo docker info 2>/dev/null | grep 'Logging Driver' | awk -F': ' '{print $2}')"
    echo "Running Containers: $(sudo docker ps -q | wc -l)"
    echo "Total Containers: $(sudo docker ps -a -q | wc -l)"
else
    echo "Docker: NOT INSTALLED"
fi
echo ""

echo "--- [ 4. ACTIVE STACKS / CONTAINERS ] ---"
if command -v docker &> /dev/null; then
    sudo docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
fi
echo ""
echo "=================================================="
echo "Audit completed successfully."
echo "=================================================="
