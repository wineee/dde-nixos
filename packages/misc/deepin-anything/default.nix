{ stdenv
, lib
, fetchFromGitHub
, dtkcore
, qmake
, pkgconfig
, udisks2-qt5
, utillinux
, pcre
}:

stdenv.mkDerivation rec {
  pname = "deepin-anything";
  version = "5.0.17";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-OY94ojhGCUxmpOPFgz4phInXntsHI/wLnWeYseMcAi0=";
  };

  output = [ "out" "server" ];

  nativeBuildInputs = [
    qmake
    pkgconfig
  ];

  buildInputs = [
    dtkcore
    udisks2-qt5
    utillinux
    pcre
  ];

  dontWrapQtApps = true;
  dontUseQmakeConfigure = true;

  buildPhase = ''
    make VERSION=${version}
    make -C library all
    cd server 
    qmake -makefile -nocache QMAKE_STRIP=: PREFIX=$server LIB_INSTALL_DIR=$server/lib deepin-anything-server.pro 
    make all
    cd ..
  '';

  installPhase = ''
    make VERSION=${version} DESTDIR=$out install
    # make -C server DESTDIR=$server install
  '';

  meta = with lib; {
    description = "Deepin Anything file search tool";
    homepage = "https://github.com/linuxdeepin/deepin-anything";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
