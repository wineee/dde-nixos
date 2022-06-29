{ stdenv
, lib
, fetchFromGitHub
, dtk
, qt5integration
, qt5platform-plugins
, dde-qt-dbus-factory
, cmake
, qttools
, pkgconfig
, qtmultimedia
, wrapQtAppsHook
, gtest
}:

stdenv.mkDerivation rec {
  pname = "deepin-gomoku";
  version = "1.0.9";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-/GxmEk3F97N2ngvvERxPjKEjXqFmMVb7kXP6KFY768Q=";
  };

  nativeBuildInputs = [
    cmake
    qttools
    pkgconfig
    wrapQtAppsHook
  ];

  buildInputs = [
    dtk
    qtmultimedia
    gtest
  ];

  cmakeFlags = [
    "-DVERSION=${version}"
  ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/plugins"
    "--prefix QT_QPA_PLATFORM_PLUGIN_PATH : ${qt5platform-plugins}/plugins"
  ];

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace "set(CMAKE_INSTALL_PREFIX /usr)" "set(CMAKE_INSTALL_PREFIX $out)"
    substituteInPlace gomoku/CMakeLists.txt \
      --replace "set(CMAKE_INSTALL_PREFIX /usr)" "set(CMAKE_INSTALL_PREFIX $out)" \
      --replace "/usr/share/deepin-manual/manual-assets/application/" "$out/share/deepin-manual/manual-assets/application/"
  '';

  meta = with lib; {
    description = "Gomoku is an easy and funny chess game that is suitable for all ages";
    homepage = "https://github.com/linuxdeepin/deepin-gomoku";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
