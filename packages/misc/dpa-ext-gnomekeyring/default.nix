{ stdenv
, lib
, fetchFromGitHub
, dtk
, dde-polkit-agent
, qt5integration
, cmake
, pkgconfig
, qttools
, wrapQtAppsHook
, libsecret
, libgnome-keyring
}:

stdenv.mkDerivation rec {
  pname = "dpa-ext-gnomekeyring";
  version = "5.0.11";
  #TODO: /usr/share/dpa-ext-gnomekeyring/translations/dpa-ext-gnomekeyring_
  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-mXaGwbtEwaqfOT0izK64zX4s3VFmsRpUGOVm6oSEhn8=";
  };

  nativeBuildInputs = [
    cmake
    pkgconfig
    qttools
    wrapQtAppsHook
  ];

  buildInputs = [
    dtk
    dde-polkit-agent
    qt5integration
    libgnome-keyring
    libsecret
  ];

  meta = with lib; {
    description = "GNOME keyring extension for dde-polkit-agent";
    homepage = https://github.com/linuxdeepin/dpa-ext-gnomekeyring;
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
