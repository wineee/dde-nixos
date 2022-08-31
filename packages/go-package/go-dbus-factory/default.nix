{ stdenv
, lib
, fetchFromGitHub
, go-lib
, go
}:

stdenv.mkDerivation rec {
  pname = "go-dbus-factory";
  version = "5.10.22";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-9hkO4lYh1mI72yzCtdYvgCPjRsi7EJyWJfdVnglD27s=";
  };

  makeFlags = [ "PREFIX=${placeholder "out"}" ];

  meta = with lib; {
    description = "Generate go binding of D-Bus interfaces";
    homepage = "https://github.com/linuxdeepin/go-dbus-factory";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
