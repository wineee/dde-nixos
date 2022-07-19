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
  pname = "deepin-draw";
  version = "5.11.2";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-oPbOnWwktR0FA9lJRXs7qxKRBABf5HymtMeI92ZHIdU";
  };

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

  fixInstallPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace "set(PREFIX /usr)" "set(PREFIX $out)"

    substituteInPlace src/deepin-draw/CMakeLists.txt \
      --replace "/usr/lib" "$out/lib" \
      --replace "/usr/bin" "$out/bin"
  '';

  fixServicePatch = ''
    substituteInPlace com.deepin.Draw.service \
      --replace "/usr/bin/deepin-draw" "deepin-draw"
  '';

  postPatch = fixInstallPatch + fixServicePatch;
  #separateDebugInfo = true;

  meta = with lib; {
    description = "An easy to use calculator for ordinary users";
    homepage = "https://github.com/linuxdeepin/deepin-calculator";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
