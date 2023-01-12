{ stdenv
, lib
, fetchpatch
, fetchFromGitHub
, getUsrPatchFrom
, dtk
, qt5integration
, dde-qt-dbus-factory
, cmake
, qttools
, pkg-config
, qtmultimedia
, wrapQtAppsHook
, gtest
, qtbase
}:

stdenv.mkDerivation rec {
  pname = "deepin-lianliankan";
  version = "1.0.9";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-79HohkY4EyeGewEsdz/n4cuWODKem/tnMPt/W6Cy/Lo=";
  };

  patches = [
    (fetchpatch {
      name = "chore: use GNUInstallDirs in CmakeLists";
      url = "https://github.com/linuxdeepin/deepin-lianliankan/commit/5a1b28b402dd25233136aa9728d822edf2d7c6b3.patch";
      sha256 = "sha256-JMeS1wClRTqMJDKFC2RxEfK0ceHQDvzz4mCs4PGvjWo=";
    })
  ];

  postPatch = getUsrPatchFrom {
    "translations/desktop/${pname}.desktop" = [ ];
  };

  nativeBuildInputs = [
    cmake
    qttools
    pkg-config
    wrapQtAppsHook
  ];

  buildInputs = [
    dtk
    qtmultimedia
    gtest
  ];

  cmakeFlags = [ "-DVERSION=${version}" ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/${qtbase.qtPluginPrefix}"
  ];

  meta = with lib; {
    description = "Lianliankan is an easy-to-play puzzle game with cute interface and countdown timer";
    homepage = "https://github.com/linuxdeepin/deepin-lianliankan";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
