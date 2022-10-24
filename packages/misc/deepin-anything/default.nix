{ stdenv
, lib
, fetchFromGitHub
, dtkcore
, qmake
, pkg-config
, udisks2-qt5
, util-linux
, libnl
, pcre
}:
stdenv.mkDerivation rec {
  pname = "deepin-anything";
  version = "unstable-2022-10-21";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "2d227f08400f65810312aa2bf607246bce18208d";
    sha256 = "sha256-ro+UyS3crPbtXg8JTHO/XnKZke/RBjZQH4NeRLfUFsg=";
  };

  outputs = [ "out" "server" "dkms" ];

  nativeBuildInputs = [
    qmake
    pkg-config
  ];

  buildInputs = [
    dtkcore
    udisks2-qt5
    util-linux
    libnl.dev
    pcre
  ];

  dontWrapQtApps = true;
  dontUseQmakeConfigure = true;

  postPatch = ''
    substituteInPlace server/backend/backend.pro \
      --replace '/usr/share/dbus-1/interfaces' '/share/dbus-1/interfaces' \
      --replace '/usr/include/libnl3' '${libnl.dev}/include/libnl3'
  '';

  buildPhase = ''
    sed 's|@@VERSION@@|${version}|g' debian/deepin-anything-dkms.dkms.in | tee debian/deepin-anything-dkms.dkms
    make -C library all
    (cd server 
      qmake -makefile -nocache QMAKE_STRIP=: PREFIX=/ LIB_INSTALL_DIR=/lib deepin-anything-backend.pro 
      make all
    )
  '';

  # FIXME out/usr/lib/modules-load.d/anything.conf ?
  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib
    cp library/bin/release/* $out/lib
    
    mkdir -p ${placeholder "dkms"}/src/deepin-anything-${version}
    cp -r kernelmod/* ${placeholder "dkms"}/src/deepin-anything-${version}
    mkdir -p ${placeholder "dkms"}/lib/modules-load.d
    echo "" | tee ${placeholder "dkms"}/lib/modules-load.d/anything.conf
    
    install -D debian/deepin-anything-dkms.dkms ${placeholder "dkms"}/src/deepin-anything-${version}/dkms.conf
    install -D debian/deepin-anything-libs.lintian-overrides $out/share/lintian/overrides/deepin-anything-libs

    mkdir -p $out/include/deepin-anything
    cp -r library/inc/* $out/include/deepin-anything
    cp -r kernelmod/vfs_genl.h  $out/include/deepin-anything
    cp -r kernelmod/vfs_change_consts.h $out/include/deepin-anything

    make -C server install INSTALL_ROOT=${placeholder "server"}
    runHook postInstall
  '';

  deepin_anything_backend_pc = ''
    prefix=${placeholder "server"}
    exec_prefix=''${prefix}
    libdir=''${prefix}/lib
    includedir=''${prefix}/include/deepin-anything-server-lib
    Name: deepin-anything-server-lib
    Description: Deepin anything backend library
    Version: ${version}
    Libs: -L''${libdir} -ldeepin-anything-server-lib
    Cflags: -I''${includedir}
  '';

  postInstall = ''
    mkdir -p ${placeholder "server"}/lib/pkg-config
    touch ${placeholder "server"}/lib/pkg-config/deepin-anything-server-lib.pc
    echo -e ${lib.strings.escapeShellArg deepin_anything_backend_pc} > ${placeholder "server"}/lib/pkg-config/deepin-anything-server-lib.pc
  '';

  dontFixup = true;

  meta = with lib; {
    description = "Deepin Anything file search tool";
    homepage = "https://github.com/linuxdeepin/deepin-anything";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    outputsToInstall = [ "out" "server" "dkms" ];
  };
}
