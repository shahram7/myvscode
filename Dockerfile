FROM gitpod/openvscode-server:latest

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
    && rm -rf /var/lib/apt/lists/*

# Fetch the latest version of Go and install it
RUN curl -sSL "https://golang.org/dl/?mode=json" | jq -r '.[0].files[] | select(.os == "linux" and .arch == "amd64") | .version' | sed 's/^go//' | xargs -I {} sh -c \
    'curl -fsSL "https://golang.org/dl/go{}.linux-amd64.tar.gz" -o golang.tar.gz && \
     tar -C /usr/local -xzf golang.tar.gz && \
     rm golang.tar.gz'

# Set Go environment variables
ENV GOROOT=/usr/local/go
ENV GOPATH=/go
ENV PATH=$PATH:$GOROOT/bin:$GOPATH/bin

# Create Go directories with correct permissions
RUN mkdir -p /go/src /go/bin && chmod -R 777 /go

# Fetch the latest Exercism CLI version dynamically
RUN export EXERCISM_VERSION=$(curl -s https://api.github.com/repos/exercism/cli/releases/latest | jq -r .tag_name | sed 's/^v//') && \
    curl -L "https://github.com/exercism/cli/releases/download/v${EXERCISM_VERSION}/exercism-${EXERCISM_VERSION}-linux-x86_64.tar.gz" -o exercism.tar.gz && \
    tar -xvzf exercism.tar.gz && \
    rm exercism.tar.gz && \
    mv exercism /usr/bin

# DO NOT SET EXERCISM_TOKEN, GIT_USERNAME, GIT_EMAIL in ENV (They will be passed at runtime)
RUN mkdir -p /home/workspace

# Entry script for setting up Git and Exercism CLI at runtime
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]
