{ stdenv
, lib
, fetchFromGitHub
, fetchpatch
, cmake
, pkg-config
, wrapQtAppsHook
, qt5integration
, qt5platform-plugins
, qtbase
, dtkgui
, gsettings-qt
, gtk3
, kconfig
, kwindowsystem
, kglobalaccel
, xorg
, tzdata
, iconv
}:
stdenv.mkDerivation rec {
  pname = "deepin-service-manager";
  version = "1.0.3";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-gTzyQHFPyn2+A+o+4VYySDBCZftfG2WnTXuqzeF+QhA=";
  };

  postPatch = ''
    for file in $(grep -rl "/usr/bin/deepin-service-manager"); do
      substituteInPlace $file --replace "/usr/bin/deepin-service-manager" "$out/bin/deepin-service-manager"
    done
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    wrapQtAppsHook
  ];

  buildInputs = [
  ];

  cmakeFlags = [
  ];

  meta = with lib; {
    description = "Manage DBus service on Deepin";
    homepage = "https://github.com/linuxdeepin/deepin-service-manager";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = teams.deepin.members;
  };
}
