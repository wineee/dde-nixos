{ stdenv
, lib
, fetchFromGitHub
, getPatchFrom
, dtk
, pkg-config
, cmake
, dde-dock
, dde-qt-dbus-factory
, deepin-gettext-tools
, glib
, gsettings-qt
, lightdm_qt
, qttools
, qtx11extras
, utillinux
, xorg
, pcre
, libselinux
, libsepol
, wrapQtAppsHook
, gtest
}:
let
  patchList = {
    ## TODO patch code
  };
in
stdenv.mkDerivation rec {
  pname = "dde-session-ui";
  version = "5.5.24";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-N4TOnkYpjRbozr6sZefhkYFOvbYDp124qvlGaUjWiuQ=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    qttools
    deepin-gettext-tools
    wrapQtAppsHook
  ];

  buildInputs = [
    dtk
    dde-dock
    dde-qt-dbus-factory
    gsettings-qt
    qtx11extras
    pcre
    xorg.libXdmcp
    utillinux
    libselinux
    libsepol
    gtest
  ];

  NIX_CFLAGS_COMPILE = "-I${dde-dock}/include/dde-dock";

  postPatch = getPatchFrom patchList;

  dontWrapQtApps = true;

  preFixup = ''
    glib-compile-schemas ${glib.makeSchemaPath "$out" "${pname}-${version}"}
    ln -s ${glib.makeSchemaPath "$out" "${pname}-${version}"} $out/share/glib-2.0/schemas

    qtWrapperArgs+=(
      "''${gappsWrapperArgs[@]}"
    )
  '';

  postFixup = ''
    # wrapGAppsHook or wrapQtAppsHook does not work with binaries outside of $out/bin or $out/libexec
    for binary in $out/lib/deepin-daemon/*; do
      wrapProgram $binary "''${qtWrapperArgs[@]}"
    done
  '';

  meta = with lib; {
    description = "Deepin desktop-environment - Session UI module";
    homepage = "https://github.com/linuxdeepin/dde-session-ui";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
