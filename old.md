

```bash
mkdir -p ~/.config/nixpkgs
cat << 'EOF' >> ~/.config/nixpkgs/home.nix
{ pkgs, ... }:

{

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  # home.username = "vagrant";
  # home.homeDirectory = "/home/vagrant";
  
  home.packages = with pkgs; [
    # btop
    # htop
    git
    openssh
    # vlc
  ];

  programs.direnv = {
    enable = true;
    nix-direnv = {
      enable = true;
    };
  };

  programs.home-manager = {
    enable = true;
  };
}
EOF


cat << 'EOF' >> ~/.config/nixpkgs/flake.nix
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
      username = "ubuntu";
    in {
      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};

        modules = [
          {
            home = {
              inherit username;
              homeDirectory = "/Users/${username}";
              stateVersion = "22.11";
            };
            programs.home-manager.enable = true;
          }
           ./home.nix
        ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
      };
    };
}
EOF

cd ~/.config/nixpkgs/

git init
git add .

$(nix build --impure --print-out-paths .#homeConfigurations.$USER.activationPackage)/activate
```


```bash
nix \
flake \
show \
github:nix-community/home-manager \
--no-write-lock-file
```


Broken, could not make it work:
```bash
nix \
profile \
install \
nixpkgs#home-manager
```


```bash
home-manager build --flake ~/.config/nixpkgs
```


```bash
HOME_MANAGER_STORE_PATH="$(nix eval --raw nixpkgs#home-manager)" \
&& nix profile remove "${HOME_MANAGER_STORE_PATH}" \
&& "${HOME_MANAGER_STORE_PATH}" switch
```
