# dde-nixos

This project is dedicated to packaging DDE for NixOS

It's still in the early stages, see [Packaging Progress](https://github.com/linuxdeepin/dde-nixos/projects/1)

## Build in NixOS

### Build 

```bash
git clone git@github.com:linuxdeepin/dde-nixos.git
cd dde-nixos
nix-build -A deepin-calculator
# check result dir
```

### Install (nix-user)

```bash
nix-env -iA -f. deepin-calculator
```

### Test Build

```bash
nix-shell -A deepin-calculator
git clone git@github.com:linuxdeepin/deepin-calculator.git
git checkout 5.7.16
... # maintenance code
mkdir build
cd build
cmake ..
make
```

## Build in Non-NixOS System

### Install Nix

[Multi-user installation (recommended)](https://nixos.org/download.html#nix-install-linux)

```bash
sh <(curl -L https://nixos.org/nix/install) --daemon
```
Then you can use `nix-build` as you would on NixOS
