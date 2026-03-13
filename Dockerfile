FROM nvidia/cuda:13.1.1-devel-ubuntu24.04

# Base + deps
RUN apt-get update && apt-get install -y \
    openssh-server sudo wget p7zip-full git build-essential openssl \
    libssl-dev zlib1g-dev yasm pkg-config libgmp-dev nano \
    libbz2-dev libpcap-dev ocl-icd-opencl-dev clinfo \
    libpam-modules libnss-files \
    && rm -rf /var/lib/apt/lists/*

# SSH DIRS + HOSTKEYS
RUN mkdir -p /var/run/sshd /var/log && \
    mknod -m 666 /dev/log p && \
    touch /var/log/auth.log && chmod 644 /var/log/auth.log && \
    rm -f /etc/ssh/ssh_host_*_key* && \
    ssh-keygen -A && \
    sed -i 's/#PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config

# KEX compat
RUN echo "KexAlgorithms curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256,diffie-hellman-group16-sha512" >> /etc/ssh/sshd_config

# User cracker
RUN useradd -m -u 1001 -s /bin/bash cracker && \
    echo "cracker ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    echo "cracker:password123" | chpasswd && \
    echo "root:password123" | chpasswd

# SSH PERMS
RUN chmod 755 /var/run/sshd && \
    chmod 600 /etc/ssh/ssh_host_*_key && \
    chmod 644 /etc/ssh/ssh_host_*_key.pub

# Hashcat
RUN cd /opt && wget https://hashcat.net/files/hashcat-7.1.2.7z && \
    7z x hashcat-7.1.2.7z && rm hashcat-7.1.2.7z && \
    chmod +x hashcat-7.1.2/hashcat.bin && \
    ln -sf /opt/hashcat-7.1.2/hashcat.bin /usr/local/bin/hashcat

# John Jumbo CUDA
RUN cd /opt && git clone https://github.com/openwall/john.git john-jumbo && \
    cd john-jumbo/src && ./configure CUDA=found && \
    make -s clean && make -j$(nproc) && \
    ln -sf /opt/john-jumbo/run/john /usr/local/bin/john

# Fix PERMS + Alias
RUN chown -R cracker:cracker /opt/ /home/cracker && \
    echo 'alias john="/opt/john-jumbo/run/john"' >> /home/cracker/.bashrc && \
    mkdir -p /home/cracker/.john && \
    echo "[Options]\nHomeDir = /opt/john-jumbo/run" > /home/cracker/.john/john.conf

USER root
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
