#!/bin/bash

# Display Go version
if command -v go &> /dev/null; then
    echo "✅ Go installed: $(go version)"
else
    echo "❌ Go is NOT installed!"
fi

# Display Exercism version
if command -v exercism &> /dev/null; then
    echo "✅ Exercism CLI installed: $(exercism version)"
else
    echo "❌ Exercism CLI is NOT installed!"
fi

# Configure Git (only if variables are set)
if [ -n "$GIT_USERNAME" ] && [ -n "$GIT_EMAIL" ]; then
    git config --global user.name "$GIT_USERNAME"
    git config --global user.email "$GIT_EMAIL"
    echo "✅ Git configured with user: $GIT_USERNAME <$GIT_EMAIL>"
else
    echo "⚠️ Git credentials not provided, skipping Git configuration."
fi

# Configure Exercism CLI (only if variables are set)
if [ -n "$EXERCISM_TOKEN" ] && [ -n "$EXERCISM_WORKSPACE" ]; then
    exercism configure --token="$EXERCISM_TOKEN" --workspace="$EXERCISM_WORKSPACE"
    echo "✅ Exercism CLI configured with workspace: $EXERCISM_WORKSPACE"
else
    echo "⚠️ Exercism token or workspace not provided, skipping Exercism configuration."
fi

# Start OpenVSCode Server
exec /home/gitpod/openvscode-server/bin/openvscode-server --host 0.0.0.0
