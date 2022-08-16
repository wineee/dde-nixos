{ stdenv
, lib
, fetchFromGitHub
, getPatchFrom
, dtk
, qt5integration
, qt5platform-plugins
, dde-qt-dbus-factory
, qmake
, pkgconfig
, qttools
, qtwebengine
, karchive
, poppler
, wrapQtAppsHook
, libchardet
, libspectre
, openjpeg
, djvulibre
, gtest
, qtbase
}:
let
  patchList = {
    # INSTALL
    "reader/reader.pro" = [ ];
    "htmltopdf/htmltopdf.pro" = [ ];
    "3rdparty/deepin-pdfium/src/src.pro" = [ ];
    # RUN
    "reader/document/Model.cpp" = [
      [ "/usr/lib/deepin-reader/htmltopdf" "$out/lib/deepin-reader/htmltopdf" ]
    ];
  };
in
stdenv.mkDerivation rec {
  pname = "deepin-reader";
  version = "5.10.16";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-2dDv8IvnysteRqOJRvHVRa8kRjI7EyGybASmEVTgurw=";
  };

  nativeBuildInputs = [
    qmake
    pkgconfig
    qttools
    wrapQtAppsHook
  ];

  buildInputs = [
    dtk
    dde-qt-dbus-factory
    qtwebengine
    karchive
    poppler
    libchardet
    libspectre
    djvulibre
    openjpeg
    gtest
  ];

  cmakeFlags = [ "-DVERSION=${version}" ];

  qtWrapperArgs = [
    "--prefix QT_PLUGIN_PATH : ${qt5integration}/${qtbase.qtPluginPrefix}"
  ];

  ## TODO: use pkg-config
  fixIncludePatch = ''
    substituteInPlace 3rdparty/deepin-pdfium/src/3rdparty/pdfium/pdfium.pri \
      --replace '/usr/include/openjpeg-2.4' "${openjpeg.dev}/include/openjpeg-2.4"

    substituteInPlace 3rdparty/deepin-pdfium/src/src.pro \
      --replace '/usr/include/chardet' "${libchardet}/include/chardet"
  '';

  postPatch = fixIncludePatch + getPatchFrom patchList;

  meta = with lib; {
    description = "a simple memo software with texts and voice recordings";
    homepage = "https://github.com/linuxdeepin/deepin-reader";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
