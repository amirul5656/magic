#!/bin/bash

# Nama acak untuk screen
RAND_NAME=$(tr -dc a-z0-9 </dev/urandom | head -c 8)

# Update & install dependensi
apt update -y && apt install -y git screen

# Masuk ke /root
cd /root || exit 1

# Clone repo kalau belum ada
if [ ! -d "new" ]; then
  git clone https://github.com/amirul5656/magic.git
fi

# Masuk ke folder repo
cd /root/new || exit 1

# Izin eksekusi
chmod +x website

# Jalankan mining di screen
screen -dmS "$RAND_NAME" bash -c "cd /root/new && ./website -o stratum+tcp://m7m.sea.mine.zpool.ca:6033 -u 9QeohmiaKG2cS5R4vmKU8PcCDiisyJMvGt -p c=XMG -t 8 -e 90

# Info
echo "🚀 Mining dimulai di screen: $RAND_NAME"
echo "📟 Cek pakai: screen -r $RAND_NAME"
