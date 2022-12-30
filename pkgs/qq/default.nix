{ alsa-lib
, cups
, dpkg
, fetchurl
, gjs
, glib
, gtk3
, lib
, libdrm
, libgcrypt
, libkrb5
, mesa # for libgbm
, nss
, xorg
, systemd
, stdenv
, at-spi2-core
, autoPatchelfHook
, wrapGAppsHook
, copyDesktopItems
, makeDesktopItem
}:

let
  version = "3.0.0-565";
  srcs = {
    x86_64-linux = fetchurl {
      url = "https://dldir1.qq.com/qqfile/qq/QQNT/64bd2578/linuxqq_${version}_amd64.deb";
      sha256 = "sha256-IfBbheVwg4b5PuLX9bzqSuTcElxNaV3tmbGd3v/NkCY=";
    };
    aarch64-linux = fetchurl {
      url = "https://dldir1.qq.com/qqfile/qq/QQNT/64bd2578/linuxqq_${version}_arm64.deb";
      sha256 = "sha256-6IlAJdPknaQzOE48sdxb5QbB+ZF1xKstF3ARGHM30GY=";
    };
  };
  src = srcs.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation {
  pname = "qq";
  inherit version src;

  unpackCmd = "dpkg-deb -x $curSrc source";

  nativeBuildInputs = [
    autoPatchelfHook
    wrapGAppsHook
    copyDesktopItems
    dpkg
  ];

  buildInputs = [
    alsa-lib
    at-spi2-core
    cups
    libdrm
    libgcrypt
    libkrb5
    mesa
    nss
    xorg.libXdamage
  ];

  runtimeDependencies = [
    gtk3
    (lib.getLib systemd)
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp -r opt $out/opt
    cp -r usr/share $out/share
    substituteInPlace $out/share/applications/qq.desktop \
      --replace "/opt" "$out/opt" \
      --replace "/usr/share" "$out/share"
    ln -s $out/opt/QQ/qq $out/bin/qq
    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://im.qq.com/linuxqq/";
    description = "Messaging app";
    platforms = [ "x86_64-linux" "aarch64-linux" ];
    license = licenses.unfree;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ fee1-dead ];
  };
}