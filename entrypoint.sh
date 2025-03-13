#!/bin/bash
set -e

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

if [ -n "$SETTINGS_JSON_PATH" ]; then
    mkdir -p "$DEFAULT_WORKSPACE/.openvscode-server/data/Machine"
    cp "$SETTINGS_JSON_PATH"/settings.json "$DEFAULT_WORKSPACE"/.openvscode-server/data/Machine/settings.json
    cp "$SETTINGS_JSON_PATH"/keybindings.json "$DEFAULT_WORKSPACE"/.openvscode-server/data/Machine/keybindings.json
    cp "$SETTINGS_JSON_PATH"/settings.json /home/workspace/.openvscode-server/data/Machine/settings.json
    cp "$SETTINGS_JSON_PATH"/keybindings.json /home/workspace/.openvscode-server/data/Machine/keybindings.json
fi
