{}: let
  pkgs = import <nixpkgs> {};
  unstablePkgs = import <nixos-unstable> {};

  lib = pkgs.lib;
  stdenv = pkgs.stdenv;

  config = import <config> {};
  configPath = builtins.getEnv "NIXOS_CONFIGURATION_DIR" + "/.";
  currentDir = ./.;
in
  pkgs.mkShell {
    buildInputs = with unstablePkgs; [
      busybox
      openblas
      libpng
      lapack
      gnumake
      fftwFloat
      pkg-config
      clang-tools
	  jq
    ];

    PARALLEL = 1;
    PARALLEL_NJOBS = 16;

    shellHook = ''
      echo "Welcome to the BART compilation shell"
      export PS1="\\[\\033[1;36m\\][\\u@BART(\\h):\\w]$\\[\\033[0m\\] "
    '';
  }
