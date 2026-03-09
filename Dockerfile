FROM nvidia/cuda:13.1.1-devel-ubuntu24.04

# Installer dépendances communes + SSH
RUN apt-get update && apt-get install -y \
    openssh-server sudo wget unzip git build-essential \
    libssl-dev zlib1g-dev yasm pkg-config libgmp-dev \
    libbz2-dev libpcap-dev ocl-icd-opencl-dev clinfo p7zip-full \
    && mkdir /var/run/sshd \
    && rm -rf /var/lib/apt/lists/*

# User cracker UID 1001
RUN useradd -m -u 1001 -s /bin/bash cracker && \
    echo "cracker:password123" | chpasswd && \
    echo "cracker ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Installer Hashcat (dernière stable)
RUN cd /opt && \
    wget https://hashcat.net/files/hashcat-6.2.6.7z && \
    7z x hashcat-6.2.6.7z && \
    chmod +x hashcat-6.2.6/hashcat.bin && \
    ln -sf /opt/hashcat-6.2.6/hashcat.bin /usr/local/bin/hashcat

# Installer John the Ripper Jumbo (CUDA)
RUN cd /opt && \
    git clone https://github.com/openwall/john.git john-jumbo && \
    cd john-jumbo/src && \
    ./configure CUDA=found && \
    make -s clean && make -j$(nproc) && \
    ln -sf /opt/john-jumbo/run/john /usr/local/bin/john

# Config SSH bulletproof
RUN sed -i 's/#UsePAM yes/UsePAM no/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    mkdir -p /home/cracker/.ssh && chown -R cracker:cracker /home/cracker

USER cracker
WORKDIR /home/cracker
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
