{ stdenv
, lib
, fetchFromGitHub
, replaceAll
, runtimeShell
, dtkwidget
, qt5integration
, qt5platform-plugins
, dde-file-manager
, cmake
, qttools
, pkg-config
, wrapQtAppsHook
, fontconfig
, freetype
, gtest
, fileManagerPlugins ? false
, qtbase
}:

stdenv.mkDerivation rec {
  pname = "deepin-font-manager";
  version = "6.0.0.999";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "96fd33b6b68f7c3830144668d389d82d77ef61f2";
    hash = "sha256-jY4fNM94u9nfX6wSE7qOwah32IKZVe1E9jx/zXlj0Y8=";
  };

  rmPluginPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace "ADD_SUBDIRECTORY(deepin-font-preview-plugin)" " " 
  '';

  postPatch = lib.optionalString (!fileManagerPlugins) rmPluginPatch
    + replaceAll "/usr/share/deepin-font-manager" "$out/share/deepin-font-manager"
    + replaceAll "/usr/share/icons" "/run/current-system/sw/share/icons"
    + replaceAll "/bin/bash" "${runtimeShell}"
    + ''
    substituteInPlace deepin-font-manager/views/dfinstallnormalwindow.cpp \
     --replace 'contains("/usr/share/")' 'contains("/nix/store")'
    substituteInPlace libdeepin-font-manager/dfontinfomanager.cpp \
      --replace 'FONT_SYSTEM_DIR = "/usr/share/fonts/"' 'FONT_SYSTEM_DIR = "/run/current-system/sw/share/X11/fonts"' \
      --replace 'contains("/usr/share/fonts/")' 'contains("/nix/store")'
    substituteInPlace libdeepin-font-manager/dfmdbmanager.h \
      --replace 'contains("/usr/share/fonts/")' 'contains("/nix/store")'
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    qttools
    wrapQtAppsHook
  ];

  buildInputs = [
    dtkwidget
    fontconfig
    freetype
    gtest
    qt5integration
    qt5platform-plugins
    (lib.optional fileManagerPlugins dde-file-manager)
  ];

  cmakeFlags = [ "-DVERSION=${version}" ];

  meta = with lib; {
    description = "Deepin Font Manager is used to install and uninstall font file for users with bulk install function";
    homepage = "https://github.com/linuxdeepin/deepin-font-manager";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
