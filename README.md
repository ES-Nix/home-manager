
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
  home.username = "ubuntu";
  home.homeDirectory = "/home/ubuntu";
  
  home.packages = [
    pkgs.htop
    pkgs.fortune
  ];

  programs.emacs = {
    enable = true;
    extraPackages = epkgs: [
      epkgs.nix-mode
      epkgs.magit
    ];
  };

  programs.firefox = {
    enable = true;
    profiles = {
      myprofile = {
        settings = {
          "general.smoothScroll" = false;
        };
      };
    };
  };

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
```


```bash
cat << 'EOF' >> ~/.config/nixpkgs/flake.nix
{
  description = "Home Manager configuration of Ubuntu";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs
    home-manager.url = "github:nix-community/home-manager";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { home-manager, ... }:
    let
      system = "x86_64-linux";
      username = "ubuntu";
    in {
      homeConfigurations.${username} = home-manager.lib.homeManagerConfiguration {
        # Specify the path to your home configuration here
        configuration = import ./home.nix;

        inherit system username;
        homeDirectory = "/home/${username}";
        # Update the state version as needed.
        # See the changelog here:
        # https://nix-community.github.io/home-manager/release-notes.html#sec-release-21.05
        stateVersion = "21.11";

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
      };
    };
}
EOF

cd ~/.config/nixpkgs/

git init
git add .
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
