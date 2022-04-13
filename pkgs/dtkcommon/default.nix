{ stdenv
, lib
, fetchFromGitHub
, pkgconfig
, qmake
, qtbase
, qttools
, wrapQtAppsHook
}:

stdenv.mkDerivation rec {
  pname = "dtkcommon";
  version = "5.5.21";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-rXiufbD6+PKkL2g0USplCsXl/XVaV/CebZ2ZuP5StaQ=";
  };

  nativeBuildInputs = [
    qmake
    pkgconfig
    qttools
    wrapQtAppsHook
  ];

  buildInputs = [
    qtbase
  ];

  qmakeFlags = [ "PREFIX=${placeholder "out"}" ];

  patches = [ ./0001-dtk_lib-disable-examples-subdirs.patch ];

  postPatch = ''
    substituteInPlace dtkcommon.pro \
        --replace '$${getQtMacroFromQMake(QT_INSTALL_LIBS)}'      $out/lib \
        --replace '$${getQtMacroFromQMake(QT_INSTALL_ARCHDATA)}'  $out
  '';

  meta = with lib; {
    description = "A public project for building DTK Library";
    homepage = "https://github.com/linuxdeepin/dtkcommon";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
