# dde-nixos

This project is dedicated to packaging DDE for NixOS 

[Packaging Progress](https://github.com/linuxdeepin/dde-nixos/projects/1)

## Build

```bash
nix build .#deepin-calculator -v -L
```

```bash
nix develop .#deepin-calculator
git clone git@github.com:linuxdeepin/deepin-calculator.git
git checkout 5.7.16
... # maintenance code
mkdir build
cd build
cmake ..
make
```

Still need time to complete nixos module，dont use this as flake input before completed.

## References
- [Status of packaging the Deepin Desktop Environment ](https://github.com/NixOS/nixpkgs/issues/94870)
- [Nix User Repository](https://github.com/nix-community/NUR)
- [nix-cutefish](https://github.com/p3psi-boo/nix-cutefish)

## License

MIT
