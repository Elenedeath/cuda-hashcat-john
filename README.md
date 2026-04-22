# CUDA Hashcat + John Ripper + SSH | TrueNAS SCALE Ready
**GPU Cracking** for TrueNAS SCALE / Docker !

## 💥 Features
- ✅ **Hashcat 7.1.2** CUDA backend (29 GH/s MD5 sur RTX 2070S)
- ✅ **John Jumbo** CUDA compilé
- ✅ **SSH sécurisé** (cracker/password123)
- ✅ NVIDIA CUDA 12.4.1-devel Ubuntu 22.04
- ✅ Volume persistant `/home/cracker/data` (hashes/wordlists)
- ✅ OpenCL fallback (ignore warning)
- ✅ Generate SSH keys when building image

**29 GH/s MD5** (RTX 2070S) | Hashcat 7.1.2 + John Jumbo + SSH | TrueNAS SCALE Ready

## 🔥 Benchmarks Hashcat
| Mode | Type | RTX 2070 SUPER | RTX A2000 + Quadro RTX 4000
|------|------|-------|-------|
| 0 | MD5 | **29.0 GH/s** | **35 GH/s** |
| 1000 | NTLM | **51 GH/s** | **67.1 GH/s** |
| 22000 | WPA | **453 kH/s** | **570.5 kH/s** |
| 5600 | NetNTLMv2 | 2.05 GH/s | 2.51 GH/s |
| 1700 | SHA2-512 | 1.31 GH/s | 1.74 GH/s |

## 🐳 TrueNAS SCALE YAML
```
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
## 🚀 **Quickstart Docker**
```
docker run -d --gpus all -p 2222:22 -v ./data:/home/cracker/data hikage/cuda-hashcat-john
ssh cracker@localhost -p 2222  # password123
hashcat -b -w 3  # Benchmark
```
