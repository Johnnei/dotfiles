#!/bin/bash
set -e
set -u
set -o pipefail

XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-~/.config}
XDG_DATA_HOME=${XDG_DATA_HOME:-~/.local/share}

# Install nvim config
mkdir -vp $XDG_CONFIG_HOME/nvim
ln --symbolic --force --verbose $PWD/nvim/init.lua $XDG_CONFIG_HOME/nvim/init.lua
ln --symbolic --force --verbose $PWD/nvim/lazy-lock.json $XDG_CONFIG_HOME/nvim/lazy-lock.json
ln --symbolic --force --no-target-directory --verbose $PWD/nvim/lua $XDG_CONFIG_HOME/nvim/lua

# Install generic .profile
if [[ -e ~/.bashrc ]]; then
	SHELL_PROFILE=~/.bashrc
else
	SHELL_PROFILE=~/.profile
fi

DOT_PROFILE_PATH=$PWD/.profile

echo "Adding $DOT_PROFILE_PATH to $SHELL_PROFILE"
grep -qxF "source $DOT_PROFILE_PATH" "$SHELL_PROFILE" || echo "source $DOT_PROFILE_PATH" >> $SHELL_PROFILE
