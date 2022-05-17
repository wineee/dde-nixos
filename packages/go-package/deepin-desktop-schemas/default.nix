{ stdenv
, lib
, fetchFromGitHub
, buildGoPackage
, go
, go-lib
, glib
}:

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

  preBuild = ''
    cp -r ${go-lib}/share/gocode/* go/
  '';

  buildPhase = ''
    runHook preBuild
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
