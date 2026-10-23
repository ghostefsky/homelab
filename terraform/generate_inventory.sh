#!/usr/bin/env bash
set -euo pipefail

# Пути
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_FILE="${SCRIPT_DIR}/../ansible/inventory.ini"

# Создаём папку ansible, если её нет
mkdir -p "$(dirname "$OUTPUT_FILE")"

echo "🔍 Получаем MAC-адреса из OpenTofu..."

MAC_JSON=$(cd "$SCRIPT_DIR" && tofu output -json vm_macs 2>/dev/null || true)

if [ -z "$MAC_JSON" ] || [ "$MAC_JSON" == "null" ]; then
    echo "❌ Ошибка: Не удалось получить vm_macs из OpenTofu."
    exit 1
fi

echo "⚡ Быстро сканируем подсеть 192.168.0.0/24 для обновления ARP-таблицы..."
# Фоновый пинг всех 254 адресов (занимает 1 секунду), чтобы хост узнал IP всех VM
for i in {1..254}; do
    ping -c 1 -W 1 192.168.0.$i >/dev/null 2>&1 &
done
wait

# Функция поиска IP по MAC-адресу или через virsh
get_ip_by_mac() {
    local mac="$1"
    local node_name="$2"
    local ip=""

    # 1. Ищем в ARP-таблице Linux
    ip=$(ip neigh 2>/dev/null | grep -i "$mac" | awk '{print $1}' | head -1)

    # 2. Если не нашли — пробуем через virsh arp
    if [ -z "$ip" ]; then
        ip=$(virsh -c qemu:///system domifaddr "$node_name" --source arp 2>/dev/null | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -1 || true)
    fi

    if [ -z "$ip" ]; then
        echo "UNKNOWN"
    else
        echo "$ip"
    fi
}

echo "📝 Генерируем $OUTPUT_FILE ..."

# Формируем файл inventory.ini
{
    echo "[k8s_master]"
    for node in $(echo "$MAC_JSON" | jq -r 'keys[]'); do
        if [[ "$node" == *"master"* ]]; then
            mac=$(echo "$MAC_JSON" | jq -r ".[\"$node\"]")
            ip=$(get_ip_by_mac "$mac" "$node")
            echo "${node} ansible_host=${ip} ansible_user=yakovlev ansible_ssh_private_key_file=~/.ssh/id_ed25519"
        fi
    done

    echo ""
    echo "[k8s_workers]"
    for node in $(echo "$MAC_JSON" | jq -r 'keys[]'); do
        if [[ "$node" == *"worker"* ]]; then
            mac=$(echo "$MAC_JSON" | jq -r ".[\"$node\"]")
            ip=$(get_ip_by_mac "$mac" "$node")
            echo "${node} ansible_host=${ip} ansible_user=yakovlev ansible_ssh_private_key_file=~/.ssh/id_ed25519"
        fi
    done

    echo ""
    echo "[k8s_cluster:children]"
    echo "k8s_master"
    echo "k8s_workers"
} > "$OUTPUT_FILE"

echo ""
echo "✅ ИНВЕНТАРЬ УСПЕШНО СОЗДАН:"
echo "----------------------------------------"
cat "$OUTPUT_FILE"
echo "----------------------------------------"
