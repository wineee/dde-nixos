{ stdenv
, lib
, fetchFromGitHub
, dtkcore
, dtkgui
, dtkwidget
, dtkcommon
, qt5integration
, qt5platform-plugins
, cmake
, qttools
, pkgconfig
, wrapQtAppsHook
}:

stdenv.mkDerivation rec {
  pname = "deepin-draw";
  version = "5.10.6";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-yG7XzEkp9IYtemC1LOsOWAA8Erq3EsQebmI3aAXhylU=";
  };

  nativeBuildInputs = [
    cmake
    qttools
    pkgconfig
    wrapQtAppsHook
  ];

  buildInputs = [
    dtkcommon
    dtkcore
    dtkgui
    dtkwidget
  ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/plugins"
    "--prefix QT_PLUGIN_PATH : ${qt5platform-plugins}/plugins"
  ];

  fixInstallPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace "set(PREFIX /usr)" "set(PREFIX $out)"

    substituteInPlace src/deepin-draw/CMakeLists.txt \
      --replace "/usr/lib" "$out/lib" \
      --replace "/usr/bin" "$out/bin"
  '';

  postPatch = fixInstallPatch;

  meta = with lib; {
    description = "An easy to use calculator for ordinary users";
    homepage = "https://github.com/linuxdeepin/deepin-calculator";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
