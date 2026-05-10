My personal preferences in several applications

# Installation

## Dependencies

Install the following tools:

Arch:
```bash
sudo pacman -S --needed noto-fonts noto-fonts-cjk noto-fonts-emoji ttf-jetbrains-mono-nerd ripgrep cargo-nextest stow hyprland archlinux-xdg-menu
```

MacOS:
```bash
brew tap homebrew/cask-fonts
brew install --cask font-jetbrains-mono-nerd-font
brew install ripgrep
brew install cargo-nextest
```

## Stow it

```bash
# If using company devices, only base is common across all my setups
stow base

# Configure off-work identity and networking settings
stow personal

# Enable device specific configuration
stow <bkk/ayu>
```

