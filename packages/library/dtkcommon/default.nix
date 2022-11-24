{ stdenv
, lib
, fetchFromGitHub
, pkg-config
, cmake
, qtbase
, qttools
, wrapQtAppsHook
, glib
}:

stdenv.mkDerivation rec {
  pname = "dtkcommon";
  version = "5.5.23+";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "73b615b5287e780261ccf8bb0bdd421bd9bb6f6b";
    sha256 = "sha256-RrM6KmM68or6MAmJgPVzN68Mflo5E4JXlhVgTYkiiTY=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    qttools
    wrapQtAppsHook
  ];

  buildInputs = [ qtbase ];

  qmakeFlags = [ "PREFIX=${placeholder "out"}" ];

  preFixup = ''
    glib-compile-schemas ${glib.makeSchemaPath "$out" "${pname}-${version}"}
  '';

  meta = with lib; {
    description = "A public project for building DTK Library";
    homepage = "https://github.com/linuxdeepin/dtkcommon";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
