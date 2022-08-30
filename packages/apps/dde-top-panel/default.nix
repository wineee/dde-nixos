{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, dtk
, gsettings-qt
, qt5integration
, udisks2-qt5
, cmake
, qttools
, qtx11extras
, kwayland
, kwindowsystem
, pkgconfig
, dde-qt-dbus-factory
, wrapQtAppsHook
, xorg
, xdotool
, qtbase
}:

stdenv.mkDerivation rec {
  pname = "dde-top-panel";
  version = "unstable-2022-08-30";

  src = fetchFromGitHub {
    owner = "wineee"; #"SeptemberHX";
    repo = pname;
    rev = "b1bc618e7629702637e539c7b2c1c0f479095c48";
    sha256 = "sha256-BAlspeiZFOn9N2gyHNnAezPqE2/ukDxQSU3pS2jSXBQ=";
  };

  nativeBuildInputs = [
    cmake
    qttools
    pkgconfig
    wrapQtAppsHook
  ];

  buildInputs = [
    dtk
    gsettings-qt
    qtx11extras
    kwindowsystem
    dde-qt-dbus-factory
    kwayland
    xorg.libXdmcp
    xdotool #
  ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/${qtbase.qtPluginPrefix}"
  ];

  cmakeFlags = [
    "-DVERSION=${version}"
    #"-DUSE_TEST=OFF"
  ];

#   fixPluginLoadPatch = ''
#     substituteInPlace src/source/common/pluginmanager.cpp \
#       --replace "/usr/lib/" "$out/lib/"
#   '';

#  postPatch = fixPluginLoadPatch;

  meta = with lib; {
    description = "Top panel for deepin desktop environment v20";
    homepage = "https://github.com/SeptemberHX/dde-top-panel";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
