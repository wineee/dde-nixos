{ stdenv
, stdenvNoCC
, lib
, getPatchFrom
, getShebangsPatchFrom
, pkg-config
, fetchFromGitHub
, cmake
, kwin
, kwayland
, qttools
, wrapQtAppsHook
, deepin-gettext-tools
, extra-cmake-modules
, dtk
, gsettings-qt
, xorg
, libepoxy
, qt5integration
, qt5platform-plugins
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
  version = "5.4.26";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-j/dgGt5zNaVHZF+DrEK8aRdYanPxcvePwqKmc7KM8gk=";
  };

  patches = [
    ./0001-feat-check-PLUGIN_INSTALL_PATH-value-before-set.patch
    ./dde-kwin.5.4.26.patch
    ./deepin-kwin-tabbox-chameleon-rename.patch
  ];

  postPatch = ''
    patch -Rp1 -i ${./deepin-kwin-added-functions-from-their-forked-kwin.patch}

    sed -i '/add_subdirectory(kdecoration)/d' plugins/CMakeLists.txt || die
    sed -i 's|GLRenderTarget|GLFramebuffer|g' plugins/kwineffects/scissor-window/scissorwindow.cpp || die
    sed -i '/(!w->isPaintingEnabled() || (mask & PAINT_WINDOW_LANCZOS)/,+2d' plugins/kwineffects/scissor-window/scissorwindow.cpp || die
  '' + getPatchFrom patchList + getShebangsPatchFrom [
    "configures/kwin_no_scale.in"
    "translate_desktop2ts.sh"
    "translate_ts2desktop.sh"
    "plugins/platforms/plugin/translate_generation.sh"
  ];

  nativeBuildInputs = [
    cmake
    qttools
    deepin-gettext-tools
    extra-cmake-modules
    pkg-config
    wrapQtAppsHook
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
    "-DUSE_WINDOW_TOOL=OFF"
    "-DENABLE_BUILTIN_BLUR=OFF"
    "-DENABLE_KDECORATION=OFF" #TODO
    "-DENABLE_BUILTIN_MULTITASKING=OFF"
    "-DENABLE_BUILTIN_BLACK_SCREEN=OFF"
    "-DUSE_DEEPIN_WAYLAND=OFF"
    "-DPLUGIN_INSTALL_PATH=${placeholder "out"}/lib/plugins/platforms"

    "-DENABLE_BUILTIN_SCISSOR_WINDOW=OFF" # TODO
    "-DKWIN_LIBRARY_PATH=${libkwin}/lib"
  ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/plugins"
    "--prefix QT_QPA_PLATFORM_PLUGIN_PATH : ${qt5platform-plugins}/plugins"
    "--prefix QT_QPA_PLATFORM_PLUGIN_PATH : ${placeholder "out"}/lib/plugins"
  ];

  postFixup = ''
    wrapQtApp $out/bin/kwin_no_scale
  '';

  meta = with lib; {
    description = "KWin configuration for Deepin Desktop Environment";
    homepage = "https://github.com/linuxdeepin/dde-kwin";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
