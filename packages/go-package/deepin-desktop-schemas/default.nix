{ stdenv
, lib
, fetchFromGitHub
, getPatchFrom
, buildGoPackage
, go
, go-lib
, glib
}:
let
  sw_share = [ "/usr/share" "/run/current-system/sw/share" ];
  patchList = {
    "schemas/com.deepin.dde.appearance.gschema.xml" = [
      sw_share
      # "/usr/share/backgrounds/default_background.jpg"
    ];
    "schemas/wrap/com.deepin.wrap.gnome.desktop.background.gschema.xml" = [
      sw_share
      # /usr/share/backgrounds/gnome/adwaita-timed.xml
    ];
    "schemas/wrap/com.deepin.wrap.gnome.desktop.screensaver.gschema.xml" = [
      sw_share
      # /usr/share/backgrounds/gnome/adwaita-lock.jpg
    ];
    "schemas/wrap/com.deepin.wrap.gnome.desktop.app-folders.gschema.xml" = [
      sw_share
      # /usr/share/desktop-directories.
    ];
    "overrides/mips/appearance.override" = [
      sw_share
      # /usr/share/wallpapers/deepin/desktop.bmp
    ];
    "overrides/common/com.deepin.wrap.gnome.desktop.override" = [
      sw_share
      # /usr/share/backgrounds/default_background.jpg
    ];
  };
in
buildGoPackage rec {
  pname = "deepin-desktop-schemas";
  version = "5.10.6";

  goPackagePath = "github.com/linuxdeepin/deepin-desktop-schemas";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-fCI9u0eotgaay/Ci8/3bzr4MZ95GN5fH0LBXFKHJlF8=";
  };

  nativeBuildInputs = [ glib ];
  buildInputs = [ go-lib ];

  postPatch = getPatchFrom patchList;

  buildPhase = ''
    runHook preBuild
    GOPATH="$GOPATH:${go-lib}/share/gocode"
    make ARCH=${stdenv.targetPlatform.linuxArch} -C go/src/${goPackagePath}
    runHook postBuild
  '';

  installPhase = ''
    make install DESTDIR="$out" PREFIX="/" -C go/src/${goPackagePath}
  '';

  preFixup = ''
    glib-compile-schemas ${glib.makeSchemaPath "$out" "${pname}-${version}"}
  '';

  meta = with lib; {
    description = "GSettings deepin desktop-wide schemas";
    homepage = "https://github.com/linuxdeepin/deepin-desktop-schemas";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
