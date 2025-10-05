{
  description = "Nix flake for Godot";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?rev=879bd460b3d3e8571354ce172128fbcbac1ed633";
    flake-parts.url = "github:hercules-ci/flake-parts?rev=758cf7296bee11f1706a574c77d072b8a7baa881";
    godot-45 = {
      url = "github:godotengine/godot/4.5";
      flake = false;
    };
    godot-cpp = {
      url = "github:godotengine/godot-cpp/godot-4.5-stable";
      flake = false;
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-parts,
      godot-45,
      godot-cpp,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      top@{
        self,
        withSystem,
        flake-parts-lib,
        ...
      }:
      let
        inherit (flake-parts-lib) importApply;
      in
      {
        imports = [ ];
        flake = {
          nixosModules.default = importApply ./module.nix {
            localFlake = self;
            inherit withSystem;
          };
        };
        systems = [
          "x86_64-linux"
        ];
        perSystem =
          {
            lib,
            pkgs,
            system,
            ...
          }:
          let
            mkSconsFlagsFromAttrSet = lib.mapAttrsToList (
              k: v: if builtins.isString v then "${k}=${v}" else "${k}=${builtins.toJSON v}"
            );

            editor = true;

            godot =
              with pkgs;
              stdenv.mkDerivation rec {
                name = "godot";
                src = inputs.godot-45;
                outputs = [
                  "out"
                ]
                ++ lib.optional (editor) "man";
                separateDebugInfo = true;

                # Set the build name which is part of the version. In official downloads, this
                # is set to 'official'. When not specified explicitly, it is set to
                # 'custom_build'. Other platforms packaging Godot (Gentoo, Arch, Flatpack
                # etc.) usually set this to their name as well.
                #
                # See also 'methods.py' in the Godot repo and 'build' in
                # https://docs.godotengine.org/en/stable/classes/class_engine.html#class-engine-method-get-version-info
                BUILD_NAME = "nix_flake";

                # From: https://github.com/godotengine/godot/blob/4.5-stable/SConstruct
                sconsFlags = mkSconsFlagsFromAttrSet ({
                  # Options from 'SConstruct'
                  platform = "linuxbsd"; # Target platform (maybe: darwin)
                  # Compilation target
                  target = "editor"; # "template_release", "template_debug"
                  # CPU architecture
                  arch = "auto"; # # x86_32 x86_64 arm32 arm64
                  # Developer build with dev-only debugging code (DEV_ENABLED)
                  dev_build = true;
                  # Optimization level (by default inferred from 'target' and 'dev_build')
                  optimize = "auto"; # none custom debug speed speed_trace size size_extra
                  # Build with debugging symbols
                  debug_symbols = true;
                  # Extract debugging symbols to a separate file
                  separate_debug_symbols = false;
                  # Make file paths in debug symbols relative (if supported)
                  debug_paths_relative = false;
                  # Link-time optimization (production builds)
                  lto = "none"; # auto thin full
                  # Set defaults to build Godot for use in production
                  production = false;
                  # Enable threading support
                  threads = true;
                  # Enable compatibility code for deprecated and removed features
                  deprecated = false;
                  # Set the floating-point precision level
                  precision = "single"; # double
                  # Enable ZIP archive support using minizip
                  minizip = true;
                  # Enable Brotli for decompression and WOFF2 fonts support
                  brotli = true;
                  # Enable the XAudio2 audio driver on supported platforms
                  xaudio2 = false;
                  # Enable the Vulkan rendering driver
                  vulkan = true;
                  # Enable the OpenGL/GLES3 rendering driver
                  opengl3 = true;
                  # Enable the Direct3D 12 rendering driver on supported platforms
                  d3d12 = false;
                  # Enable the Metal rendering driver on supported platforms (Apple arm64 only)
                  metal = false;
                  # Use the volk library to load the Vulkan loader dynamically
                  use_volk = true;
                  # Use AccessKit C SDK
                  accesskit = true;
                  # Path to the AccessKit C SDK
                  accesskit_sdk_path = "";
                  # Enable the SDL3 input driver
                  sdl = true;
                  # lias for dev options: verbose=yes warnings=extra werror=yes tests=yes strict_checks=yes
                  dev_mode = true;
                  # Build the unit tests
                  tests = true;
                  # Enable unsafe options for faster rebuilds
                  fast_unsafe = false;
                  # Use the ninja backend for faster rebuilds
                  ninja = false;
                  # Run ninja automatically after generating the ninja file
                  ninja_auto_run = true;
                  # Path to the generated ninja file
                  ninja_file = "build.ninja";
                  # Generate compilation DB (`compile_commands.json`) for external tools
                  compiledb = false;
                  # Use up to N jobs when compiling (equivalent to `-j N`). Defaults to max jobs - 1. Ignored if -j is used.
                  num_jobs = "";
                  # Enable verbose output for the compilation
                  verbose = true;
                  # Show a progress indicator during compilation
                  progress = true;
                  # Level of compilation warnings
                  warnings = "extra"; # all moderate no
                  # Treat compiler warnings as errors
                  werror = false;
                  # Custom extra suffix added to the base filename of all generated binary files
                  extra_suffix = "";
                  # Custom prefix added to the base filename of all generated object files
                  object_prefix = "";
                  # Generate a Visual Studio solution
                  vsproj = false;
                  # Name of the Visual Studio solution
                  vsproj_name = "godot";
                  # A comma-separated list of environment variables to copy from the outer environment.
                  import_env_vars = "";
                  # Force disabling exception handling code
                  disable_exceptions = true;
                  # Disable 3D nodes for a smaller executable
                  disable_3d = false;
                  # Disable advanced GUI nodes and behaviors
                  disable_advanced_gui = false;
                  # Disable 2D physics nodes and server
                  disable_physics_2d = false;
                  # Disable 3D physics nodes and server
                  disable_physics_3d = false;
                  # Disable 2D navigation features
                  disable_navigation_2d = false;
                  # Disable 3D navigation features
                  disable_navigation_3d = false;
                  # Disable XR nodes and server
                  disable_xr = true;
                  # Path to a file containing a feature build profile
                  build_profile = "";
                  # A list of comma-separated directory paths containing custom modules to build.
                  custom_modules = "";
                  # Detect custom modules recursively for each specified path.
                  custom_modules_recursive = true;
                  # If no, disable all modules except ones explicitly enabled
                  modules_enabled_by_default = false;
                  # Don't use the custom splash screen for the editor
                  no_editor_splash = true;
                  # Use this path as TLS certificates default for editor and Linux/BSD export templates (for package maintainers)
                  system_certs_path = "";
                  # Math checks use very precise epsilon (debug option)
                  use_precise_math_checks = false;
                  # Enforce stricter checks (debug option)
                  strict_checks = true;
                  # Use single compilation unit build
                  scu_build = false;
                  # Max includes per SCU file when using scu_build (determines RAM use)
                  scu_limit = "0";
                  # Enable engine update checks in the Project Manager
                  engine_update_check = false;
                  # Enable minimal SteamAPI integration for usage time tracking (editor only)
                  steamapi = false;
                  # Path to a directory where SCons cache files will be stored. No value disables the cache.
                  cache_path = "";
                  # Path to a directory where SCons cache files will be stored. No value disables the cache.
                  cache_limit = "0";
                  # Enable redirecting built objects/libraries to `bin/obj/` to declutter the repository.
                  redirect_build_objects = false;
                  # Use the built-in Brotli library
                  builtin_brotli = false;
                  # Use the built-in SSL certificates bundles
                  builtin_certs = false;
                  # Use the built-in Clipper2 library
                  builtin_clipper2 = true;
                  # Use the built-in Embree library
                  builtin_embree = false;
                  # Use the built-in ENet library
                  builtin_enet = false;
                  # Use the built-in FreeType library
                  builtin_freetype = false;
                  # Use the built-in MSDFgen library
                  builtin_msdfgen = true;
                  # Use the built-in glslang library
                  builtin_glslang = false;
                  # Use the built-in Graphite library
                  builtin_graphite = false;
                  # Use the built-in HarfBuzz library
                  builtin_harfbuzz = false;
                  # Use the built-in SDL library
                  builtin_sdl = false;
                  # Use the built-in ICU library
                  builtin_icu4c = false;
                  # Use the built-in libjpeg-turbo library
                  builtin_libjpeg_turbo = false;
                  # Use the built-in libogg library
                  builtin_libogg = false;
                  # Use the built-in libpng library
                  builtin_libpng = false;
                  # Use the built-in libtheora library
                  builtin_libtheora = false;
                  # Use the built-in libvorbis library
                  builtin_libvorbis = false;
                  # Use the built-in libwebp library
                  builtin_libwebp = false;
                  # Use the built-in wslay library
                  builtin_wslay = false;
                  # Use the built-in mbedTLS library
                  builtin_mbedtls = false;
                  # Use the built-in miniupnpc library
                  builtin_miniupnpc = false;
                  # Use the built-in OpenXR library
                  builtin_openxr = false;
                  # Use the built-in PCRE2 library
                  builtin_pcre2 = false;
                  # Use JIT compiler for the built-in PCRE2 library
                  builtin_pcre2_with_jit = false;
                  # Use the built-in Recast navigation library
                  builtin_recastnavigation = false;
                  # Use the built-in RVO2 2D library
                  builtin_rvo2_2d = true;
                  # Use the built-in RVO2 3D library
                  builtin_rvo2_3d = true;
                  # Use the built-in xatlas library
                  builtin_xatlas = true;
                  # Use the built-in zlib library
                  builtin_zlib = false;
                  # Use the built-in Zstd library
                  builtin_zstd = false;
                  # Compilation environment setup
                  # CXX, CC, and LINK directly set the equivalent `env` values (which may still
                  # be overridden for a specific platform), the lowercase ones are appended.
                  # C++ compiler binary
                  # CXX = "";
                  # C compiler binary
                  # CC = "";
                  # Linker binary
                  # LINK = "";
                  # Custom flags for both the C and C++ compilers
                  # aliasing bugs exist with hardening+LTO
                  # https://github.com/godotengine/godot/pull/104501
                  ccflags = "-fno-strict-aliasing";
                  # Custom defines for the pre-processor
                  cppdefines = "";
                  # Custom flags for the C++ compiler
                  cxxflags = "";
                  # Custom flags for the C compiler
                  cflags = "";
                  # Custom flags for the linker
                  # aliasing bugs exist with hardening+LTO
                  # https://github.com/godotengine/godot/pull/104501
                  linkflags = "-Wl,--build-id";
                  # Custom flags for the assembler
                  asflags = "";
                  # Custom flags for the archive tool
                  arflags = "";
                  # Custom flags for Windows resource compiler
                  rcflags = "";
                  # C compiler launcher (e.g. `ccache`)
                  c_compiler_launcher = "";
                  # C++ compiler launcher (e.g. `ccache`)
                  cpp_compiler_launcher = "";

                  # Options from 'platform/linuxbsd/detect.py'
                  # Linker program
                  linker = "default"; # bfd gold lld mold
                  # Use the LLVM compiler
                  use_llvm = false;
                  # Link libgcc and libstdc++ statically for better portability
                  use_static_cpp = true;
                  # Test Godot coverage
                  use_coverage = false;
                  # Use LLVM/GCC compiler undefined behavior sanitizer (UBSANmodule_
                  use_msan = false;
                  # Dynamically load system libraries
                  use_sowrap = false;
                  # Use ALSA
                  alsa = true;
                  # Use PulseAudio
                  pulseaudio = true;
                  # Use D-Bus to handle screensaver and portal desktop settings
                  dbus = true;
                  # Use Speech Dispatcher for Text-to-Speech support
                  speechd = true;
                  # Use fontconfig for system fonts support
                  fontconfig = true;
                  # Use udev for gamepad connection callbacks
                  udev = true;
                  # Enable X11 display
                  x11 = true;
                  # Enable Wayland display
                  wayland = true;
                  # Enable libdecor support
                  libdecor = true;
                  # Enable touch events
                  touch = true;
                  # Use libexecinfo on systems where glibc is not available
                  execinfo = false;

                  module_mono_enabled = false;

                  # for editor
                  module_svg_enabled = true;
                  module_regex_enabled = true;
                  module_freetype_enabled = true;
                  module_gltf_enabled = true;

                  # libraries that aren't available in nixpkgs
                  # builtin_msdfgen = true;
                  # builtin_rvo2_2d = true;
                  # builtin_rvo2_3d = true;
                  # builtin_xatlas = true;

                  # using system clipper2 is currently not implemented
                  # builtin_clipper2 = true;

                  # builtin_squish = true; # godot<4.4
                  # broken with system packages
                  # builtin_miniupnpc = true; # godot<4.4
                });

                enableParallelBuilding = true;
                strictDeps = true;

                patches = [
                  ./Linux-fix-missing-library-with-builtin_glslang-false.patch
                  ./fix-freetype-link-error.patch
                ];

                postPatch = ''
                  # this stops scons from hiding e.g. NIX_CFLAGS_COMPILE
                  perl -pi -e '{ $r += s:(env = Environment\(.*):\1\nenv["ENV"] = os.environ: } END { exit ($r != 1) }' SConstruct

                  # # disable all builtin libraries by default
                  # perl -pi -e '{ $r |= s:(opts.Add\(BoolVariable\("builtin_.*, )True(\)\)):\1False\2: } END { exit ($r != 1) }' SConstruct

                  substituteInPlace platform/linuxbsd/detect.py \
                    --replace-fail /usr/include/recastnavigation ${lib.escapeShellArg (lib.getDev recastnavigation)}/include/recastnavigation

                  substituteInPlace thirdparty/glad/egl.c \
                    --replace-fail \
                      'static const char *NAMES[] = {"libEGL.so.1", "libEGL.so"}' \
                      'static const char *NAMES[] = {"${lib.getLib libGL}/lib/libEGL.so"}'

                  substituteInPlace thirdparty/glad/gl.c \
                    --replace-fail \
                      'static const char *NAMES[] = {"libGLESv2.so.2", "libGLESv2.so"}' \
                      'static const char *NAMES[] = {"${lib.getLib libGL}/lib/libGLESv2.so"}' \

                  substituteInPlace thirdparty/glad/gl{,x}.c \
                    --replace-fail \
                      '"libGL.so.1"' \
                      '"${lib.getLib libGL}/lib/libGL.so"'

                  substituteInPlace thirdparty/volk/volk.c \
                    --replace-fail \
                      'dlopen("libvulkan.so.1"' \
                      'dlopen("${lib.getLib vulkan-loader}/lib/libvulkan.so"'

                  substituteInPlace platform/linuxbsd/detect.py --replace 'pkg-config xi ' 'pkg-config xi xfixes '
                '';

                depsBuildBuild = lib.optionals (stdenv.buildPlatform != stdenv.hostPlatform) [
                  buildPackages.stdenv.cc
                  pkg-config
                ];

                buildInputs = [
                  embree
                  enet
                  freetype
                  glslang
                  graphite2
                  (harfbuzz.override { withIcu = true; })
                  icu
                  libtheora
                  libwebp
                  mbedtls
                  miniupnpc
                  openxr-loader
                  pcre2
                  recastnavigation
                  wslay
                  zstd

                  # optional
                  alsa-lib
                  libxkbcommon
                  xorg.libX11
                  xorg.libXcursor
                  xorg.libXext
                  xorg.libXfixes
                  xorg.libXi
                  xorg.libXinerama
                  xorg.libXrandr
                  xorg.libXrender
                  libdecor
                  wayland
                  dbus
                  fontconfig
                  libpulseaudio
                  speechd-minimal
                  glib
                  udev
                  libjpeg_turbo
                  sdl3
                ];

                nativeBuildInputs = [
                  installShellFiles
                  perl
                  pkg-config
                  scons
                  embree
                  glslang
                  recastnavigation

                  # optional
                  wayland-scanner
                ];

                installPhase = ''
                  runHook preInstall

                  mkdir -p "$out"/{bin,libexec}
                  cp -r bin/* "$out"/libexec

                  cd "$out"/bin
                  ln -s ../libexec/godot.linuxbsd.editor.dev.x86_64 godot
                  cd -
                ''
                + (
                  if editor then
                    ''
                      installManPage misc/dist/linux/godot.6

                      mkdir -p "$out"/share/{applications,icons/hicolor/scalable/apps}
                      cp misc/dist/linux/org.godotengine.Godot.desktop \
                        "$out/share/applications/org.godotengine.Godot.desktop"

                      substituteInPlace "$out/share/applications/org.godotengine.Godot.desktop" \
                        --replace-fail "Exec=godot" "Exec=$out/bin/godot"

                      cp icon.svg "$out/share/icons/hicolor/scalable/apps/godot.svg"
                      cp icon.png "$out/share/icons/godot.png"
                    ''
                  else
                    ''''
                )
                + ''
                  runHook postInstall
                '';

                requiredSystemFeatures = [
                  # fixes: No space left on device
                  "big-parallel"
                ];

                meta = {
                  changelog = "https://github.com/godotengine/godot/releases/tag/4.5";
                  description = "Free and Open Source 2D and 3D game engine";
                  homepage = "https://godotengine.org";
                  license = {
                    spdxId = "MIT";
                    fullName = "MIT License";
                  };
                  platforms = [
                    "x86_64-linux"
                    "aarch64-linux"
                    "i686-linux"
                  ];
                  mainProgram = "godot";
                };
              };
          in
          {
            packages.default = godot;

            devShells.default = pkgs.mkShell {
              packages = [
                godot
              ];
              env = { };
              shellHook = ''
                echo "Godot `godot --version`"
              '';
            };
          };
      }
    );
}
