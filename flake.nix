{
  description = "Home Manager configuration of Ubuntu for ubuntu user";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs
    home-manager.url = "github:nix-community/home-manager";
    nixpkgs.url = "github:NixOS/nixpkgs/release-22.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      # username = "vagrant";
      username = "ubuntu";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        pkgs = pkgs;

        # defaultPackage.${system} = home-manager.defaultPackage.${system};

        modules = [
          # "${pkgs.path}/nixos/modules/virtualisation/qemu-vm.nix"

          {
            # nix repl --expr 'import <nixpkgs> {}'
            # :lf .#
            # :p homeConfigurations.ubuntu.config.nixpkgs
            home = {
              inherit username;
              homeDirectory = "/home/${username}";
              stateVersion = "22.05";

#              activation.test = home-manager.lib.hm.dag.entryAfter ["writeBoundary"] ''
#                # set -x
#                echo "Started activation.test, it may call sudo on first time"
#
#                # Hack, but work relly well
#                export PATH=/usr/bin:$PATH
#
#                if [ ! $(stat -c '%a' $(readlink "$HOME"/.nix-profile/bin/newuidmap)) -eq 4511 ]; then
#                  sudo chmod -v 4511 $(readlink "$HOME"/.nix-profile/bin/newuidmap)
#                fi
#
#                if [ ! $(stat -c '%a' $(readlink "$HOME"/.nix-profile/bin/newgidmap)) -eq 4511 ]; then
#                  sudo chmod -v 4511 $(readlink "$HOME"/.nix-profile/bin/newgidmap)
#                fi
#              '';
            };
            programs.home-manager.enable = true;
            # TODO: https://nix-community.github.io/home-manager/index.html#sec-install-standalone
            # programs.home-manager.useGlobalPkgs = true;
          }

          ./home.nix

        ];
        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
      };
    };
}
