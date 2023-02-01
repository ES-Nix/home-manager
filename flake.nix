{
  description = "Home Manager configuration of Ubuntu for vagrant user";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs
    home-manager.url = "github:nix-community/home-manager";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
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
        pkgs = pkgs; # nixpkgs.legacyPackages.${system};

        # defaultPackage.${system} = home-manager.defaultPackage.${system};

        modules = [
          # "${pkgs.path}/nixos/modules/virtualisation/qemu-vm.nix"

          {
            home = {
              inherit username;
              homeDirectory = "/Users/${username}";
              stateVersion = "22.11";
            };
            programs.home-manager.enable = true;
          }

          ./home.nix
          #{targets.genericLinux.enable = true;}

#          {
#            virtualisation.docker.enable = true;
#          }
        ];
        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
      };
    };
}
