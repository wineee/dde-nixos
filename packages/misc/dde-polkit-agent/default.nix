{ stdenv
, lib
, fetchFromGitHub
, getUsrPatchFrom
, dtk
, qt5integration
, qt5platform-plugins
, dde-qt-dbus-factory
, pkgconfig
, cmake
, qttools
, wrapQtAppsHook
, polkit-qt
, dde-session-shell
, qtbase
}:
let
  patchList = {
    "AuthDialog.cpp" = [
      [ "/usr/share/dde-session-shell/dde-session-shell.conf"  "${dde-session-shell}/share/dde-session-shell/dde-session-shell.conf" ]
    ];
  };
in
stdenv.mkDerivation rec {
  pname = "dde-polkit-agent";
  version = "5.5.21";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-jWH1E3lBEIlLtwO8oTIaK7CzUhGfxJIo2KOQ1om2qco=";
  };

  postPatch = getUsrPatchFrom patchList;

  nativeBuildInputs = [
    cmake
    pkgconfig
    qttools
    wrapQtAppsHook
  ];

  buildInputs = [
    dtk
    dde-qt-dbus-factory
    polkit-qt
  ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/${qtbase.qtPluginPrefix}"
  ];

  postFixup = ''
    wrapQtApp $out/lib/polkit-1-dde/dde-polkit-agent
  '';

  meta = with lib; {
    description = "PolicyKit agent for Deepin Desktop Environment";
    homepage = https://github.com/linuxdeepin/dde-polkit-agent;
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
