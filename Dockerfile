FROM nvidia/cuda:13.1.1-devel-ubuntu24.04

# Install dependencies + SSH
RUN apt-get update && apt-get install -y \
    openssh-server sudo wget p7zip-full git build-essential \
    libssl-dev zlib1g-dev yasm pkg-config libgmp-dev \
    libbz2-dev libpcap-dev ocl-icd-opencl-dev clinfo openssl \
    && rm -rf /var/lib/apt/lists/*

# GENÈRE HOSTKEYS SSH (fix crash!)
RUN rm -f /etc/ssh/ssh_host_*_key* && \
    yes | ssh-keygen -A && \
    mkdir -p /var/run/sshd

# User + mdp bulletproof
RUN useradd -m -u 1001 -s /bin/bash cracker && \
    usermod -p '$(openssl passwd -1 password123)' cracker && \
    echo "cracker ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Install Hashcat (latest stable)
RUN cd /opt && wget https://hashcat.net/files/hashcat-6.2.6.7z && \
    7z x hashcat-6.2.6.7z && chmod +x hashcat-6.2.6/hashcat.bin && \
    ln -sf /opt/hashcat-6.2.6/hashcat.bin /usr/local/bin/hashcat

# Install John the Ripper Jumbo (CUDA)
RUN cd /opt && git clone https://github.com/openwall/john.git john-jumbo && \
    cd john-jumbo/src && ./configure CUDA=found && \
    make -s clean && make -j$(nproc) && \
    ln -sf /opt/john-jumbo/run/john /usr/local/bin/john

# Config SSHD bulletproof
RUN sed -i 's/#UsePAM yes/UsePAM no/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

USER cracker
WORKDIR /home/cracker
EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
