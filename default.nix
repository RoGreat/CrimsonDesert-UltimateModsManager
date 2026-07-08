{
  cdumm-native,
  copyDesktopItems,
  imagemagick,
  lib,
  makeDesktopItem,
  privatebin,
  pyside6-fluent-widgets,
  python3Packages,
  qt6,
  xvfb,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "crimsondesert-ultimatemodsmanager";
  version = "3.5.0";
  pyproject = true;

  src = ./.;

  build-system = with python3Packages; [
    setuptools
  ];

  pythonRemoveDeps = [
    "pyside6-essentials"
  ];

  nativeBuildInputs = [
    copyDesktopItems
    imagemagick
    qt6.wrapQtAppsHook
  ];

  dependencies = [
    cdumm-native
    privatebin
    pyside6-fluent-widgets
    qt6.qtbase
  ]
  ++ (with python3Packages; [
    bsdiff4
    cryptography
    lxml
    lz4
    psutil
    py7zr
    pyside6
    websocket-client
    xxhash
  ]);

  nativeCheckInputs = [
    xvfb
  ]
  ++ (with python3Packages; [
    pytestCheckHook
    pytest-qt
    pytest-xvfb
  ]);

  doCheck = false;

  desktopItems = [
    (makeDesktopItem {
      name = "cdumm";
      desktopName = "CDUMM";
      genericName = "Mod Manager";
      comment = "Crimson Desert Ultimate Mods Manager";
      icon = "cdumm";
      exec = "cdumm";
      categories = [ "Utility" ];
    })
  ];

  postPatch = ''
    substituteInPlace src/cdumm/main.py \
        --replace-fail "Path(__file__).resolve().parents[2]" "Path(__file__).resolve().parents[1]"
    substituteInPlace src/cdumm/engine/nxm_handler.py \
        --replace-fail "{exe} -m cdumm.main" "cdumm"
  '';

  postInstall = ''
    mkdir -p $out/bin
    echo "#!/bin/sh" > $out/bin/cdumm
    echo "exec ${python3Packages.python.interpreter} $out/${python3Packages.python.sitePackages}/cdumm/main.py \"\$@\"" >> $out/bin/cdumm
    chmod +x $out/bin/cdumm

    cp -a src/cdumm/translations $out/${python3Packages.python.sitePackages}/cdumm
    cp -a schemas $out/${python3Packages.python.sitePackages}
    cp -a field_schema $out/${python3Packages.python.sitePackages}

    for i in 16 24 48 64 96 128 256 512 1024; do
        mkdir -p $out/share/icons/hicolor/''${i}x''${i}/apps
        magick assets/cdumm-logo.png -resize ''${i}x''${i}  \
            $out/share/icons/hicolor/''${i}x''${i}/apps/cdumm.png
    done
    cp -a assets $out/${python3Packages.python.sitePackages}
  '';

  dontWrapQtApps = true;

  preFixup = ''
    wrapQtApp $out/bin/cdumm --prefix PYTHONPATH : "$out/${python3Packages.python.sitePackages}:$PYTHONPATH"
  '';

  meta = {
    description = "Crimson Desert Ultimate Mods Manager";
    homepage = "https://github.com/faisalkindi/CrimsonDesert-UltimateModsManager";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ RoGreat ];
    mainProgram = "cdumm";
    platforms = lib.platforms.linux;
  };
})
