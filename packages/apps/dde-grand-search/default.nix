{ stdenv
, lib
, fetchFromGitHub
, dtk
, qt5integration
, qt5platform-plugins
, cmake
, qttools
, pkgconfig
, wrapQtAppsHook
}:

stdenv.mkDerivation rec {
  pname = "dde-grand-search";
  version = "5.3.2";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "";
  };

  #postPatch = fixInstallPatch + fixServicePatch;

  nativeBuildInputs = [
    cmake
    qttools
    pkgconfig
    wrapQtAppsHook
  ];

  buildInputs = [ dtk ];

  cmakeFlags = [ "-DVERSION=${version}" ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/plugins"
    "--prefix QT_QPA_PLATFORM_PLUGIN_PATH : ${qt5platform-plugins}/plugins"
  ];

  meta = with lib; {
    description = "System-wide desktop search for DDE";
    homepage = "https://github.com/linuxdeepin/dde-grand-search";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
