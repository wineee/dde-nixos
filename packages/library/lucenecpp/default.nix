{ lib, stdenv, fetchFromGitHub, cmake, boost, gtest, zlib }:

stdenv.mkDerivation rec {
  pname = "lucene++";
  version = "3.0.8";

  src = fetchFromGitHub {
    owner = "luceneplusplus";
    repo = "LucenePlusPlus";
    rev = "rel_${version}";
    sha256 = "12v7r62f7pqh5h210pb74sfx6h70lj4pgfpva8ya2d55fn0qxrr2";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ boost gtest zlib ];

  postPatch = ''
    substituteInPlace src/test/CMakeLists.txt \
      --replace "add_subdirectory(gtest)" ""
    
    substituteInPlace src/config/core/liblucene++.pc.in \
      --replace "libdir=@LIB_DESTINATION@" "libdir=\''${prefix}/lib" \
      --replace "-L@LIB_DESTINATION@" "-L\''${libdir}"
    substituteInPlace src/config/contrib/liblucene++-contrib.pc.in \
      --replace "libdir=@LIB_DESTINATION@" "libdir=\''${prefix}/lib" \
      --replace "-L@LIB_DESTINATION@" "-L\''${libdir}"
  '';

  postInstall = ''
    mv $out/include/pkgconfig $out/lib/
    cp $src/src/contrib/include/*h $out/include/lucene++/
  '';

  meta = {
    description = "C++ port of the popular Java Lucene search engine";
    homepage = "https://github.com/luceneplusplus/LucenePlusPlus";
    license = with lib.licenses; [ asl20 lgpl3Plus ];
    platforms = lib.platforms.linux;
  };
}

