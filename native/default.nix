{
  buildPythonPackage,
  rustPlatform,
}:

buildPythonPackage (finalAttrs: {
  pname = "cdumm-native";
  version = "0.1.0";
  pyproject = true;

  src = ./.;

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs)
      pname
      version
      src
      ;
    hash = "sha256-TVLNTlC2gKigeyyj09iH0MKOlmBIs6rCeeUHP+Nm3Ds=";
  };
  nativeBuildInputs = with rustPlatform; [
    cargoSetupHook
    maturinBuildHook
  ];
})
