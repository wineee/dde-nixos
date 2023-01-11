{ stdenv
, lib
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "dde-account-faces";
  version = "1.0.12.1";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-NWjR8qxWi2IrcP0cSF+lLxBJ/GrVpk1BfTjVH0ytinY=";
  };

  # It should be installed to /var，but this can't be done directly on nixos, so move to $out/share
  # we need patch dde-control-center / dde-daemon also
  installPhase = ''
    make install DESTDIR="$out/share" PREFIX="/"
  '';

  meta = with lib; {
    description = "Account faces of deepin desktop environment";
    homepage = "https://github.com/linuxdeepin/dde-account-faces";
    license = with licenses; [ gpl3Plus cc0 ];
    platforms = platforms.linux;
  };
}
