{ stdenv
, lib
, fetchFromGitHub
, cmake
, pkg-config
, wrapQtAppsHook
, dde-qt-dbus-factory
, qtbase
, qtx11extras
, dtkwidget
, dde-polkit-agent
, fetchpatch
, gtest
}:

stdenv.mkDerivation rec {
  pname = "dde-widgets";
  version = "6.0.12";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-7qz+frsYs1XifcO+x0Q9nkc2wEoAQL/HOZV1fwAsTy8=";
  };

  patches = [
    (fetchpatch {
      url = "https://github.com/linuxdeepin/dde-widgets/commit/272bcab458e59219ce59fb6c802daa29efb1b90a.patch";
      sha256 = "sha256-z6ZLrPcE72JrQw7oWG8LuhpPrQku1TF5FkEOqfiFtJU=";
    })
    (fetchpatch {
      url = "https://github.com/linuxdeepin/dde-widgets/commit/d05630fa89448cb782bf30b5c2ef1ad3c98b8ab5.patch";
      sha256 = "sha256-VrrrVZoL4JO7REKBV0nriY9ORRixhEtiE+DF0xuziCI=";
    })
  ];

  postPatch = ''
    for file in $(grep -rl "/usr/bin"); do
      substituteInPlace $file --replace "/usr/bin" ""
    done
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    dde-qt-dbus-factory
    wrapQtAppsHook
  ];

  buildInputs = [
    qtbase
    qtx11extras
    dtkwidget
    gtest
  ];

  meta = with lib; {
    description = "Desktop widgets service/implementation for DDE";
    homepage = "https://github.com/linuxdeepin/dde-widgets";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = teams.deepin.members;
  };
}
