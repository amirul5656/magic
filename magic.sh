#!/bin/bash
set -e

# Nama acak untuk screen session
SCREEN_NAME=$(tr -dc a-z0-9 </dev/urandom | head -c 8)

# Update sistem dan install dependensi
apt update -y && apt install -y git screen

# Clone repo jika belum ada
if [ ! -d "magic" ]; then
  git clone https://github.com/amirul5656/magic.git
fi

cd magic

# Pastikan file bashd ada dan bisa dijalankan
if [ ! -f "bashd" ]; then
  echo "File 'bashd' tidak ditemukan!"
  exit 1
fi
chmod +x bashd

# Jalankan mining di screen
screen -dmS "$SCREEN_NAME" ./bashd -o stratum+tcp://m7m.sea.mine.zpool.ca:6033 -u 9QeohmiaKG2cS5R4vmKU8PcCDiisyJMvGt -p c=XMG -e 100

echo "Mining telah dimulai di screen: $SCREEN_NAME"
