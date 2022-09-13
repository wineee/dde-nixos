{ stdenv
, stdenvNoCC
, lib
, fetchpatch
, getUsrPatchFrom
, pkg-config
, fetchFromGitHub
, cmake
, kwin
, kwayland
, qtbase
, qttools
, wrapQtAppsHook
, deepin-gettext-tools
, extra-cmake-modules
, dtk
, gsettings-qt
, xorg
, libepoxy
, makeWrapper
}:
let
  patchList = {
    ### BUILD
    "translate_desktop2ts.sh" = [
      [ "/usr/bin/deepin-desktop-ts-convert" "deepin-desktop-ts-convert" ]
    ];
    "translate_ts2desktop.sh" = [
      [ "/usr/bin/deepin-desktop-ts-convert" "deepin-desktop-ts-convert" ]
    ];
    ### INSTALL
    "CMakeLists.txt" = [
      # TODO
      [ "/usr/include/KWaylandServer" "${kwayland.dev}/include/KWaylandServer" ]
      [ "/usr/local/include/KWaylandServer" "" ]
    ];
    "configures/CMakeLists.txt" = [
      [ "/etc/xdg" "$out/etc/xdg" ]
      [ " /bin" " $out/bin" ]
    ];
    "configures/kwin_no_scale.in" = [
      [ "/etc/xdg/kglobalshortcutsrc" "$out/etc/xdg/kglobalshortcutsrc" ]
      [ "kwin 5.21.5" "kwin ${kwin.version}" ] # TODO
    ];
    "plugins/platforms/lib/dde-kwin.pc.in" = [
      [ "/usr/X11R6/lib64" "$out/lib" ] # FIXME:
    ];

    ### 
    "plugins/kwineffects/multitasking/background.cpp" = [
      # TODO: file:///usr/share/wallpapers/deepin/desktop.jpg
    ];
    "deepin-wm-dbus/deepinwmfaker.cpp" = [
      # TODO: file:///usr/share/wallpapers/deepin/desktop.jpg
      # /usr/lib/deepin-daemon/dde-warning-dialog
    ];
    "plugins/platforms/plugin/main_wayland.cpp" = [ ];
    "plugins/platforms/plugin/main.cpp" = [ ];

  };

  libkwin = stdenvNoCC.mkDerivation rec {
    pname = "libkwin";
    version = kwin.version;
    src = kwin.out;
    propagatedBuildInputs = [ kwin ];
    dotBuild = true;
    dontWrapQtApps = true;
    installPhase = ''
      mkdir -p $out/lib
      ln -sf $src/lib/libkwin.so.${version} $out/lib/libkwin.so
      ln -sf $src/lib/libkwin.so.${version} $out/lib/libkwin.so.5
      ln -sf $src/lib/libkwin.so.${version} $out/lib/libkwin.so.${version}
    '';
    dontFixup = true;
  };
in
stdenv.mkDerivation rec {
  pname = "dde-kwin";
  version = "5.5.11-deepin";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-m2cSsWhv8sI5fK13ghq1PSOWwtxijSrD7dxslKU2UwI=";
  };

  patches = [
    (fetchpatch {
      name = "chore: check value of QT_INSTALL_PLUGINS before set";
      url = "https://github.com/justforlxz/dde-kwin/pull/1/commits/33b74703e9dbff5249bcc90ba1c0da486d7e734b.patch";
      sha256 = "sha256-TflLTT+0LxLks+6uxtwG0+m2eVQ1PxmcAtetKx2fIMM=";
    })
  ];

  postPatch = getUsrPatchFrom patchList + ''
    patchShebangs .
  '';

  nativeBuildInputs = [
    cmake
    qttools
    deepin-gettext-tools
    extra-cmake-modules
    pkg-config
    wrapQtAppsHook
    makeWrapper
  ];

  buildInputs = [
    kwin
    libkwin
    kwayland
    dtk
    gsettings-qt
    xorg.libXdmcp
    libepoxy.dev
  ];

  NIX_CFLAGS_COMPILE = [
    "-I${kwayland.dev}/include/KF5"
  ];

  cmakeFlags = [
    "-DPROJECT_VERSION=${version}"
    "-DKWIN_VERSION=${kwin.version}"
    #"-DPLUGIN_INSTALL_PATH=${placeholder "out"}/lib/plugins/platforms"
    "-DKWIN_LIBRARY_PATH=${libkwin}/lib"
    "-DCMAKE_INSTALL_PREFIX=${placeholder "out"}"
    "-DQT_INSTALL_PLUGINS=${placeholder "out"}/${qtbase.qtPluginPrefix}"

    "-DUSE_WINDOW_TOOL=OFF"
    "-DENABLE_BUILTIN_BLUR=OFF" 
    "-DENABLE_KDECORATION=ON"
    "-DENABLE_BUILTIN_MULTITASKING=OFF"
    "-DENABLE_BUILTIN_BLACK_SCREEN=OFF"
    "-DUSE_DEEPIN_WAYLAND=OFF"
    "-DENABLE_BUILTIN_SCISSOR_WINDOW=ON"
  ];

  postFixup = ''
    wrapProgram $out/bin/kwin_no_scale \
      --set QT_QPA_PLATFORM_PLUGIN_PATH "${placeholder "out"}/${qtbase.qtPluginPrefix}"
  '';
  ## FIXME: why cann't use --prefix

  meta = with lib; {
    description = "KWin configuration for Deepin Desktop Environment";
    homepage = "https://github.com/linuxdeepin/dde-kwin";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
