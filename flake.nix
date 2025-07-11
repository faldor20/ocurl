{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flakelight.url = "github:nix-community/flakelight";
  };

  outputs =
    { flakelight, ... }@inputs:
    flakelight ./. {
      inherit inputs;

      # default devshell
      devShell.packages =
        pkgs: with pkgs; [
          ocaml
          ocamlPackages.ocaml-lsp
          ocamlPackages.odoc
          ocamlPackages.ocamlformat
          ocamlPackages.lwt
          ocamlPackages.dune-configurator
          ocamlPackages.lwt_ppx
          gmp
          gmp.dev
          curl.dev
          pkg-config
        ];
      pname="ocurl";
      packages = pkgs:{
        default = { stdenv,pkgs }:
          pkgs.ocamlPackages.buildDunePackage {

            pname = "curl";
            version = "0.1.0";
            duneVersion = "3";
            src = ./.;
            buildInputs = [
              pkgs.curl.dev
              pkgs.pkg-config
              pkgs.ocamlPackages.lwt
              pkgs.ocamlPackages.dune-configurator
              pkgs.ocamlPackages.lwt_ppx
            ];
            strictDeps = true;
          };
        

      };
    };

}
