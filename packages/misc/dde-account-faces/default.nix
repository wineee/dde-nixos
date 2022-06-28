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

  installPhase = ''
    make install DESTDIR="$out" PREFIX="/"
  '';

  meta = with lib; {
    description = "dde-account-faces provides account-faces of dde";
    homepage = "https://github.com/linuxdeepin/dde-account-faces";
    license = licenses.cc0;
    platforms = platforms.linux;
  };
}
