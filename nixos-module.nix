{ localFlake, withSystem }:
{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.programs.godot;
in
{
  options.programs.godot = {
    enable = mkEnableOption "godot";
    package = mkOption {
      type = types.attrs;
      default = withSystem pkgs.stdenv.hostPlatform.system ({ config, ... }: config.packages.default);
    };
    # https://github.com/godotengine/godot/blob/4.5-stable/SConstruct
    buildOptions = mkOption {
      type = types.submodule {
        options = {
          # Platform and target
          platform = mkOption {
            type = types.enum [
              "linuxbsd"
              "darwin"
            ];
            default = "linuxbsd";
            description = "Target platform";
          };

          target = mkOption {
            type = types.enum [
              "editor"
              "template_release"
              "template_debug"
            ];
            default = "editor";
            description = "Compilation target";
          };

          arch = mkOption {
            type = types.enum [
              "auto"
              "x86_32"
              "x86_64"
              "arm32"
              "arm64"
            ];
            default = "auto";
            description = "CPU architecture";
          };

          dev_build = mkOption {
            type = types.bool;
            default = true;
            description = "Developer build with dev-only debugging code";
          };

          optimize = mkOption {
            type = types.enum [
              "auto"
              "none"
              "custom"
              "debug"
              "speed"
              "speed_trace"
              "size"
              "size_extra"
            ];
            default = "auto";
            description = "Optimization level";
          };

          debug_symbols = mkOption {
            type = types.bool;
            default = true;
            description = "Build with debugging symbols";
          };

          separate_debug_symbols = mkOption {
            type = types.bool;
            default = false;
            description = "Extract debugging symbols to a separate file";
          };

          debug_paths_relative = mkOption {
            type = types.bool;
            default = false;
            description = "Make file paths in debug symbols relative";
          };

          lto = mkOption {
            type = types.enum [
              "none"
              "auto"
              "thin"
              "full"
            ];
            default = "none";
            description = "Link-time optimization";
          };

          production = mkOption {
            type = types.bool;
            default = false;
            description = "Enable several options for production builds";
          };

          threads = mkOption {
            type = types.bool;
            default = true;
            description = "Enable threading support";
          };

          deprecated = mkOption {
            type = types.bool;
            default = false;
            description = "Enable compatibility code for deprecated/removed features";
          };

          precision = mkOption {
            type = types.enum [
              "single"
              "double"
            ];
            default = "single";
            description = "Floating-point precision level";
          };

          minizip = mkOption {
            type = types.bool;
            default = true;
            description = "Enable ZIP archive support using minizip";
          };

          brotli = mkOption {
            type = types.bool;
            default = true;
            description = "Enable Brotli for decompression and WOFF2 fonts";
          };

          xaudio2 = mkOption {
            type = types.bool;
            default = false;
            description = "Enable XAudio2 driver on supported platforms";
          };

          vulkan = mkOption {
            type = types.bool;
            default = true;
            description = "Enable Vulkan rendering driver";
          };

          opengl3 = mkOption {
            type = types.bool;
            default = true;
            description = "Enable OpenGL/GLES3 rendering driver";
          };

          d3d12 = mkOption {
            type = types.bool;
            default = false;
            description = "Enable Direct3D12 driver on supported platforms";
          };

          metal = mkOption {
            type = types.bool;
            default = false;
            description = "Enable Metal driver on Apple arm64 only";
          };

          use_volk = mkOption {
            type = types.bool;
            default = true;
            description = "Use volk to load Vulkan loader dynamically";
          };

          accesskit = mkOption {
            type = types.bool;
            default = true;
            description = "Use AccessKit C SDK";
          };

          accesskit_sdk_path = mkOption {
            type = types.str;
            default = "";
            description = "Path to AccessKit C SDK";
          };

          sdl = mkOption {
            type = types.bool;
            default = true;
            description = "Enable SDL3 input driver";
          };

          dev_mode = mkOption {
            type = types.bool;
            default = true;
            description = "Alias for dev options (verbose=true, warnings=extra, werror=true, tests=true, strict_checks=true)";
          };

          tests = mkOption {
            type = types.bool;
            default = true;
            description = "Build unit tests";
          };

          fast_unsafe = mkOption {
            type = types.bool;
            default = false;
            description = "Enable unsafe options for faster rebuilds";
          };

          ninja = mkOption {
            type = types.bool;
            default = false;
            description = "Use ninja backend for faster rebuilds";
          };

          ninja_auto_run = mkOption {
            type = types.bool;
            default = true;
            description = "Run ninja automatically after generating ninja file";
          };

          ninja_file = mkOption {
            type = types.str;
            default = "build.ninja";
            description = "Path to generated ninja file";
          };

          compiledb = mkOption {
            type = types.bool;
            default = false;
            description = "Generate compilation DB (`compile_commands.json`) for external tools";
          };

          num_jobs = mkOption {
            type = types.str;
            default = "";
            description = "Use up to N jobs when compiling (equivalent to `-j N`). Defaults to max jobs - 1. Ignored if -j is used.";
          };

          verbose = mkOption {
            type = types.bool;
            default = true;
            description = "Enable verbose compilation output";
          };

          progress = mkOption {
            type = types.bool;
            default = true;
            description = "Show progress indicator during compilation";
          };

          warnings = mkOption {
            type = types.enum [
              "all"
              "moderate"
              "no"
              "extra"
            ];
            default = "extra";
            description = "Compilation warning level";
          };

          werror = mkOption {
            type = types.bool;
            default = false;
            description = "Treat warnings as errors";
          };

          extra_suffix = mkOption {
            type = types.str;
            default = "";
            description = "Extra suffix for generated binaries";
          };

          object_prefix = mkOption {
            type = types.str;
            default = "";
            description = "Prefix for object file names";
          };

          vsproj = mkOption {
            type = types.bool;
            default = false;
            description = "Generate Visual Studio solution";
          };

          vsproj_name = mkOption {
            type = types.str;
            default = "godot";
            description = "Visual Studio solution name";
          };

          import_env_vars = mkOption {
            type = types.str;
            default = "";
            description = "Comma-separated environment variables to import";
          };

          disable_exceptions = mkOption {
            type = types.bool;
            default = true;
            description = "Force disable exception handling code";
          };

          disable_3d = mkOption {
            type = types.bool;
            default = false;
            description = "Disable 3D nodes";
          };

          disable_advanced_gui = mkOption {
            type = types.bool;
            default = false;
            description = "Disable advanced GUI nodes";
          };

          disable_physics_2d = mkOption {
            type = types.bool;
            default = false;
            description = "Disable 2D physics nodes";
          };

          disable_physics_3d = mkOption {
            type = types.bool;
            default = false;
            description = "Disable 3D physics nodes";
          };

          disable_navigation_2d = mkOption {
            type = types.bool;
            default = false;
            description = "Disable 2D navigation features";
          };

          disable_navigation_3d = mkOption {
            type = types.bool;
            default = false;
            description = "Disable 3D navigation features";
          };

          disable_xr = mkOption {
            type = types.bool;
            default = true;
            description = "Disable XR nodes and server";
          };

          build_profile = mkOption {
            type = types.str;
            default = "";
            description = "Path to feature build profile file";
          };

          custom_modules = mkOption {
            type = types.str;
            default = "";
            description = "Comma-separated list of custom modules";
          };

          custom_modules_recursive = mkOption {
            type = types.bool;
            default = true;
            description = "Detect custom modules recursively";
          };

          no_editor_splash = mkOption {
            type = types.bool;
            default = true;
            description = "Disable custom editor splash screen";
          };

          system_certs_path = mkOption {
            type = types.str;
            default = "";
            description = "Path to TLS certificates for editor/export templates";
          };

          use_precise_math_checks = mkOption {
            type = types.bool;
            default = false;
            description = "Use very precise epsilon in math checks";
          };

          strict_checks = mkOption {
            type = types.bool;
            default = true;
            description = "Enable stricter debug checks";
          };

          scu_build = mkOption {
            type = types.bool;
            default = false;
            description = "Use single compilation unit build";
          };

          scu_limit = mkOption {
            type = types.str;
            default = "0";
            description = "Max includes per SCU file (RAM usage)";
          };

          engine_update_check = mkOption {
            type = types.bool;
            default = false;
            description = "Enable engine update checks";
          };

          steamapi = mkOption {
            type = types.bool;
            default = false;
            description = "Enable minimal SteamAPI integration";
          };

          cache_path = mkOption {
            type = types.str;
            default = "";
            description = "Directory for SCons cache files";
          };

          cache_limit = mkOption {
            type = types.str;
            default = "0";
            description = "Limit for SCons cache";
          };

          redirect_build_objects = mkOption {
            type = types.bool;
            default = false;
            description = "Redirect build objects/libraries to bin/obj/";
          };

          # Built-in libraries
          builtin_brotli = mkOption {
            type = types.bool;
            default = false;
            description = "Use built-in Brotli library";
          };
          builtin_certs = mkOption {
            type = types.bool;
            default = false;
            description = "Use built-in SSL certificates";
          };
          builtin_clipper2 = mkOption {
            type = types.bool;
            default = true;
            description = "Use built-in Clipper2 library";
          };
          builtin_embree = mkOption {
            type = types.bool;
            default = false;
            description = "Use built-in Embree library";
          };
          builtin_enet = mkOption {
            type = types.bool;
            default = false;
            description = "Use built-in ENet library";
          };
          builtin_freetype = mkOption {
            type = types.bool;
            default = false;
            description = "Use built-in FreeType library";
          };
          builtin_msdfgen = mkOption {
            type = types.bool;
            default = true;
            description = "Use built-in MSDFgen library";
          };
          builtin_glslang = mkOption {
            type = types.bool;
            default = false;
            description = "Use built-in glslang library";
          };
          builtin_graphite = mkOption {
            type = types.bool;
            default = false;
            description = "Use built-in Graphite library";
          };
          builtin_harfbuzz = mkOption {
            type = types.bool;
            default = false;
            description = "Use built-in HarfBuzz library";
          };
          builtin_sdl = mkOption {
            type = types.bool;
            default = false;
            description = "Use built-in SDL library";
          };
          builtin_icu4c = mkOption {
            type = types.bool;
            default = false;
            description = "Use built-in ICU library";
          };
          builtin_libjpeg_turbo = mkOption {
            type = types.bool;
            default = false;
            description = "Use built-in libjpeg-turbo library";
          };
          builtin_libogg = mkOption {
            type = types.bool;
            default = false;
            description = "Use built-in libogg library";
          };
          builtin_libpng = mkOption {
            type = types.bool;
            default = false;
            description = "Use built-in libpng library";
          };
          builtin_libtheora = mkOption {
            type = types.bool;
            default = false;
            description = "Use built-in libtheora library";
          };
          builtin_libvorbis = mkOption {
            type = types.bool;
            default = false;
            description = "Use built-in libvorbis library";
          };
          builtin_libwebp = mkOption {
            type = types.bool;
            default = false;
            description = "Use built-in libwebp library";
          };
          builtin_wslay = mkOption {
            type = types.bool;
            default = false;
            description = "Use built-in wslay library";
          };
          builtin_mbedtls = mkOption {
            type = types.bool;
            default = false;
            description = "Use built-in mbedTLS library";
          };
          builtin_miniupnpc = mkOption {
            type = types.bool;
            default = false;
            description = "Use built-in miniupnpc library";
          };
          builtin_openxr = mkOption {
            type = types.bool;
            default = false;
            description = "Use built-in OpenXR library";
          };
          builtin_pcre2 = mkOption {
            type = types.bool;
            default = false;
            description = "Use built-in PCRE2 library";
          };
          builtin_pcre2_with_jit = mkOption {
            type = types.bool;
            default = false;
            description = "Use JIT compiler for PCRE2 library";
          };
          builtin_recastnavigation = mkOption {
            type = types.bool;
            default = false;
            description = "Use built-in Recast navigation library";
          };
          builtin_rvo2_2d = mkOption {
            type = types.bool;
            default = true;
            description = "Use built-in RVO2 2D library";
          };
          builtin_rvo2_3d = mkOption {
            type = types.bool;
            default = true;
            description = "Use built-in RVO2 3D library";
          };
          builtin_xatlas = mkOption {
            type = types.bool;
            default = true;
            description = "Use built-in xatlas library";
          };
          builtin_zlib = mkOption {
            type = types.bool;
            default = false;
            description = "Use built-in zlib library";
          };
          builtin_zstd = mkOption {
            type = types.bool;
            default = false;
            description = "Use built-in Zstd library";
          };

          # Compiler and linker flags
          ccflags = mkOption {
            type = types.str;
            default = "-fno-strict-aliasing";
            description = "Custom C/C++ compiler flags";
          };
          cppdefines = mkOption {
            type = types.str;
            default = "";
            description = "Custom preprocessor defines";
          };
          cxxflags = mkOption {
            type = types.str;
            default = "";
            description = "Custom C++ compiler flags";
          };
          cflags = mkOption {
            type = types.str;
            default = "";
            description = "Custom C compiler flags";
          };
          linkflags = mkOption {
            type = types.str;
            default = "-Wl,--build-id";
            description = "Custom linker flags";
          };
          asflags = mkOption {
            type = types.str;
            default = "";
            description = "Custom assembler flags";
          };
          arflags = mkOption {
            type = types.str;
            default = "";
            description = "Custom archive flags";
          };
          rcflags = mkOption {
            type = types.str;
            default = "";
            description = "Custom Windows resource compiler flags";
          };

          c_compiler_launcher = mkOption {
            type = types.str;
            default = "";
            description = "C compiler launcher";
          };
          cpp_compiler_launcher = mkOption {
            type = types.str;
            default = "";
            description = "C++ compiler launcher";
          };

          # Linux/BSD platform options
          use_llvm = mkOption {
            type = types.bool;
            default = false;
            description = "Use LLVM compiler";
          };
          use_static_cpp = mkOption {
            type = types.bool;
            default = true;
            description = "Link libgcc/libstdc++ statically";
          };
          use_coverage = mkOption {
            type = types.bool;
            default = false;
            description = "Enable test coverage";
          };
          use_msan = mkOption {
            type = types.bool;
            default = false;
            description = "Enable UBSAN";
          };
          use_sowrap = mkOption {
            type = types.bool;
            default = false;
            description = "Dynamically load system libraries";
          };
          alsa = mkOption {
            type = types.bool;
            default = true;
            description = "Use ALSA";
          };
          pulseaudio = mkOption {
            type = types.bool;
            default = true;
            description = "Use PulseAudio";
          };
          dbus = mkOption {
            type = types.bool;
            default = true;
            description = "Use D-Bus";
          };
          speechd = mkOption {
            type = types.bool;
            default = true;
            description = "Use Speech Dispatcher";
          };
          fontconfig = mkOption {
            type = types.bool;
            default = true;
            description = "Use fontconfig";
          };
          udev = mkOption {
            type = types.bool;
            default = true;
            description = "Use udev";
          };
          x11 = mkOption {
            type = types.bool;
            default = true;
            description = "Enable X11 display";
          };
          wayland = mkOption {
            type = types.bool;
            default = true;
            description = "Enable Wayland display";
          };
          libdecor = mkOption {
            type = types.bool;
            default = true;
            description = "Enable libdecor";
          };
          touch = mkOption {
            type = types.bool;
            default = true;
            description = "Enable touch events";
          };
          execinfo = mkOption {
            type = types.bool;
            default = false;
            description = "Use libexecinfo where glibc not available";
          };

          # Godot modules
          modules_enabled_by_default = mkOption {
            type = types.bool;
            default = false;
            description = "Enable all modules by default (false = only explicit)";
          };

          module_mono_enabled = mkOption {
            type = types.bool;
            default = false;
            description = "C# support";
          };

          # Modules required for minimal editor build
          module_svg_enabled = mkOption {
            type = types.bool;
            default = true;
            description = "Enable svg module";
          };

          module_regex_enabled = mkOption {
            type = types.bool;
            default = true;
            description = "Enable regex module";
          };

          module_freetype_enabled = mkOption {
            type = types.bool;
            default = true;
            description = "Enable freetype module";
          };

          module_gltf_enabled = mkOption {
            type = types.bool;
            default = true;
            description = "Enable gltf module";
          };

          # TODO: maybe do something with these
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
        };

      };
      default = { };
      description = "scons flags";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      cfg.package.override
      (final: prev: {
        buildOptions = prev.buildOptions // cfg.buildOptions;
      })
    ];
  };
}
