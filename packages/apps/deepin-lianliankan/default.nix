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
  pname = "deepin-lianliankan";
  version = "1.0.9";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-79HohkY4EyeGewEsdz/n4cuWODKem/tnMPt/W6Cy/Lo=";
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

  cmakeFlags = [ "-DVERSION=${version}" ];

  # qtWrapperArgs = [
  #   "--prefix QT_PLUGIN_PATH : ${qt5integration}/plugins"
  #   "--prefix QT_QPA_PLATFORM_PLUGIN_PATH : ${qt5platform-plugins}/plugins"
  # ];

  postPatch = ''
    substituteInPlace src/CMakeLists.txt \
      --replace "set(CMAKE_INSTALL_PREFIX /usr)" "set(CMAKE_INSTALL_PREFIX $out)" \
      --replace "/usr/share/deepin-manual/manual-assets/application/" "$out/share/deepin-manual/manual-assets/application/"
  '';

  meta = with lib; {
    description = "Lianliankan is an easy-to-play puzzle game with cute interface and countdown timer";
    homepage = "https://github.com/linuxdeepin/deepin-lianliankan";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
