# CUDA Hashcat + John Ripper + SSH + bkcrack | TrueNAS SCALE Ready
**GPU Cracking** for TrueNAS SCALE / Docker !

## 💥 Features
- ✅ **Hashcat 7.1.2** CUDA backend (29 GH/s MD5 on RTX 2070S)
- ✅ **John Jumbo** compiled with CUDA support
- ✅ **bkcrack 1.8.1** ZipCrypto known-plaintext attack
- ✅ **zopfli** Deflate compression matching
- ✅ **SSH** access (cracker/password123)
- ✅ NVIDIA CUDA 12.4.1-devel Ubuntu 22.04
- ✅ Persistent volume `/home/cracker/data` (hashes/wordlists)
- ✅ OpenCL fallback (ignore warning)
- ✅ SSH keys generated at build time

> ⚠️ **Security Warning** : SSH is exposed with a default password. **Do not expose port 2222 to the internet.** Use only on a trusted local network. Change the default password after first login: `passwd cracker`

## 🔥 Hashcat Benchmarks
| Mode | Type | RTX 2070 SUPER | RTX A2000 + Quadro RTX 4000
|------|------|-------|-------|
| 0 | MD5 | **29.0 GH/s** | **35 GH/s** |
| 1000 | NTLM | **51 GH/s** | **67.1 GH/s** |
| 22000 | WPA | **453 kH/s** | **570.5 kH/s** |
| 5600 | NetNTLMv2 | 2.05 GH/s | 2.51 GH/s |
| 1700 | SHA2-512 | 1.31 GH/s | 1.74 GH/s |

## 🐳 TrueNAS SCALE YAML
```yaml
services:
  cuda-hashcat:
    image: hikage/cuda-hashcat-john:latest
    container_name: cuda-hashcat
    runtime: nvidia
    environment:
      - NVIDIA_VISIBLE_DEVICES=all
      - NVIDIA_DRIVER_CAPABILITIES=all,compute,utility
    ports:
      - "2222:22"
    volumes:
      - /mnt/.ix-apps/app_mounts/cuda-hashcat-john/hashes:/home/cracker/data  # Your ZFS pool
    restart: unless-stopped
x-notes: >
  # cuda-hashcat-john

  **Source** :
  [https://github.com/Elenedeath/cuda-hashcat-john](https://github.com/Elenedeath/cuda-hashcat-john)


  **Image Docker** : hikage/cuda-hashcat-john:latest

  ## Security


  **Read the following security precautions to ensure that you wish to continue
  using this application.**

  ---

  ## Bug Reports and Feature Requests


  If you find a bug in this app or have an idea for a new feature, please file
  an issue at

  https://github.com/Elenedeath/cuda-hashcat-john
```

## 🚀 Quickstart Docker
```bash
docker run -d --gpus all -p 2222:22 \
  -v ./data:/home/cracker/data \
  hikage/cuda-hashcat-john:latest

ssh cracker@localhost -p 2222  # password: password123
hashcat -b -w 3                # GPU Benchmark
```

## 🔓 bkcrack — ZipCrypto Known-Plaintext Attack
```bash
# List contents of an encrypted ZIP
bkcrack -C archive.zip

# Known-plaintext attack (requires at least 12 known plaintext bytes)
bkcrack -C archive.zip -c file.stl -P plain.zip -p file.stl -j $(nproc)

# Decrypt with recovered keys
bkcrack -C archive.zip -k KEY0 KEY1 KEY2 -D decrypted.zip

# Attempt password recovery from keys
bkcrack -k KEY0 KEY1 KEY2 --bruteforce '?a' --length 0..12 -j $(nproc)
```

## 🔧 Build from Source
```bash
git clone https://github.com/Elenedeath/cuda-hashcat-john.git
cd cuda-hashcat-john
docker build --no-cache -t hikage/cuda-hashcat-john:latest .
docker push hikage/cuda-hashcat-john:latest
```

## 🔗 Links
- [bkcrack](https://github.com/kimci86/bkcrack)
- [hashcat](https://hashcat.net)
- [John Jumbo](https://github.com/openwall/john)
- [zopfli](https://github.com/google/zopfli)