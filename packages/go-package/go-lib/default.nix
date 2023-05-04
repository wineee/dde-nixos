{ stdenv
, lib
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "go-lib";
  version = "6.0.4";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-twzFtZdtJqMZsBBbHclFHzEDeXHP3MpOtmL1zvVg5vk=";
  };

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/gocode/src/github.com/linuxdeepin/go-lib
    cp -a * $out/share/gocode/src/github.com/linuxdeepin/go-lib
    rm -r $out/share/gocode/src/github.com/linuxdeepin/go-lib/debian
    runHook postInstall
  '';

  meta = with lib; {
    description = "a library containing many useful go routines for things such as glib, gettext, archive, graphic, etc";
    homepage = "https://github.com/linuxdeepin/go-lib";
    license = licenses.gpl2Only;
    platforms = platforms.linux;
    maintainers = teams.deepin.members;
  };
}
