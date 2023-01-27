
Mainly from [Example: Use nix-flakes with home-manager on non-nixos systems](https://discourse.nixos.org/t/example-use-nix-flakes-with-home-manager-on-non-nixos-systems/10185/9)


Related: [How to do a flake build in non-nixos system?](https://discourse.nixos.org/t/how-to-do-a-flake-build-in-non-nixos-system/10450/7)
https://www.reddit.com/r/NixOS/comments/mqw0cl/question_about_flakes_and_homemanager/h0oruzg/?utm_source=share&utm_medium=web2x&context=3

https://discourse.nixos.org/t/starting-using-flakes-for-system-projects-and-home-manager/8844/7




[Wrappers vs. Dotfiles](https://nixos.wiki/wiki/Wrappers_vs._Dotfiles) from nixos.wiki


The `~/.config/nixpkgs/home.nix`


- https://github.com/nix-community/home-manager#usage
- https://nixos.wiki/wiki/Home_Manager


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
    htop
    fortune
    git
    vlc
    # podman
  ];

  programs.direnv = {
    enable = true;
    nix-direnv = {
      enable = true;
    };
  };

#  programs.vscode = {
#      enable = true;
#      package = pkgs.vscode;
#      extensions = with pkgs.vscode-extensions; [
#          bbenoist.nix
#          yzhang.markdown-all-in-one
#          github.vscode-pull-request-github
#          ms-vscode.makefile-tools
#          ms-vsliveshare.vsliveshare
#          streetsidesoftware.code-spell-checker
#          eamodio.gitlens
#          dart-code.dart-code
#          dart-code.flutter
#          dbaeumer.vscode-eslint
#          prisma.prisma
#          yzhang.markdown-all-in-one
#          redhat.vscode-yaml
#          firefox-devtools.vscode-firefox-debug
#          apollographql.vscode-apollo
#          bierner.markdown-mermaid
#          bradlc.vscode-tailwindcss
#          donjayamanne.githistory
#      ];
#      userSettings = {
#          "terminal.integrated.fontFamily" = "Hack";
#      };
#  };

  # programs.emacs = {
  #   enable = true;
  #   extraPackages = epkgs: [
  #     epkgs.nix-mode
  #     epkgs.magit
  #  ];
  # };

  # programs.firefox = {
  #   enable = true;
  #   profiles = {
  #      myprofile = {
  #      settings = {
  #        "general.smoothScroll" = false;
  #      };
  #     };
  #   };
  # };

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
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
      username = "vagrant";
    in {
      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};

        # defaultPackage.${system} = home-manager.defaultPackage.${system};
       
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

$(nix build --impure --print-out-paths .#homeConfigurations.vagrant.activationPackage)/activate
```


```bash
nix \
flake \
show \
github:nix-community/home-manager \
--no-write-lock-file
```

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

## References

- [Home Manager](https://nixos.wiki/wiki/Home_Manager)
- https://rycee.gitlab.io/home-manager/options.html
- [Example: Use nix-flakes with home-manager on non-nixos systems](https://discourse.nixos.org/t/example-use-nix-flakes-with-home-manager-on-non-nixos-systems/10185/8)
