{ stdenv
, lib
, buildGoModule
, fetchFromGitHub
, glib
}:

buildGoModule rec {
  pname = "deepin-desktop-schemas";
  version = "6.0.1";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "1a5e90644345d2f92382efb454d98e2d50d8e9ee";
    sha256 = "sha256-IfK6S13xgHHDiXRSaUol/35Y4UuoYa2ant64yIRhLFw=";
  };

  vendorSha256 = "sha256-q6ugetchJLv2JjZ9+nevUI0ptizh2V+6SByoY/eFJJQ=";

  postPatch = ''
    # Relocate files path for backgrounds and wallpapers
    for file in $(grep -rl "/usr/share")
    do
      substituteInPlace $file \
        --replace "/usr/share" "/run/current-system/sw/share"
    done
  '';

  buildPhase = ''
    runHook preBuild
    make ARCH=${stdenv.targetPlatform.linuxArch}
    runHook postBuild
  '';

  nativeCheckInputs = [ glib ];
  checkPhase = ''
    runHook preCheck
    make test
    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall
    make install DESTDIR="$out" PREFIX="/"
    runHook postInstall
  '';

  meta = with lib; {
    description = "GSettings deepin desktop-wide schemas";
    homepage = "https://github.com/linuxdeepin/deepin-desktop-schemas";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = teams.deepin.members;
  };
}
