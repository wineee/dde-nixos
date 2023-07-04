{ stdenv
, lib
, fetchFromGitHub
, cmake
}:

stdenv.mkDerivation rec {
  pname = "dtkcommon";
  version = "5.6.12";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    hash = "sha256-tLz9ddE+yKjn3MGgqkr54mY+z3/a9YOUykr0sgeXwpE=";
  };

  nativeBuildInputs = [
    cmake
  ];

  dontWrapQtApps = true;

  qmakeFlags = [ "PREFIX=${placeholder "out"}" ];

  meta = with lib; {
    description = "A public project for building DTK Library";
    homepage = "https://github.com/linuxdeepin/dtkcommon";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = teams.deepin.members;
  };
}
