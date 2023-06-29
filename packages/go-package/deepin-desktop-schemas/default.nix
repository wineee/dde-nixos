{ stdenv
, lib
, buildGoModule
, fetchFromGitHub
, glib
}:

buildGoModule rec {
  pname = "deepin-desktop-schemas";
  version = "6.0.1.p4";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "1712a3b812b8a0e49f75b5a0112d9060cc116bb9";
    hash = "sha256-FrL4Q55Q7ST9L/hrwvw44HQOLaDIxoMXaR0tW/u3u/8=";
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
