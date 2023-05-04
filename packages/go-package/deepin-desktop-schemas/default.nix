{ stdenv
, lib
, buildGoModule
, fetchFromGitHub
, go
, glib
}:
buildGoModule rec {
  pname = "deepin-desktop-schemas";
  version = "6.0.0";

  src = fetchFromGitHub {
    owner = "wineee";
    repo = pname;
    rev = "1e5a8b203f0e010b531cd8fbc050db133f7bb88d";
    sha256 = "sha256-Ez7kSrFefAsWSfnF6neCNMhKc7/wBLbc1vn8+Y4LLYY=";
  };

  vendorSha256 = "sha256-IoJDa1YNGL18I5xQZBDds0muIu8yGXOV8SFQYiQSYdk=";

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
    glib-compile-schemas --dry-run result
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
  };
}
