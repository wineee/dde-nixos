{ stdenv
, lib
, fetchFromGitHub
, dtk
, qtsvg
, qt5integration
, qt5platform-plugins
, cmake
, qttools
, pkgconfig
, wrapQtAppsHook
, qtbase
}:

stdenv.mkDerivation rec {
  pname = "deepin-draw";
  version = "5.11.2";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-oPbOnWwktR0FA9lJRXs7qxKRBABf5HymtMeI92ZHIdU";
  };

  fixInstallPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace "set(PREFIX /usr)" "set(PREFIX $out)"

    substituteInPlace src/deepin-draw/CMakeLists.txt \
      --replace "/usr/lib" "$out/lib" \
      --replace "/usr/bin" "$out/bin"
  '';

  fixServicePatch = ''
    substituteInPlace com.deepin.Draw.service \
      --replace "/usr/bin/deepin-draw" "$out/bin/deepin-draw"
  '';

  postPatch = fixInstallPatch + fixServicePatch;

  nativeBuildInputs = [
    cmake
    qttools
    pkgconfig
    wrapQtAppsHook
  ];

  buildInputs = [ dtk  ];

  cmakeFlags = [ "-DVERSION=${version}" ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/${qtbase.qtPluginPrefix}"
  ];

  #separateDebugInfo = true;

  meta = with lib; {
    description = "An easy to use calculator for ordinary users";
    homepage = "https://github.com/linuxdeepin/deepin-calculator";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
