FROM gitpod/openvscode-server:latest

ENV OPENVSCODE_SERVER_ROOT="/home/.openvscode-server"
ENV OPENVSCODE="${OPENVSCODE_SERVER_ROOT}/bin/openvscode-server"

SHELL ["/bin/bash", "-c"]

USER root

# Install dependencies
RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    wget \
    jq \
    tar \
    python3 \
    python3-pip \
    sudo \
    libatomic1 \
    && rm -rf /var/lib/apt/lists/*

# Fetch the latest version of Go and install it
RUN GO_VERSION=$(curl -sSL "https://golang.org/dl/?mode=json" | jq -r '.[0].files[] | select(.os == "linux" and .arch == "amd64") | .version' | sed 's/^go//') && \
    echo "🛠️ Installing Go version: $GO_VERSION" && \
    curl -fsSL "https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz" -o golang.tar.gz && \
    tar -C /usr/local -xzf golang.tar.gz && \
    rm golang.tar.gz && \
    echo "✅ Go version $GO_VERSION installed."

# Set Go environment variables and add Go binary to PATH
ENV GOROOT=/usr/local/go
ENV GOPATH=/go
ENV PATH=$PATH:$GOROOT/bin:$GOPATH/bin

# Ensure Go installation is available globally
RUN ln -s /usr/local/go/bin/go /usr/bin/go && \
    ln -s /usr/local/go/bin/gofmt /usr/bin/gofmt && \
    go version && \
    echo "✅ Go is installed and accessible globally."

# Create Go directories with correct permissions
RUN mkdir -p /go/src /go/bin && chmod -R 777 /go

# Fetch the latest Exercism CLI version dynamically
RUN EXERCISM_VERSION=$(curl -s https://api.github.com/repos/exercism/cli/releases/latest | jq -r .tag_name | sed 's/^v//') && \
    echo "🛠️ Installing Exercism CLI version: $EXERCISM_VERSION" && \
    curl -L "https://github.com/exercism/cli/releases/download/v${EXERCISM_VERSION}/exercism-${EXERCISM_VERSION}-linux-x86_64.tar.gz" -o exercism.tar.gz && \
    tar -xvzf exercism.tar.gz && \
    rm exercism.tar.gz && \
    mv exercism /usr/bin && \
    echo "✅ Exercism CLI version $EXERCISM_VERSION installed."

# DO NOT SET EXERCISM_TOKEN, GIT_USERNAME, GIT_EMAIL in ENV (They will be passed at runtime)
RUN mkdir -p /home/workspace

# Set alias for ll to work
RUN echo "alias ll='ls -la'" >> /etc/bash.bashrc

# Entry script for setting up Git and Exercism CLI at runtime
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# to restore permissions for the web interface
USER openvscode-server

# Default exposed port if none is specified
EXPOSE 3000
ENTRYPOINT ["/entrypoint.sh"]
