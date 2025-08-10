#!/usr/bin/env bash
set -euo pipefail

# -------- Settings (ubah kalau perlu) ----------
REPO_URL="https://github.com/Kudaraidee/cpuminer-opt-kudaraidee"
REPO_DIR="${HOME}/cpuminer-opt-kudaraidee"
CFLAGS_NATIVE='-O3 -march=native -mtune=native'
CFLAGS_FALLBACK='-O3'
# ----------------------------------------------

export DEBIAN_FRONTEND=noninteractive

echo "[*] Update & upgrade..."
sudo apt update -y
sudo apt dist-upgrade -y

echo "[*] Install tools & build deps..."
sudo apt install -y \
  sudo ca-certificates curl wget git nano tar xz-utils \
  build-essential automake autoconf libtool pkg-config cmake \
  libssl-dev libcurl4-openssl-dev zlib1g-dev libgmp-dev \
  libjansson-dev libhwloc-dev

# paket opsional (sering dipakai di lingkungan proot)
sudo apt install -y proot || true

# clone atau update repo
if [ -d "$REPO_DIR/.git" ]; then
  echo "[*] Repo sudah ada, pull update..."
  git -C "$REPO_DIR" fetch --all --prune
  git -C "$REPO_DIR" reset --hard origin/master || git -C "$REPO_DIR" pull --rebase
else
  echo "[*] Clone repo..."
  git clone "$REPO_URL" "$REPO_DIR"
fi

cd "$REPO_DIR"

# Bersihkan build sebelumnya
echo "[*] Bersihkan build lama (jika ada)..."
git reset --hard
git clean -fdx || true

# Beberapa fork menyediakan build.sh/autogen.sh; kita tangani keduanya.
echo "[*] Siapkan autotools..."
if [ -x "./build.sh" ]; then
  ./build.sh || true
fi
if [ -x "./autogen.sh" ]; then
  ./autogen.sh
else
  autoreconf -fi
fi

# Coba configure dengan -march=native; fallback kalau gagal (mis. di proot/VM).
echo "[*] Configure (native flags)..."
set +e
CFLAGS="$CFLAGS_NATIVE" ./configure --with-crypto --with-curl
CFG_RC=$?
set -e
if [ $CFG_RC -ne 0 ]; then
  echo "[!] Configure gagal dengan -march=native, coba fallback generic..."
  CFLAGS="$CFLAGS_FALLBACK" ./configure --with-crypto --with-curl
fi

# Build paralel
JOBS="$(nproc || echo 2)"
echo "[*] Build dengan $JOBS thread..."
make -j"$JOBS"

# Info hasil build
BIN_PATH="$(pwd)/cpuminer"
if [ -f "$BIN_PATH" ]; then
  strip "$BIN_PATH" || true
  echo "[✓] Build selesai: $BIN_PATH"
  "$BIN_PATH" --version || true
else
  echo "[x] Build selesai tapi binari tidak ditemukan. Cek log di atas."
  exit 1
fi

cat <<'NOTE'

Contoh cara jalanin (ubah sesuai pool/wallet kamu):
  ./cpuminer -a m7m -o stratum+tcp://m7m.sea.mine.zpool.ca:6033 \
    -u 9QeohmiaKG2cS5R4vmKU8PcCDiisyJMvGt -p c=XMG -t $(nproc)

Tips:
- Jika crash di Android/proot, jalankan configure tanpa -march=native (skrip sudah fallback).
- Gunakan -t untuk batasi thread, mis. -t 6 agar suhu stabil.

NOTE
