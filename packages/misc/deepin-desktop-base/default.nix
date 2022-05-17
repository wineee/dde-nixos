{ stdenv
, lib
, fetchFromGitHub
, nixos-icons
}:
stdenv.mkDerivation rec {
  pname = "deepin-desktop-base";
  version = "2022.03.07";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-joAduRI9jUtPA4lNsEhgOZlci8j/cvD8rJThqvj6a8A=";
  };

  propagatedBuildInputs = [ nixos-icons ];

  makeFlags = [ "DESTDIR=${placeholder "out"}" ];

  distribution_info = ''
    [Distribution]
    Name=NixOS
    WebsiteName=www.nixos.org
    Website=https://www.nixos.org
    Logo=nix-snowflake.svg
    LogoLight=nix-snowflake-white.svg
    LogoTransparent=nix-snowflake.svg
  '';

  postInstall = ''
    # Remove Deepin distro's lsb-release
    rm $out/etc/lsb-release
    # Don't override systemd timeouts
    rm -r $out/etc/systemd
    rm -r $out/usr/share/python-apt
    rm -r $out/usr/share/plymouth
    rm -r $out/usr/share/distro-info
    echo -e ${lib.escapeShellArg distribution_info} > $out/usr/share/deepin/distribution.info
  '';

  meta = with lib; {
    description = "Base assets and definitions for Deepin Desktop Environment";
    homepage = "https://github.com/linuxdeepin/deepin-desktop-base";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
