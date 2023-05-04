{ stdenv
, lib
, fetchFromGitHub
, dtkwidget
, qt5integration
, qt5platform-plugins
, dde-qt-dbus-factory
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
  version = "6.0.4";

  src = fetchFromGitHub {
    owner = "linuxdeepin";
    repo = pname;
    rev = version;
    sha256 = "sha256-FT4gXZJQOkXiAkEGaOsho7OCaamo7TRmnTvcIVLrJKg=";
  };

  # https://github.com/linuxdeepin/dde-clipboard/pull/132
  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace "/etc/xdg" "$out/etc/xdg" \
      --replace "/lib/systemd/user" "$out/lib/systemd/user" \
      --replace "/usr/share" "$out/share"

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
    qt5integration
    qt5platform-plugins
    dde-qt-dbus-factory
    gio-qt
    wayland
    kwayland
    dwayland
    glibmm
    gtest
  ];

  # cmakeFlags = [
  #   "-DUSE_DEEPIN_WAYLAND=OFF"
  # ];

  meta = with lib; {
    description = "DDE optional clipboard manager componment";
    homepage = "https://github.com/linuxdeepin/dde-clipboard";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = teams.deepin.members;
  };
}