{ stdenv
, lib
, fetchFromGitHub
, dtkwidget
, gio-qt
, cmake
, extra-cmake-modules
, qttools
, wayland
, kwayland
, dwayland
, pkg-config
, wrapQtAppsHook
, glibmm
, gtest
}:

stdenv.mkDerivation rec {
  pname = "dde-clipboard";
  version = "6.0.4.999";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "ca671ae2e3ac2f9370645db363b9d6acfe97cfc8";
    hash = "sha256-O27Ioye3++4BsyYHe48AqXFjESxmFF+q7WX5U3xhnjo=";
  };

  postPatch = ''
    substituteInPlace misc/{dde-clipboard.desktop,dde-clipboard-daemon.service,org.deepin.dde.Clipboard1.service} \
      --replace "/usr/bin/qdbus" "${lib.getBin qttools}/bin/qdbus" \
      --replace "/usr" "$out"
  '';

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
    pkg-config
    qttools
    wrapQtAppsHook
  ];

  buildInputs = [
    dtkwidget
    gio-qt
    wayland
    kwayland
    dwayland
    glibmm
    gtest
  ];

  cmakeFlags = [
    "-DSYSTEMD_USER_UNIT_DIR=${placeholder "out"}/lib/systemd/user"
  ];

  meta = with lib; {
    description = "DDE optional clipboard manager componment";
    homepage = "https://github.com/linuxdeepin/dde-clipboard";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = teams.deepin.members;
  };
}
