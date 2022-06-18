{ stdenv
, lib
, fetchFromGitHub
, pkgconfig
, qmake
, qtbase
, qttools
, wrapQtAppsHook
, glib
}:

stdenv.mkDerivation rec {
  pname = "dtkcommon";
  version = "5.5.23";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-6Oe0b74Vkj9OQMVh5kQlx4FVO66HSL0Y1RJkCFqeqFQ=";
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
    substituteInPlace cmake/Dtk/DtkInstallDConfigConfig.cmake \
      --replace '/usr/share/dsg' 'share/dsg' \
      --replace '/opt/apps'      'opt/apps'
    substituteInPlace features/dtk_install_dconfig.prf \
      --replace '/usr/share/dsg' 'share/dsg' \
      --replace '/opt/apps'      'opt/apps'
  '';

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
