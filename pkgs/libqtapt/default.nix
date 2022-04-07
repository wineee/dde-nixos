{ stdenv
, lib
, fetchgit
, cmake
, extra-cmake-modules
, xapian
, apt
, polkit-qt
, pkgconfig
, wrapQtAppsHook
}:

stdenv.mkDerivation rec {
  pname = "libqtapt";
  version = "unstable-2022-01-05";

  src = fetchgit {
    url = "https://invent.kde.org/system/libqapt.git";
    rev = "37d5f3f3143b35cbcb203b6ad9a9a0a2b19cbf84";
    sha256 = "sha256-pOWRUP2ctT77Dn+zhNcAuW6+cIGKXtJufxY1DlLTjgU=";
  };

  nativeBuildInputs = [
    cmake
    pkgconfig
    wrapQtAppsHook
  ];

  buildInputs = [
    extra-cmake-modules
    xapian
    apt
    polkit-qt
  ];

  meta = with lib; {
    description = "A Qt wrapper library/APT implementation around the libapt-pkg library";
    homepage = "https://invent.kde.org/system/libqapt";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
  };
}
