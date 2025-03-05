FROM gitpod/openvscode-server:latest

USER root

# Set environment variables
ENV EXERCISM_TOKEN=${EXERCISM_TOKEN}
ENV EXERCISM_WORKSPACE=${EXERCISM_WORKSPACE}
ENV GOROOT=/usr/local/go
ENV GOPATH=/go
ENV PATH=$PATH:$GOROOT/bin:$GOPATH/bin
ARG GIT_USERNAME
ARG GIT_EMAIL
ENV GIT_USERNAME=${GIT_USERNAME}
ENV GIT_EMAIL=${GIT_EMAIL}

# Install dependencies: curl, wget, tar, python3, python3-pip, ca-certificates, jq
RUN apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    wget \
    jq \
    tar \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Fetch the latest version of Go, download, and install
RUN curl -sSL "https://golang.org/dl/?mode=json" | jq -r '.[0].files[] | select(.os == "linux" and .arch == "amd64") | .version' | sed 's/^go//' | xargs -I {} sh -c \
    'curl -fsSL "https://golang.org/dl/go{}.linux-amd64.tar.gz" -o golang.tar.gz && \
     tar -C /usr/local -xzf golang.tar.gz && \
     rm golang.tar.gz'


RUN mkdir -p /go/src /go/bin && \
    chmod -R 777 /go

# Fetch the latest Exercism CLI version dynamically
RUN EXERCISM_VERSION=$(curl -s https://api.github.com/repos/exercism/cli/releases/latest | jq -r .tag_name | sed 's/^v//') && \
    curl -L "https://github.com/exercism/cli/releases/download/v${EXERCISM_VERSION}/exercism-${EXERCISM_VERSION}-linux-x86_64.tar.gz" -o exercism.tar.gz && \
    tar -xvzf exercism.tar.gz && \
    rm exercism.tar.gz && \
    mv exercism /usr/bin

# DO NOT SET EXERCISM_TOKEN, GIT_USERNAME, GIT_EMAIL in ENV
# They will be passed at runtime instead

# Create workspace directory
RUN mkdir -p /home/workspace

# Set Git config and Exercism CLI token at runtime
CMD git config --global user.name "$GIT_USERNAME" && \
    git config --global user.email "$GIT_EMAIL" && \
    exercism configure --token "$EXERCISM_TOKEN" --workspace /home/workspace && \
    exec /entrypoint.sh
