

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


### podman via home-manager


```bash
mkdir -p ~/.config/nixpkgs
cat << 'EOF' >> ~/.config/nixpkgs/home.nix
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    podman
    runc
    skopeo
    conmon
    slirp4netns
    shadow
  ];

  targets.genericLinux.enable = true;

  # https://beb.ninja/post/installing-podman/
  home.file."registries.conf" = {
    target = ".config/containers/registries.conf";
    text = ''
      [registries.search]
      registries = ['docker.io', 'registry.gitlab.com']
    '';
  };

  home.file."policy.json" = {
    target = ".config/containers/policy.json";
    text = ''
      {
          "default": [
              {
                 "type": "insecureAcceptAnything"
              }
          ],
          "transports":
            {
               "docker-daemon":
                  {
                     "": [{"type":"insecureAcceptAnything"}]
                  }
            }
      }
    '';
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
      };
    };
}
EOF

cd ~/.config/nixpkgs/

git init
git add .

$(nix build --impure --print-out-paths .#homeConfigurations.$USER.activationPackage)/activate

# Fancy/custom version
# export NIXPKGS_ALLOW_UNFREE=1; $(nix build --impure --print-out-paths "${DESTINATION_FOLDER}"#homeConfigurations.$USER.activationPackage)/activate

```

```bash
sudo chmod -v 4511 "$HOME"/.nix-profile/bin/new{u,g}idmap
podman ps
```

```bash
# Broken!
# services.docker.enable = true;
# pkgs.lib.fileSystems."/".neededForBoot = true;
# fileSystems."/".neededForBoot = true;
# virtualisation.podman.enable = true;
# services.cachix-agent = { enable = true; name = "foo-bar-cachix"; };

#programs = {
#    home-manager.enable = true;
#    gpg.enable = true;
#    fzf.enable = true;
#    jq.enable = true;
#    bat.enable = true;
#    command-not-found.enable = true;
#    dircolors.enable = true;
#    htop.enable = true;
#    info.enable = true;
#    exa.enable = true;
#};
```
