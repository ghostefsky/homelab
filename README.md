# SRE Homelab Repository

Daily-driver ПК (Ubuntu 24.04 LTS) + Homelab инфраструктура.

## Железо
- **CPU:** AMD Ryzen 5 7500F
- **GPU:** NVIDIA GeForce RTX 4070 (Driver 580.xx)
- **RAM:** 32GB
- **Storage:** NVMe 238GB (OS) + HDD 3.6TB (/home)

## Статус проекта

- [x] **Phase 1: Базовая настройка ОС & Безопасность**
  - SSH на порту 2222, вход только по ED25519 ключам
  - UFW (default deny incoming) + Fail2ban
  - AppArmor, Unattended-upgrades
  - Хранилище `~/homelab_storage` на 3.6TB HDD
  - Git-репозиторий и скрипт аудита

- [x] **Phase 2: Docker Engine & Portainer CE**
  - Docker CE (data-root перенесён на 3.6TB HDD)
  - Настройка `daemon.json` (ротация логов, live-restore, DNS)
  - UFW fix через цепочку `DOCKER-USER`
  - Portainer CE (доступен локально на `https://localhost:9443`)
  - Обновлённый скрипт аудита `audit.sh`

- [ ] **Phase 3: TBD (Next Steps)**
