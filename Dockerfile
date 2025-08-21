# -----------------------------
# Base image
# -----------------------------
FROM debian:bookworm

# -----------------------------
# Install basic packages
# -----------------------------
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        bash \
        wget \
        curl \
        gnupg2 \
        ca-certificates \
        lsb-release \
        sudo \
        nano \
        git \
        unzip \
        npm \
        ssh \
        iputils-ping \
        iptables \
        uidmap && \
    rm -rf /var/lib/apt/lists/*

# -----------------------------
# Install Visual Studio Code
# -----------------------------
RUN wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | \
    gpg --dearmor | tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null && \
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/code stable main" | \
    tee /etc/apt/sources.list.d/vscode.list && \
    apt-get update && \
    apt-get install -y code && \
    rm -rf /var/lib/apt/lists/*

# -----------------------------
# Install Docker Engine + CLI + Compose v2
# -----------------------------
RUN install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    chmod a+r /etc/apt/keyrings/docker.gpg && \
    echo \
      "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
      $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-buildx-plugin \
        docker-compose-plugin && \
    rm -rf /var/lib/apt/lists/*

# -----------------------------
# Copy start.sh to the container
# -----------------------------
COPY start.sh /app/start.sh
RUN chmod +x /app/start.sh

# -----------------------------
# Create a non-root user
# -----------------------------
RUN useradd -m -s /bin/bash vscodeuser && \
    echo 'vscodeuser ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/vscodeuser && \
    chmod 0444 /etc/sudoers.d/vscodeuser && \
    usermod -aG sudo vscodeuser && \
    usermod -aG docker vscodeuser

# Switch to the non-root user
USER vscodeuser
ENV HOME=/home/vscodeuser

# -----------------------------
# Start Docker Daemon + Custom Entrypoint
# -----------------------------
ENTRYPOINT ["bash", "/app/start.sh"]
