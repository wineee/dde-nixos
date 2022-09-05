{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, getPatchFrom
, dtk
, deepin-gettext-tools
, qt5integration
, qt5platform-plugins
, qmake
, qttools
, qtx11extras
, pkgconfig
, wrapQtAppsHook
, udisks2-qt5
, gtest
, qtbase
}:
let
  patchList = {
    ## INSTALL
    "dde-device-formatter.pro" = [ ];
  };
in
stdenv.mkDerivation rec {
  pname = "dde-device-formatter";
  version = "unstable-2022-09-05";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "9b8489cb2bb7c85bd62557d16a5eabc94100512e";
    sha256 = "sha256-Mi48dSDCoKhr8CGt9z64/9d7+r9QSrPPICv+R5VDuaU=";
  };

  patches = [
    (fetchpatch {
      name = "chore: don't use hardcode path";
      url = "https://github.com/linuxdeepin/dde-device-formatter/commit/b836a498b8e783e0dff3820302957f15ee8416eb.patch";
      sha256 = "sha256-i/VqJ6EmCyhE6weHKUB66bW6b51gLyssIAzb5li4aJM=";
    })
  ];
  
  postPatch = getPatchFrom patchList + ''
    patchShebangs *.sh
  '';


  nativeBuildInputs = [
    qmake
    qttools
    pkgconfig
    wrapQtAppsHook
    deepin-gettext-tools
  ];

  buildInputs = [
    dtk
    udisks2-qt5
    qtx11extras
  ];

  cmakeFlags = [ "-DVERSION=${version}" ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/${qtbase.qtPluginPrefix}"
  ];

  meta = with lib; {
    description = "A simple graphical interface for creating file system in a block device";
    homepage = "https://github.com/linuxdeepin/dde-device-formatter";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
