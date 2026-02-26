#!/usr/bin/env bash
set -e

ENV_EXAMPLE=".env.example"
ENV_FILE=".env"

# --------------------------------------------------
# Kontroller
# --------------------------------------------------
if [ ! -f "$ENV_EXAMPLE" ]; then
  echo "❌ $ENV_EXAMPLE bulunamadı."
  exit 1
fi

if [ ! -f "$ENV_FILE" ]; then
  cp "$ENV_EXAMPLE" "$ENV_FILE"
  echo "✅ $ENV_EXAMPLE → $ENV_FILE kopyalandı"
else
  echo "ℹ️  $ENV_FILE mevcut, güncellenecek"
fi

# --------------------------------------------------
# Yardımcı Fonksiyonlar
# --------------------------------------------------
gen_password() {
  openssl rand -base64 24 | tr -dc 'A-Za-z0-9' | head -c 20
}

set_env() {
  local key="$1"
  local value="$2"

  if grep -q "^${key}=" "$ENV_FILE"; then
    sed -i "s|^${key}=.*|${key}=${value}|" "$ENV_FILE"
  else
    echo "${key}=${value}" >> "$ENV_FILE"
  fi
}

set_env_once() {
  local key="$1"
  local value="$2"

  local current
  current=$(grep "^${key}=" "$ENV_FILE" 2>/dev/null | cut -d'=' -f2-)

  if [ -z "$current" ]; then
    set_env "$key" "$value"
  fi
}

# --------------------------------------------------
# Kullanıcıdan Gerekli Bilgiler
# --------------------------------------------------
read -rp "MATTERMOST_SERVER_HOSTNAME (örn: chat.example.com): " MATTERMOST_SERVER_HOSTNAME

echo
echo "--- SMTP Ayarları ---"
read -rp "SMTP_HOST (örn: live.smtp.mailtrap.io): " SMTP_HOST
read -rp "SMTP_PORT (boş bırakılırsa: 587): " INPUT_SMTP_PORT
SMTP_PORT="${INPUT_SMTP_PORT:-587}"
read -rp "SMTP_USERNAME: " SMTP_USERNAME
read -rsp "SMTP_PASSWORD: " SMTP_PASSWORD
echo
read -rp "EMAIL_FROM_NAME (örn: Mattermost): " EMAIL_FROM_NAME

# --------------------------------------------------
# .env Güncelle
# --------------------------------------------------
set_env MATTERMOST_SERVER_HOSTNAME "$MATTERMOST_SERVER_HOSTNAME"

set_env SMTP_HOST      "$SMTP_HOST"
set_env SMTP_PORT      "$SMTP_PORT"
set_env SMTP_USERNAME  "$SMTP_USERNAME"
set_env SMTP_PASSWORD  "$SMTP_PASSWORD"
set_env EMAIL_FROM_NAME "$EMAIL_FROM_NAME"

set_env_once DATABASE_PASSWORD "$(gen_password)"

DATABASE_PASSWORD=$(grep "^DATABASE_PASSWORD=" "$ENV_FILE" | cut -d'=' -f2-)

# --------------------------------------------------
# Sonuçları Göster
# --------------------------------------------------
echo
echo "==============================================="
echo "✅ Mattermost .env başarıyla hazırlandı"
echo "-----------------------------------------------"
echo "🌐 Hostname      : $MATTERMOST_SERVER_HOSTNAME"
echo "📧 SMTP Host     : $SMTP_HOST:$SMTP_PORT"
echo "📧 SMTP Kullanıcı: $SMTP_USERNAME"
echo "🔑 DB Şifresi    : $DATABASE_PASSWORD"
echo "-----------------------------------------------"
echo "⚠️  Şifreyi güvenli bir yerde saklayın!"
echo "==============================================="
