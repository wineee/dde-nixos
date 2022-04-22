{
  description = "dde for nixos";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem ["x86_64-linux" "aarch64-linux"] (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        deepinPkgs = import ./packages { inherit pkgs; };
        deepin = flake-utils.lib.flattenTree deepinPkgs;
      in
      rec {
        defaultPackage = pkgs.stdenv.mkDerivation {
          name = "deepin-meta";
          buildInputs = nixpkgs.lib.attrsets.attrValues packages.deepin;
        };
        packages = deepin;
        devShells = builtins.mapAttrs (
          name: value: 
            pkgs.mkShell {
              nativeBuildInputs = deepin.${name}.nativeBuildInputs;
              buildInputs = deepin.${name}.buildInputs;
           }
        ) deepin;
      }
    );
}
