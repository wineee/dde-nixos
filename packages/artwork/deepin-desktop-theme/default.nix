{ stdenv
, lib
, fetchFromGitHub
, cmake
, gtk3
, xcursorgen
, papirus-icon-theme
, breeze-icons
, hicolor-icon-theme
, deepin-icon-theme
}:

stdenv.mkDerivation rec {
  pname = "deepin-desktop-theme";
  version = "1.0.8.999";

  src = fetchFromGitHub {
    owner = "felixonmars";
    repo = pname;
    rev = "b07fa5b706db490713b0849056a2e2b5a762d1eb";
    hash = "sha256-gp+CkIVocvUnrroUfNkD7/xcXaZsilUOxao8JMk1uqw=";
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
    hicolor-icon-theme
    deepin-icon-theme
  ];

  dontDropIconThemeCache = true;

  postFixup = ''
    rm -r $out/share/icons/flow
    for theme in $out/share/icons/*; do
      gtk-update-icon-cache $theme
    done
  '';

  meta = with lib; {
    description = "deepin desktop theme";
    homepage = "https://github.com/linuxdeepin/deepin-icon-theme";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = teams.deepin.members;
  };
}
