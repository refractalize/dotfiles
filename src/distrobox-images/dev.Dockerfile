FROM registry.fedoraproject.org/fedora-toolbox:40

RUN mkdir -p /build

WORKDIR /build

COPY ./install.d /build/install.d

RUN for script in install.d/*.sh; do bash -e $script; done

RUN dnf -y copr enable atim/starship && dnf install -y starship

RUN dnf install -y \
  neovim \
  fzf \
  direnv \
  ripgrep \
  jq \
  kitty \
  kitty-terminfo \
  git-delta \
  fd-find \
  git-credential-libsecret \
  hyperfine \
  git-lfs \
  httpie \
  zsh

# mkcert
RUN dnf install -y nss-tools \
  && curl -JLO "https://dl.filippo.io/mkcert/latest?for=linux/amd64" \
  && chmod +x mkcert-v*-linux-amd64 \
  && sudo cp mkcert-v*-linux-amd64 /usr/local/bin/mkcert \
  && mkcert -install
# we also need to write this to a directory that python will look for

# cvat + SAM
RUN curl -s https://api.github.com/repos/nuclio/nuclio/releases/latest \
  | grep -i "browser_download_url.*nuctl.*$(uname)-amd64" \
  | cut -d : -f 2,3 \
  | tr -d \" \
  | wget -O nuctl -qi - \
  && chmod +x nuctl \
  && sudo mv nuctl /usr/local/bin
  
# docker
RUN dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
RUN dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# dive
RUN DIVE_VERSION=$(curl -sL "https://api.github.com/repos/wagoodman/dive/releases/latest" | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/') \
  && curl -OL https://github.com/wagoodman/dive/releases/download/v${DIVE_VERSION}/dive_${DIVE_VERSION}_linux_amd64.rpm \
  && rpm -i dive_${DIVE_VERSION}_linux_amd64.rpm

# RUN cargo install bkt

RUN ln -s /usr/bin/distrobox-host-exec /usr/local/bin/podman
RUN ln -s /usr/bin/distrobox-host-exec /usr/local/bin/kitty
# open URLs in default browser
RUN ln -s /usr/bin/distrobox-host-exec /usr/local/bin/xdg-open

RUN curl https://github.com/git-ecosystem/git-credential-manager/releases/download/v2.4.1/gcm-linux_amd64.2.4.1.tar.gz -L > gcm.tar.gz
RUN tar -xf gcm.tar.gz -C /usr/local/bin

# pyenv dependencies
RUN dnf install -y make gcc patch zlib-devel bzip2 bzip2-devel readline-devel sqlite sqlite-devel openssl-devel tk-devel libffi-devel xz-devel libuuid-devel gdbm-libs libnsl2
RUN dnf install -y pipx

# cuda: https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#network-repo-installation-for-fedora
RUN dnf config-manager --add-repo https://developer.download.nvidia.com/compute/cuda/repos/fedora39/x86_64/cuda-fedora39.repo
RUN dnf -y install cuda-toolkit-12-4
RUN dnf module install -y nvidia-driver:latest-dkms

# dotnet
# RUN sudo dnf config-manager --add-repo https://packages.microsoft.com/config/fedora/40/prod.repo
RUN dnf install -y dotnet-sdk-8.0 azure-cli
# ENV DOTNET_ROOT=/usr/share/dotnet
RUN curl https://go.microsoft.com/fwlink/?linkid=2261574 -L > azuredatastudio.rpm
RUN dnf install -y azuredatastudio.rpm
RUN rm azuredatastudio.rpm

RUN curl https://aka.ms/downloadazcopy-v10-linux -L -o azcopy.tar.gz
RUN tar -xf azcopy.tar.gz -C /usr/local/bin '*/azcopy' --strip-components 1 && chmod a+x /usr/local/bin/azcopy
RUN rm azcopy.tar.gz

RUN curl https://github.com/microsoft/go-sqlcmd/releases/download/v1.6.0/sqlcmd-v1.6.0-linux-x64.tar.bz2 -L -o sqlcmd.tar.bz2
RUN tar --extract -f sqlcmd.tar.bz2 -C /usr/local/bin sqlcmd
RUN rm sqlcmd.tar.bz2

RUN rpm --import https://packages.microsoft.com/keys/microsoft.asc
RUN sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
RUN dnf install -y code

RUN curl https://github.com/Samsung/netcoredbg/releases/download/3.1.0-1031/netcoredbg-linux-amd64.tar.gz -L -o netcoredbg.tar.gz
RUN tar --extract -f netcoredbg.tar.gz -C /usr/local/bin --strip-components 1
RUN rm netcoredbg.tar.gz

RUN dotnet tool install --global microsoft.sqlpackage
RUN dotnet tool install --global dotnet-ef

RUN curl https://releases.yaak.app/releases/2024.9.0-beta.3/yaak-2024.9.0-beta.3-1.x86_64.rpm -L -o yaak.rpm
RUN dnf install -y yaak.rpm
RUN rm yaak.rpm
