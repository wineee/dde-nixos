{ stdenv
, lib
, fetchFromGitHub
, dtkcore
, dtkgui
, dtkwidget
, dtkcommon
, qt5integration
, qt5platform-plugins
, dde-qt-dbus-factory
, gio-qt
, cmake
, qttools
, kwayland
, pkgconfig
, wrapQtAppsHook
, glibmm
, gtest
}:

stdenv.mkDerivation rec {
  pname = "dde-clipboard";
  version = "unstable-2022-03-03";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "e9642d368183edc5ea0ad62d65fbaa13a042121b";
    sha256 = "sha256-Y+rIc4Na7CwCPQN4xeQzUO3bUbK+tidhDL5mHD+3OVA=";
  };

  nativeBuildInputs = [
    cmake
    pkgconfig
    qttools
    wrapQtAppsHook
  ];

  buildInputs = [
    dtkcore
    dtkgui
    dtkwidget
    dtkcommon
    dde-qt-dbus-factory
    gio-qt
    kwayland
    glibmm
    gtest
  ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/plugins"
    "--prefix QT_QPA_PLATFORM_PLUGIN_PATH : ${qt5platform-plugins}/plugins"
  ];

  patches = [ ./0001-remove-support-waylandcopy-client.patch ];

  postPatch = ''
    patchShebangs translate_generation.sh generate_gtest_report.sh

    substituteInPlace CMakeLists.txt \
      --replace "/etc/xdg/autostart)" "$out/xdg/autostart)"
  '';

  meta = with lib; {
    description = "DDE optional clipboard manager componment";
    homepage = "https://github.com/linuxdeepin/dde-clipboard";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
