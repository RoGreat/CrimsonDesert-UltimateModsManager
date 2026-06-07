{
  cdumm-native,
  copyDesktopItems,
  imagemagick,
  lib,
  makeDesktopItem,
  privatebin,
  pyside6-fluent-widgets,
  python3Packages,
  xvfb,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "crimsondesert-ultimatemodsmanager";
  version = "3.3.17";
  pyproject = true;

  src = ./.;

  build-system = with python3Packages; [
    setuptools
  ];

  pythonRemoveDeps = [
    "pyside6-essentials"
  ];

  dependencies = with python3Packages; [
    bsdiff4
    cdumm-native
    cryptography
    lxml
    lz4
    privatebin
    psutil
    py7zr
    pyside6
    pyside6-fluent-widgets
    websocket-client
    xxhash
  ];

  nativeCheckInputs = [
    xvfb
  ]
  ++ (with python3Packages; [
    pytestCheckHook
    pytest-qt
    pytest-xvfb
  ]);

  disabledTestPaths = [
    "tests/test_pamt_cache_honors_cdmods_path.py::test_pamt_cache_uses_parent_when_called_with_vanilla"
    "tests/test_pamt_cache_honors_cdmods_path.py::test_pamt_cache_uses_pointer_for_real_game_dir"
    "tests/test_platform.py::TestOpenPathErrorLogging::test_oserror_logs_path_and_reason"
    "tests/test_transactional_io_absolute_path_guard.py::test_stage_file_rejects_absolute_path"
  ];

  nativeBuildInputs = [
    copyDesktopItems
    imagemagick
  ];

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

  prePatch = ''
    cat >> pyproject.toml << EOL

    [project.scripts]
    cdumm = "cdumm.main:main"
    EOL

    substituteInPlace src/cdumm/engine/nxm_handler.py \
        --replace-fail "{exe} -m" \
        "env PYTHONPATH=@out@/${python3Packages.python.sitePackages}:@PYTHONPATH@ {exe} -m" \
            --subst-var out \
            --subst-var PYTHONPATH
  '';

  postInstall = ''
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

  preFixup = ''
    makeWrapperArgs+=(
      --prefix PYTHONPATH : "$out/${python3Packages.python.sitePackages}:$PYTHONPATH"
    )
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
