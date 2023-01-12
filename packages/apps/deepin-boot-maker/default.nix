{ stdenv
, lib
, fetchFromGitHub
, dtk
, qmake
, pkg-config
, qtbase
, qttools
, qtx11extras
, wrapQtAppsHook
, qt5integration
, mtools
, p7zip
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

  postPatch = ''
    substituteInPlace src/src.pro \
      --replace "/usr/share/deepin-boot-maker/translations" "$out/share/deepin-boot-maker/translations"
    substituteInPlace deepin-boot-maker.pro \
      --replace "/usr/share/deepin-manual/manual-assets/application" "$out/share/deepin-manual/manual-assets/application"
    
    substituteInPlace src/service/data/com.deepin.bootmaker.service \
      --replace "/usr/lib/deepin-daemon/deepin-boot-maker-service" "/run/current-system/sw/lib/deepin-daemon/deepin-boot-maker-service"
  '';

  nativeBuildInputs = [
    qmake
    qttools
    pkg-config
    wrapQtAppsHook
  ];

  buildInputs = [
    dtk
    qtx11extras
    mtools
    p7zip
    syslinux
    gtest
  ];

  qmakeFlags = [
    "PREFIX=${placeholder "out"}"
  ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/${qtbase.qtPluginPrefix}"
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
