{ stdenv
, lib
, fetchFromGitHub
, getUsrPatchFrom
, dtkwidget
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
  };
in
stdenv.mkDerivation rec {
  pname = "dde-clipboard";
  version = "5.4.25";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-oFATOBXf4NvGxjVMlfxwfQkBffeKut8ao+X6T9twb/I=";
  };

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
    dtkwidget
    dde-qt-dbus-factory
    gio-qt
    kwayland
    glibmm
    gtest
  ];

  cmakeFlags = [
    "-DUSE_DEEPIN_WAYLAND=OFF"
  ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/${qtbase.qtPluginPrefix}"
    "--prefix QT_QPA_PLATFORM_PLUGIN_PATH : ${qt5platform-plugins}/${qtbase.qtPluginPrefix}"
  ];

  meta = with lib; {
    description = "DDE optional clipboard manager componment";
    homepage = "https://github.com/linuxdeepin/dde-clipboard";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
