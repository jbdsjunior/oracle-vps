FROM quay.io/fedora/fedora-bootc:latest

# 1. Instalar pacotes essenciais do host (Rede, VPN, Utilidades)
RUN dnf install -y \
    wireguard-tools \
    tailscale \
    podman \
    iptables \
    nftables \
    curl \
    wget \
    htop \
    nano \
    tar \
    git \
    systemd-resolved && \
    dnf clean all

# 2. Configurações de Sysctl do Kernel (Forwarding e BBR para VPNs)
COPY config/network/99-ip-forward.conf /etc/sysctl.d/99-ip-forward.conf

# 3. Podman Quadlets (Containers gerenciados nativamente pelo systemd)
COPY config/containers/ /etc/containers/systemd/

# 4. Timer e Serviço de Auto-Update do SO (bootc)
COPY config/systemd/bootc-update.service /etc/systemd/system/bootc-update.service
COPY config/systemd/bootc-update.timer /etc/systemd/system/bootc-update.timer

# 5. Habilitar serviços essenciais do systemd
RUN systemctl enable tailscaled.service && \
    systemctl enable podman.socket && \
    systemctl enable podman-auto-update.timer && \
    systemctl enable bootc-update.timer

# 6. Criar diretórios de persistência de dados de containers
RUN mkdir -p /var/lib/adguardhome/work /var/lib/adguardhome/conf

