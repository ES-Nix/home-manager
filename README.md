
Mainly from [Example: Use nix-flakes with home-manager on non-nixos systems](https://discourse.nixos.org/t/example-use-nix-flakes-with-home-manager-on-non-nixos-systems/10185/9)


Related: [How to do a flake build in non-nixos system?](https://discourse.nixos.org/t/how-to-do-a-flake-build-in-non-nixos-system/10450/7)
https://www.reddit.com/r/NixOS/comments/mqw0cl/question_about_flakes_and_homemanager/h0oruzg/?utm_source=share&utm_medium=web2x&context=3

https://discourse.nixos.org/t/starting-using-flakes-for-system-projects-and-home-manager/8844/7




[Wrappers vs. Dotfiles](https://nixos.wiki/wiki/Wrappers_vs._Dotfiles) from nixos.wiki


The `~/.config/nixpkgs/home.nix`


- https://github.com/nix-community/home-manager#usage
- https://nixos.wiki/wiki/Home_Manager


```bash
NIX_RELEASE_VERSION=2.10.2 \
&& curl -L https://releases.nixos.org/nix/nix-"${NIX_RELEASE_VERSION}"/install | sh -s -- --daemon \
&& echo "Exiting the current shell session!" \
&& exit 0
```


```bash
nix \
profile \
install \
nixpkgs#busybox \
--option \
experimental-features 'nix-command flakes'


busybox test -d ~/.config/nix || busybox mkdir -p -m 0755 ~/.config/nix \
&& busybox grep 'nixos' ~/.config/nix/nix.conf 1> /dev/null 2> /dev/null || busybox echo 'system-features = benchmark big-parallel kvm nixos-test' >> ~/.config/nix/nix.conf \
&& busybox grep 'flakes' ~/.config/nix/nix.conf 1> /dev/null 2> /dev/null || busybox echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf \
&& busybox grep 'trace' ~/.config/nix/nix.conf 1> /dev/null 2> /dev/null || busybox echo 'show-trace = true' >> ~/.config/nix/nix.conf \
&& busybox test -d ~/.config/nixpkgs || busybox mkdir -p -m 0755 ~/.config/nixpkgs \
&& busybox grep 'allowUnfree' ~/.config/nixpkgs/config.nix 1> /dev/null 2> /dev/null || busybox echo '{ allowUnfree = true; android_sdk.accept_license = true; }' >> ~/.config/nixpkgs/config.nix


echo 'PATH="$HOME"/.nix-profile/bin:"$PATH"' >> ~/."$(busybox basename $SHELL)"rc && . ~/."$( busybox basename $SHELL)"rc

nix \
profile \
remove \
"$(nix eval --raw nixpkgs#busybox)"

nix store gc --verbose
systemctl status nix-daemon
nix flake --version



DESTINATION_FOLDER="$HOME/.config/nixpkgs"
rm -fr "${DESTINATION_FOLDER}"
mkdir -p "${DESTINATION_FOLDER}"
cd "${DESTINATION_FOLDER}"
nix flake clone github:ES-Nix/home-manager --dest "${DESTINATION_FOLDER}"

$(nix build --impure --print-out-paths "${DESTINATION_FOLDER}"#homeConfigurations.$USER.activationPackage)/activate

```


```bash
mkdir -pv "$HOME"/.local/bin
cp "$HOME"/.nix-profile/bin/new{u,g}idmap "$HOME"/.local/bin
chmod -v 4700 "$HOME"/.local/bin/new{u,g}idmap
export PATH="$HOME"/.local/bin:$PATH

podman ps
```


```bash
home-manager build --flake ~/.config/nixpkgs
```

```bash
direnv allow 
```

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
    # Example packages
    #discord
    #obsidian
    #spotify
    #tdesktop
    #kolourpaint
    #gitkraken
    #btop
    #vscodium

    # btop
    # htop
    git
    openssh
    # vlc
    
    # jetbrains.pycharm-community
    # gitkraken
    # peek

    podman
    runc
    skopeo
    conmon
    slirp4netns
  ];

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
  

  programs.direnv = {
    enable = true;
    nix-direnv = {
      enable = true;
    };
  };

#  programs.vscode = {
#      enable = true;
#      package = pkgs.vscode;
      # TODO:
      # https://www.reddit.com/r/NixOS/comments/ybb08b/if_i_manage_visual_studio_code_packages_via_home/
      # extensions.autoCheckUpdates = false;
      # extensions.autoUpdate = false;

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
      # username = "vagrant";
      username = "ubuntu";
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

$(nix build --impure --print-out-paths .#homeConfigurations.$USER.activationPackage)/activate
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
