{ stdenv
, lib
, fetchFromGitHub
, dde-api
}:

stdenv.mkDerivation rec {
  pname = "deepin-wallpapers";
  version = "unstable-2023-04-07";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = "fbd128d87d110c219535fddbf9db6da7d37ef451";
    sha256 = "sha256-qprdzUMXTlAPcWU5pLG00JwxWn5lvORTt63qWSm/IX0=";
  };

  nativeBuildInputs = [ dde-api ];

  postPatch = ''
    substituteInPlace Makefile \
      --replace /usr/lib/deepin-api/image-blur ${dde-api}/lib/deepin-api/image-blur
  '';

  installPhase = ''
    mkdir -p $out/share/wallpapers/deepin
    cp deepin/* $out/share/wallpapers/deepin

    mkdir -p $out/share/wallpapers/image-blur
    cp image-blur/* $out/share/wallpapers/image-blur

    mkdir -p $out/share/backgrounds

    ln -s $out/share/wallpapers/deepin/desktop.jpg  $out/share/backgrounds/default_background.jpg
  '';

  meta = with lib; {
    description = "deepin-wallpapers provides wallpapers of dde";
    homepage = "https://github.com/linuxdeepin/deepin-wallpapers";
    license = with licenses; [ gpl3Plus cc-by-sa-30 ];
    platforms = platforms.linux;
    maintainers = teams.deepin.members;
  };
}
