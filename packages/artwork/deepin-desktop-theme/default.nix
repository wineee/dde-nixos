{ stdenv
, lib
, fetchFromGitHub
, cmake
, gtk3
, xcursorgen
, breeze-icons
, papirus-icon-theme
, deepin-icon-theme
}:

stdenv.mkDerivation rec {
  pname = "deepin-desktop-theme";
  version = "1.0.41";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "383e45e3272fe6a9a004caf47d4e1b45e08a15eb";
    sha256 = "sha256-93R+82tWT+LGz2YNGfI8IOzcfxZDXgYZEFG85ohl5iY=";
  };

  makeFlags = [ "PREFIX=${placeholder "out"}" ];

  nativeBuildInputs = [ 
    cmake
    gtk3
    xcursorgen
  ];

  propagatedBuildInputs = [
    breeze-icons
    papirus-icon-theme
    deepin-icon-theme
  ];

  dontDropIconThemeCache = true;

  postFixup = ''
    for theme in $out/share/icons/*; do
      gtk-update-icon-cache $theme
    done
  '';

  meta = with lib; {
    description = "deepin desktop theme";
    homepage = "https://github.com/linuxdeepin/deepin-icon-theme";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
