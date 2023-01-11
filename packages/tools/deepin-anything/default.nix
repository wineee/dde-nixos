{ stdenv
, lib
, fetchFromGitHub
, getUsrPatchFrom
, dtkcore
, qmake
, pkg-config
, wrapQtAppsHook
, udisks2-qt5
, util-linux
, libnl
, pcre
}:
stdenv.mkDerivation rec {
  pname = "deepin-anything";
  version = "5.0.18";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-md1ITvzzH19VRWoYCAr81BmftT5/oXAcz0gzenjM5/A=";
  };

  outputs = [ "out" "modsrc" ];

  nativeBuildInputs = [
    qmake
    pkg-config
    wrapQtAppsHook
  ];

  buildInputs = [
    dtkcore
    udisks2-qt5
    util-linux
    libnl.dev
    pcre
  ];

  #dontWrapQtApps = true;
  dontUseQmakeConfigure = true;

  postPatch = getUsrPatchFrom {
    "server/tool/tool.pro" = [
      [ "/usr/share/dbus-1" "/share/dbus-1" ]
    ];
    "server/monitor/deepin-anything-monitor.service" = [ ];
    "server/tool/com.deepin.anything.service" = [ ];
    "server/tool/deepin-anything-tool.service" = [ ];
  };

  buildPhase = ''
    sed 's|@@VERSION@@|${version}|g' debian/deepin-anything-dkms.dkms.in | tee debian/deepin-anything-dkms.dkms
    make -C library all
    (cd server 
      qmake -makefile -nocache QMAKE_STRIP=: PREFIX=/ LIB_INSTALL_DIR=/lib deepin-anything-server.pro 
      make all
    )
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/lib
    cp library/bin/release/* $out/lib
    
    mkdir -p ${placeholder "modsrc"}/src/deepin-anything-${version}
    cp -r kernelmod/* ${placeholder "modsrc"}/src/deepin-anything-${version}
    mkdir -p ${placeholder "modsrc"}/lib/modules-load.d
    echo "" | tee ${placeholder "modsrc"}/lib/modules-load.d/anything.conf
    
    install -D debian/deepin-anything-dkms.dkms ${placeholder "modsrc"}/src/deepin-anything-${version}/dkms.conf
    install -D debian/deepin-anything-libs.lintian-overrides $out/share/lintian/overrides/deepin-anything-libs

    mkdir -p $out/include/deepin-anything
    cp -r library/inc/* $out/include/deepin-anything
    cp -r kernelmod/vfs_change_uapi.h  $out/include/deepin-anything
    cp -r kernelmod/vfs_change_consts.h $out/include/deepin-anything

    make -C server install INSTALL_ROOT=$out
    runHook postInstall
  '';

  deepin_anything_backend_pc = ''
    prefix=${placeholder "out"}
    exec_prefix=''${prefix}
    libdir=''${prefix}/lib
    includedir=''${prefix}/include/deepin-anything-server
    Name: deepin-anything-server-lib
    Description: Deepin anything backend library
    Version: ${version}
    Libs: -L''${libdir} -ldeepin-anything-server-lib
    Cflags: -I''${includedir}
  '';

  postInstall = ''
    echo ${lib.strings.escapeShellArg deepin_anything_backend_pc} > $out/lib/pkgconfig/deepin-anything-server-lib.pc
  '';

  # dontFixup = true;

  meta = with lib; {
    description = "Deepin Anything file search tool";
    homepage = "https://github.com/linuxdeepin/deepin-anything";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    outputsToInstall = [ "out" ];
  };
}
