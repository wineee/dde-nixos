{ stdenv
, lib
, fetchFromGitHub
, dtkwidget
, qt5integration
, qt5platform-plugins
, qmake
, pkg-config
, qtbase
, qttools
, qtx11extras
, wrapQtAppsHook
, mtools
, p7zip
, udisks
, util-linux
, coreutils
, syslinux
, gtest
}:

stdenv.mkDerivation rec {
  pname = "deepin-boot-maker";
  version = "5.7.8";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-Ks35LDZrldilCRu+U41n2b03vFpqgIaJSvKqphzp6gM=";
  };

  patches = [ ./0001-fix-path-for-nixos.patch ];

  postPatch = ''
    substituteInPlace src/src.pro deepin-boot-maker.pro \
      --replace "/usr/share" "$out/share"

    substituteInPlace src/service/data/com.deepin.bootmaker.service \
      --replace "/usr/lib/deepin-daemon" "$out/lib/deepin-daemon"

    substituteInPlace src/vendor/src/libxsys/DiskUtil/Syslinux.cpp \
      --replace "/usr/lib/syslinux" "${syslinux}/lib/syslinux" \
      --replace "/usr/share/syslinux" "${syslinux}/share/syslinux"
  '';

  nativeBuildInputs = [
    qmake
    qttools
    pkg-config
    wrapQtAppsHook
  ];

  buildInputs = [
    dtkwidget
    qt5platform-plugins
    qtx11extras
    mtools
    p7zip
    syslinux
    gtest
  ];

  #qmakeFlags = [
  #  "PREFIX=${placeholder "out"}"
  #];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/${qtbase.qtPluginPrefix}"
    "--prefix PATH : ${lib.makeBinPath [ mtools p7zip udisks util-linux ]}"
  ];

  postFixup = ''
    wrapQtApp $out/lib/deepin-daemon/deepin-boot-maker-service
  '';

  meta = with lib; {
    description = "Tool to create a bootable usb stick quick and easy";
    homepage = "https://github.com/linuxdeepin/deepin-boot-maker";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
