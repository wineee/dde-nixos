{ stdenv
, lib
, fetchFromGitHub
, dtk
, qt5integration
, qt5platform-plugins
, cmake
, qttools
, qtwebengine
, qtwebsockets
, pkgconfig
, wrapQtAppsHook
, gtest
}:

stdenv.mkDerivation rec {
  pname = "deepin-downloader";
  version = "5.3.69.1";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-mPjrno6quSClXJmL8Nvh0cA0uiX214l5igSDIelGPgw=";
  };

  nativeBuildInputs = [
    cmake
    qttools
    pkgconfig
    wrapQtAppsHook
  ];

  buildInputs = [ 
    dtk
    qtwebengine
    qtwebsockets
    gtest
  ];

  cmakeFlags = [ "-DVERSION=${version}" ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/plugins"
    "--prefix QT_QPA_PLATFORM_PLUGIN_PATH : ${qt5platform-plugins}/plugins"
  ];

  fixInstallPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace "set(CMAKE_INSTALL_PREFIX /usr)" "set(CMAKE_INSTALL_PREFIX $out)" \
      --replace "/usr/share/deepin-manual/manual-assets/application/" "$out/share/deepin-manual/manual-assets/application/" \
      --replace "/etc/browser/native-messaging-hosts/" "$out/etc/browser/native-messaging-hosts/" \
      --replace "/usr/libexec/openconnect/" "$out/libexec/openconnect/"

  '';

  # TODO UOS_DONWLOAD_DATABASE_PATH ..
  fixPathCodePatch = ''
    substituteInPlace src/aria2/aria2rpcinterface.cpp \
      --replace "/usr/bin/touch" "touch"
  '';

  postPatch = fixInstallPatch;

  meta = with lib; {
    description = "Download Manager is Deepin Desktop Environment download manager";
    homepage = "https://github.com/linuxdeepin/deepin-downloader";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
