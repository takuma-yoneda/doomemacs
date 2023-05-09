{
  # NOTE:
  # All this does is to provide a simple environment
  # that has emacs and the all other binaries necessary for extensions.
  description = "nix-doom-emacs shell";

  # References
  # - https://github.com/hlissner/dotfiles/blob/master/modules/editors/emacs.nix

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-22.11-darwin";
    # nix-doom-emacs.url = "github:nix-community/nix-doom-emacs";
    # nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    # nix-doom-emacs.url = "github:nix-community/nix-doom-emacs";
  };

  outputs = { self, ... }@inputs:
    let
      system = "aarch64-darwin";
      pkgs = import inputs.nixpkgs { inherit system; };
      doomDir = "~/.doom.d";
      emacsDir = "~/.emacs.d";
      doomLocalDir = "~/.doom-local";
      configDir = ./config;
      # doomPrivateDir = ./doom.d;
      # doom-emacs = inputs.nix-doom-emacs.packages.${system}.default.override {
      #   doomPrivateDir = ./doom.d;
      # };
      myPythonPackages = p: with p; [
        black
        nose
        pytest
        python-lsp-server
        black-macchiato  # Partial formatting

        # For the launguage server to aware
        flask
        imageio
        moviepy
        numpy
        pandas
        pyyaml
        requests
        scipy
        scikitimage
        torch
        tqdm
        matplotlib
        wandb

        # Notebook
        jupyter
      ] ++ python-lsp-server.optional-dependencies.all;

      # After running doom sync, we should also remove cache for spell-fu
      # `rm -rf ~/.emacs.d/.local/etc/spell-fu`
      # https://github.com/doomemacs/doomemacs/issues/4138#issuecomment-717689085
      myAspell = pkgs.aspellWithDicts (d: with d; [en en-science en-computers]);

    in {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs;
          [
            binutils
            openssh
            gnutls
            coreutils
            fd
            ffmpeg
            clang
            nixfmt

            emacs
            git

            editorconfig-core-c

            # Spel checker
            myAspell

            jq # JSON processor

            # Shell script
            shfmt # formatter
            shellcheck # Shell script linting

            sqlite

            (ripgrep.override {withPCRE2 = true;})  # Provides search functionality


            # Web development
            nodePackages.stylelint
            nodePackages.js-beautify
            nodePackages.eslint
            nodePackages.typescript-language-server
            nodePackages.dockerfile-language-server-nodejs

            # doom-emacs
            # python38Packages.python-lsp-server
            # python38Packages.python-lsp-server
            # python-language-server
            # python38Packages.python-language-server.optional-dependencies.all
            (python310.withPackages myPythonPackages)

            # Python packages
            # python310Packages.torch
            # python310Packages.numpy

            (pkgs.writeScriptBin "doom" ''
              export EMACSDIR="${emacsDir}"
              export DOOMDIR="${doomDir}"
              export DOOMLOCALDIR="${doomLocalDir}"
              exec $EMACSDIR/bin/doom "''${@}"
            '')
          ];

        # installPhase = ''
        #   echo "$out"
        #   mkdir -p "$out"
        #   doom sync
        # '';

        shellHook = ''
          export EMACSDIR="${emacsDir}"
          export DOOMDIR="${doomDir}"
          export DOOMLOCALDIR="${doomLocalDir}"
          export PATH=/Library/Frameworks/Python.framework/Versions/3.8/bin:$PATH  # Hack to use python outside of nix shell
          export GIT_CONFIG_GLOBAL="${configDir}"/gitconfig
          export HOME=/Users/yoneda
          doom sync
        '';
      };
    };
}
