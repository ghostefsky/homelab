# Phase 2: Docker Engine, UFW Security & Portainer CE

**Дата завершения:** $(date '+%Y-%m-%d')
**Статус:** ✅ Завершена

## Что реализовано

### 1. Установка Docker Engine
- Установлен официальный Docker CE (v27+) + плагин Docker Compose v2.
- Отказались от Snap и Desktop версий в пользу чистой серверной системы.

### 2. Конфигурация хранилища (4TB HDD)
- Настроен `/etc/docker/daemon.json`.
- `data-root` перенесён на большой ext4-диск: `/home/yakovlev/homelab_storage/docker`.
- Системный NVMe (238GB) освобождён от данных контейнеров и образов.
- Добавлена система ротации логов: `max-size: 10m`, `max-file: 3`.
- Включен `live-restore: true`.
- В `systemd` настроена зависимость `RequiresMountsFor=/home`, исключающая старт Docker до монтирования HDD.

### 3. Защита UFW + Docker
- Устранена проблема обхода UFW контейнерами Docker.
- В `/etc/ufw/after.rules` настроена цепочка `DOCKER-USER` (фильтрация внешней сети, доступ открыт для `192.168.0.0/24` и `127.0.0.1`).

### 4. Управление через Portainer CE
- Развёрнут стек `stacks/portainer/docker-compose.yml`.
- Порт привязан жестко к `127.0.0.1:9443` (нет прямого доступа из внешнего интернета).
- Данные Portainer хранятся в `~/homelab_storage/docker/portainer`.
