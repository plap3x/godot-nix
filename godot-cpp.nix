{
  lib,
  pkgs,
  src,
  godot,
}:
with pkgs;
stdenv.mkDerivation rec {
  inherit src;
  name = "godot-cpp";
  enableParallelBuilding = true;
  nativeBuildInputs = [
    scons
  ];

  sconsFlags = [
    "platform=linux"
    # "custom_api_file=./extension_api.json"
    # "bits=64"
  ];

  installPhase = ''
    runHook preInstall

    # ${godot}/bin/godot --headless --dump-extension-api

    mkdir -p "$out"/bin
    cp -r bin/* "$out"/bin

    runHook postInstall
  '';
}
