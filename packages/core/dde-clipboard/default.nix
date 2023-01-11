{ stdenv
, lib
, fetchFromGitHub
, getUsrPatchFrom
, dtk
, qt5integration
, qt5platform-plugins
, dde-qt-dbus-factory
, gio-qt
, cmake
, qttools
, kwayland
, pkg-config
, wrapQtAppsHook
, glibmm
, gtest
, qtbase
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
    owner = "wineee";
    repo = pname;
    rev = "8a985ca4edf9cad634121128c13abcddaf46d4a1";
    sha256 = "sha256-iHqFTHIKXPebRxuGFC5lQhZoN2u3CLO7jkczGtKOuRU=";
  };

  #patches = [ ./0001-feat-remove-wayland-support.patch ];

  postPatch = getUsrPatchFrom patchList + ''
    patchShebangs translate_generation.sh generate_gtest_report.sh
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
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
  ];

  # NIX_CFLAGS_COMPILE = [ "-I${kwayland.dev}/include/KF5/KWayland" ];
  cmakeFlags = [
    "-DUSE_DEEPIN_WAYLAND=OFF"
  ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/${qtbase.qtPluginPrefix}"
  ];

  meta = with lib; {
    description = "DDE optional clipboard manager componment";
    homepage = "https://github.com/linuxdeepin/dde-clipboard";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
