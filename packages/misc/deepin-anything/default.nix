{ stdenv
, lib
, fetchFromGitHub
, dtkcore
, qmake
, pkgconfig
, udisks2-qt5
, utillinux
, pcre
, breakpointHook
, tree
}:

stdenv.mkDerivation rec {
  pname = "deepin-anything";
  version = "6.0.0";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-1GX/gemRTMhP8ZixYzB3mwQrWonjEPNYWY6zutTnLqw=";
  };

  outputs = [ "out" "server" ];

  nativeBuildInputs = [
    qmake
    pkgconfig
    breakpointHook
    tree
  ];

  buildInputs = [
    dtkcore
    udisks2-qt5
    utillinux
    pcre
  ];

  dontWrapQtApps = true;
  dontUseQmakeConfigure = true;

  # TODO: sysusers
  fixServerPatch = ''
    substituteInPlace server/backend/backend.pro \
      --replace '/usr/share/dbus-1/interfaces' '/share/dbus-1/interfaces'
  '';

  postPatch = fixServerPatch;

  buildPhase = ''
    make -C library all
    cd server 
    qmake -makefile -nocache QMAKE_STRIP=: PREFIX=/ LIB_INSTALL_DIR=/lib deepin-anything-backend.pro 
    make all
    cd ..
  '';

  # FIXME out/usr/lib/modules-load.d/anything.conf ?
  installPhase = ''
    mkdir -p $out/lib
    cp library/bin/release/* $out/lib
    
    mkdir -p $out/src/deepin-anything-${version}
    cp -r kernelmod/* $out/src/deepin-anything-${version}
    mkdir -p $out/lib/modules-load.d
    echo "" | tee $out/lib/modules-load.d/anything.conf
    mkdir -p $out/include/deepin-anything
    cp -r library/inc/* $out/include/deepin-anything
    cp -r kernelmod/vfs_change_uapi.h $out/include/deepin-anything
    cp -r kernelmod/vfs_change_consts.h $out/include/deepin-anything

    make -C server install INSTALL_ROOT=${placeholder "server"}
  '';

  dontFixup = true;

  meta = with lib; {
    description = "Deepin Anything file search tool";
    homepage = "https://github.com/linuxdeepin/deepin-anything";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    outputsToInstall = [ "out" "server" ];
  };
}
