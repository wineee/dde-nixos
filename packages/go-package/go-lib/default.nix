{ stdenv
, lib
, fetchFromGitHub
, replaceAll
, glib
, xorg
, gdk-pixbuf
, pulseaudio
, mobile-broadband-provider-info
, runtimeShell
}:

stdenv.mkDerivation rec {
  pname = "go-lib";
  version = "5.8.27";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-ZV5zWu7UvNKVcVo79/iKMhF4H09rGyDCvEL61H05lZc=";
  };

  patches = [ ./0001-fix-IsDir-for-symlink.patch ];

  postPatch = replaceAll "/bin/sh" "${runtimeShell}";

  propagatedBuildInputs = [
    glib
    xorg.libX11
    gdk-pixbuf
    pulseaudio
    mobile-broadband-provider-info
  ];

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
  };
}
