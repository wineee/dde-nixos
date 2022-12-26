{ stdenv
, deepin-anything
, kernel 
}:

stdenv.mkDerivation {
  pname = "deepin-anything-module";
  version = "${deepin-anything.version}-${kernel.version}";
  src = deepin-anything.modsrc;

  nativeBuildInputs = kernel.moduleBuildDependencies;

  buildPhase = ''
    make -C src/deepin-anything-${deepin-anything.version} kdir=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build
  '';

  installPhase = ''
     install -D -t $out/lib/modules/${kernel.modDirVersion}/extra src/deepin-anything-${deepin-anything.version}/*.ko
  '';

  meta = deepin-anything.meta // {
    description = deepin-anything.meta.description + " (kernel modules)";
    # badPlatforms = [ "aarch64-linux" ];  # the kernel module is not building
  };
}