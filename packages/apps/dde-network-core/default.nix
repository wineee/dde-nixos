{ stdenv
, lib
, getPatchFrom
, fetchFromGitHub
, fetchpatch
, dtk
, dde-qt-dbus-factory
, dde-dock
, dde-control-center
, dde-session-shell
, qt5integration
, qt5platform-plugins
, gio-qt
, cmake
, qttools
, pkgconfig
, gsettings-qt
, networkmanager-qt
, glib
, pcre
, utillinux
, libselinux
, libsepol
, wrapQtAppsHook
, dbus
, gtest
, qtbase
, breakpointHook
}:
let
  # FIXME: cant build 
  patchList = {

  }; 
in stdenv.mkDerivation rec {
  pname = "dde-network-core";
  version = "1.0.45+";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "2dd8c5c35644d48b2b007188b3746f64516720d3";
    sha256 = "sha256-UmjDUax/PsCsqT5b2KImiYLyU/mLKTHhE2/8W49I9Tg=";
  };

  patches = [
    (fetchpatch {
      name = "chore: use GNUInstallDirs in CmakeLists";
      url = "https://github.com/linuxdeepin/dde-network-core/commit/ada23d3ff993316d832ffac755f62dd95829f9da.patch";
      sha256 = "sha256-Xr1qlseCjsp81TxRKH0UjQiJg56RnY+0BDHL08rD91k=";
    })
  ];

  postPatch = getPatchFrom patchList;

  nativeBuildInputs = [
    cmake
    qttools
    pkgconfig
    wrapQtAppsHook
    breakpointHook
  ];

  buildInputs = [ 
    dtk
    dde-dock
    dde-control-center
    dde-session-shell
    dde-qt-dbus-factory
    gsettings-qt
    gio-qt
    networkmanager-qt.dev
    glib.dev
    pcre
    utillinux
    libselinux
    libsepol
    gtest
  ];

  #NIX_CFLAGS_COMPILE = [ "-I${glib.dev}/include/glib-2.0" ];

  enableParallelBuilding = true;
  cmakeFlags = [ 
    "-DVERSION=${version}"
  ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/${qtbase.qtPluginPrefix}"
  ];

  meta = with lib; {
    description = "dde-network-core";
    homepage = "https://github.com/linuxdeepin/dde-network-core";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
