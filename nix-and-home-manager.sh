command -v curl || (command -v apt && sudo apt-get update && sudo apt-get install -y curl)
command -v curl || (command -v apk && sudo apk add --no-cache -y curl)

NIX_RELEASE_VERSION=2.10.2 \
&& curl -L https://releases.nixos.org/nix/nix-"${NIX_RELEASE_VERSION}"/install | sh -s -- --no-daemon \
&& . "$HOME"/.nix-profile/etc/profile.d/nix.sh

export NIX_CONFIG='extra-experimental-features = nix-command flakes'

nix \
shell \
github:NixOS/nixpkgs/f5ffd5787786dde3a8bf648c7a1b5f78c4e01abb#{git,bashInteractive,coreutils,gnused,home-manager} \
--command \
bash <<-EOF
{
  mkdir -pv /home/"$USER"/.config/nixpkgs \
  && ls -al /home/"$USER"/.config/nixpkgs

  tee /home/"$USER"/.config/nixpkgs/home.nix <<'NESTEDEOF'
  { pkgs, ... }:
  {

    home.packages = with pkgs; [
      coreutils
      curl
      fzf
      git
      jq
      neovim
      openssh
      shadow
      tmate
    ];

    nix = {
      enable = true;
      package = pkgs.nixVersions.nix_2_10;
      extraOptions = "experimental-features = nix-command flakes";
    };
    programs.home-manager = {
      enable = true;
    };
}
NESTEDEOF


tee /home/"$USER"/.config/nixpkgs/flake.nix <<'NESTEDEOF'
{
  description = "Home Manager configuration";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs
    home-manager.url = "github:nix-community/home-manager";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      username = "vagrant";
    in {
      homeConfigurations.\${username} = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.\${system};

        modules = [
          {
            home = {
              inherit username;
              # TODO: esse caminho muda no Mac!
              homeDirectory = "/home/\${username}";
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
NESTEDEOF
}

echo \
&& cd /home/"$USER"/.config/nixpkgs/ \
&& sed -i 's/username = ".*";/username = "'$USER'";/g' flake.nix \
&& git init \
&& git status \
&& git add . \
&& nix flake update --override-input nixpkgs github:NixOS/nixpkgs/f5ffd5787786dde3a8bf648c7a1b5f78c4e01abb \
&& git status \
&& git add .

# Estas linhas precisam das variáveis de ambiente USER e HOME
export NIXPKGS_ALLOW_UNFREE=1 \
&& home-manager switch -b backuphm --impure --flake ~/.config/nixpkgs \
&& home-manager generations
EOF

sudo reboot

# . "$HOME"/.nix-profile/etc/profile.d/nix.sh
