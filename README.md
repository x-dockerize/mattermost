# Mattermost Team Edition (ARM) – Docker + Traefik + MySQL

Bu repo, **ARM64 mimarisi için derlenmiş Mattermost Team Edition** imajını kullanarak, **Traefik reverse proxy** ve **harici / yönetilen MySQL** veritabanı ile çalışan **production-ready** bir Docker Compose kurulumunu içerir.

Yapı ve anlatım dili, `x-dockerize/firezone` projesindeki README düzeni örnek alınarak hazırlanmıştır.

---

## 🚀 Amaç

Bu projenin amacı:

* ARM tabanlı sunucularda Mattermost Team Edition çalıştırmak
* HTTPS erişimi Traefik üzerinden yönetmek
* MySQL’i container içine almadan (managed / harici DB) kullanmak
* Kurulumu adım adım, net ve tekrar edilebilir hale getirmek

---

## 🧩 Gereksinimler

Kuruluma başlamadan önce aşağıdakilerin hazır olması gerekir:

* Docker Engine
* Docker Compose v2
* Çalışır durumda Traefik
* Traefik tarafından kullanılan **external Docker network**
* MySQL / MariaDB sunucusu
* ARM64 mimarili sunucu (Oracle ARM, Raspberry Pi, ARM VPS vb.)

---

## 📁 Proje Yapısı

```
.
├── .env.example
├── docker-compose.production.yml
├── .docker/
│   └── mattermost/
│       ├── data/
│       ├── logs/
│       ├── config/
│       └── plugins/
└── README.md
```

---

## ⚙️ Kurulum

### 1️⃣ Ortam Değişkenleri

Örnek ortam dosyasını kopyala:

```bash
cp .env.example .env
```

`.env` dosyasını düzenleyerek aşağıdaki alanları doldur:

* `SERVER_HOSTNAME`
* `DATABASE_HOST`
* `DATABASE_PASSWORD`
* SMTP bilgileri (opsiyonel ama önerilir)

---

### 2️⃣ Docker Compose Dosyasını Aktifleştir

Production compose dosyasını varsayılan dosya haline getir:

```bash
cp docker-compose.production.yml docker-compose.yml
```

---

### 3️⃣ Dosya Yetkileri

Mattermost container’ı **UID/GID 2000:2000** ile çalışır. Volume dizinlerinin sahipliğini ayarla:

```bash
sudo chown -R 2000:2000 ./.docker/mattermost
```

Bu adım atlanırsa Mattermost başlatılamaz.

---

### 4️⃣ Veritabanı Oluşturma (MySQL)

MySQL sunucunda aşağıdaki SQL komutlarını çalıştır:

```sql
CREATE DATABASE chat CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'mattermost'@'%' IDENTIFIED BY 'STRONG_PASSWORD_HERE';
GRANT ALL PRIVILEGES ON chat.* TO 'mattermost'@'%';
FLUSH PRIVILEGES;
```

> ⚠️ Kullanılan şifre `.env` dosyasındaki `DATABASE_PASSWORD` ile **aynı** olmalıdır.

---

### 5️⃣ Traefik Network

Traefik’in kullandığı network yoksa oluştur:

```bash
docker network create traefik-network
```

---

### 6️⃣ Servisleri Başlat

```bash
docker compose up -d
```

Kurulum tamamlandıktan sonra Mattermost arayüzüne şu adresten erişilir:

```
https://chat.example.com
```

İlk açılışta **admin kullanıcı** web arayüzü üzerinden oluşturulur.

---

## 🌐 Traefik Entegrasyonu

Mattermost servisi Traefik üzerinden aşağıdaki şekilde yayınlanır:

* Host tabanlı routing
* `websecure` entrypoint
* Otomatik TLS sertifikası

İlgili Traefik ayarları `docker-compose.yml` içindeki label’lar ile yapılmaktadır.

---

## ✉️ SMTP / Email Ayarları

SMTP ayarları `.env` dosyasından yönetilir. Email aktif edildiğinde:

* Kullanıcı davetleri
* Şifre sıfırlama
* Sistem bildirimleri

otomatik olarak çalışır.

---

## 🔄 Güncelleme

```bash
docker pull ngrie/mattermost-team-edition-arm
docker compose down
docker compose up -d
```
