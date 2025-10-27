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

  preBuild = ''
    export HOME=$TMP
    ${godot}/bin/godot --headless --dump-extension-api
  '';

  sconsFlags = [
    "platform=linux"
    "custom_api_file=./extension_api.json"
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out"/bin
    cp -r bin/* "$out"/bin
    cp ./extension_api.json $out

    runHook postInstall
  '';
}
