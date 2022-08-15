{ stdenv
, lib
, fetchFromGitHub
, getPatchFrom
, dtk
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
let
  patchList = {
    "CMakeLists.txt" = [
      [ "/etc/xdg" "$out/etc/xdg" ]
      [ "/lib/systemd/user" "$out/lib/systemd/user" ]
    ];
    "misc/dde-clipboard.desktop" = [ ];
    "misc/dde-clipboard-daemon.service" = [ ];
    "misc/com.deepin.dde.Clipboard.service" = [
      [ "/usr/bin/qdbus" "${qttools}/bin/qdbus" ]
    ];
    "dde-clipboard-daemon/dbus_manager.cpp" = [ ];
  };
in
stdenv.mkDerivation rec {
  pname = "dde-clipboard";
  version = "5.4.7+";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "20e6ade9a253fe15d90400555a0e2e6f4c68a970";
    sha256 = "sha256-Q8yuhseFX3hlmBLfARYkoDfv5E4VxMEkKWs+mh74ZU8=";
  };

  patches = [ ./0001-feat-remove-wayland-support.patch ];

  postPatch = getPatchFrom patchList + ''
    patchShebangs translate_generation.sh generate_gtest_report.sh
  '';

  nativeBuildInputs = [
    cmake
    pkgconfig
    qttools
    wrapQtAppsHook
  ];

  buildInputs = [
    dtk
    dde-qt-dbus-factory
    gio-qt
    kwayland
    glibmm
    gtest
    qt5integration
    qt5platform-plugins
  ];

  # NIX_CFLAGS_COMPILE = [ "-I${kwayland.dev}/include/KF5/KWayland" ];

  # qtWrapperArgs = [
  #   "--prefix QT_PLUGIN_PATH : ${qt5integration}/plugins"
  #   "--prefix QT_QPA_PLATFORM_PLUGIN_PATH : ${qt5platform-plugins}/plugins"
  # ];

  meta = with lib; {
    description = "DDE optional clipboard manager componment";
    homepage = "https://github.com/linuxdeepin/dde-clipboard";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
