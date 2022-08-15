{ stdenv
, lib
, fetchFromGitHub
, dtk
, qt5integration
, qt5platform-plugins
, qmake
, qttools
, pkgconfig
, wrapQtAppsHook
}:

stdenv.mkDerivation rec {
  pname = "deepin-shortcut-viewer";
  version = "5.0.3";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-/VAT05ykFUCo4wBlylHbmgZ8Z9ptG2BCZo8ew3A4pkU=";
  };

  nativeBuildInputs = [
    qmake
    qttools
    pkgconfig
    wrapQtAppsHook
  ];

  buildInputs = [ dtk ];

  qmakeFlags = [
    "VERSION=${version}"
    "PREFIX=${placeholder "out"}"
  ];

  # qtWrapperArgs = [
  #   "--prefix QT_PLUGIN_PATH : ${qt5integration}/plugins"
  #   "--prefix QT_QPA_PLATFORM_PLUGIN_PATH : ${qt5platform-plugins}/plugins"
  # ];

  postPatch = ''
    substituteInPlace view/shortcutscene.cpp \
      --replace "/usr/share/deepin-shortcut-viewer\n" "$out/share/deepin-shortcut-viewer\n"
  '';

  meta = with lib; {
    description = "Deepin Shortcut Viewer";
    homepage = "https://github.com/linuxdeepin/deepin-shortcut-viewer";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
