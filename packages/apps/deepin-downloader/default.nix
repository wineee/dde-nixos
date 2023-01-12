{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, replaceAll
, dtk
, qt5integration
, cmake
, qttools
, qtwebengine
, qtwebsockets
, pkg-config
, wrapQtAppsHook
, gtest
, qtbase
}:

stdenv.mkDerivation rec {
  pname = "deepin-downloader";
  version = "5.3.70";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-divROohz9v3sAI9sVF+ck2UeaQoGgjFbXNJ8yCkwdfE=";
  };

  patches = [
    (fetchpatch {
      name = "chore: use GNUInstallDirs in CmakeLists";
      url = "https://github.com/linuxdeepin/deepin-downloader/commit/b4e5425c97b48065baebe55a8f9af3a3f149ad59.patch";
      sha256 = "sha256-xu+rnkfnsnvVolbzvnHJCZSwbV5CYxrWJ+UO9s+Bk6g=";
    })
  ];

  postPatch = replaceAll "/usr/bin/touch" "touch" + replaceAll "/usr/share/downloader/database/" "/var/db/downloader/database/";
  #    replaceAll "/usr/share/applications/" "/run/current-system/sw/share/applications/"
  #   + replaceAll "/usr/bin/touch" "touch";

  nativeBuildInputs = [
    cmake
    qttools
    pkg-config
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
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/${qtbase.qtPluginPrefix}"
  ];

  # TODO UOS_DONWLOAD_DATABASE_PATH ..

  meta = with lib; {
    description = "Download Manager is Deepin Desktop Environment download manager";
    homepage = "https://github.com/linuxdeepin/deepin-downloader";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
