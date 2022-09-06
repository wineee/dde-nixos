{ stdenv
, lib
, fetchFromGitHub
, pkgconfig
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
    rev = "a070bf688aeccd4cb701b078897fcd3efe88a657";
    sha256 = "sha256-B0szFtXsEhcvPuwVy8SIDVKvJCPk2V4/N0lsNR0rjD4=";
  };

  nativeBuildInputs = [
    cmake
    pkgconfig
    qttools
    wrapQtAppsHook
  ];

  buildInputs = [ qtbase ];

  qmakeFlags = [ "PREFIX=${placeholder "out"}" ];

  patches = [ ./0001-dtk_lib-disable-examples-subdirs.patch ];

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
