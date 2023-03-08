command -v curl || (command -v apt && sudo apt-get update && sudo apt-get install -y curl)
command -v curl || (command -v apk && sudo apk add --no-cache -y curl)

NIX_RELEASE_VERSION=2.10.2 \
&& curl -L https://releases.nixos.org/nix/nix-"${NIX_RELEASE_VERSION}"/install | sh -s -- --no-daemon \
&& . "$HOME"/.nix-profile/etc/profile.d/nix.sh

export NIX_CONFIG='extra-experimental-features = nix-command flakes'

nix \
shell \
--ignore-environment \
github:NixOS/nixpkgs/f5ffd5787786dde3a8bf648c7a1b5f78c4e01abb#{git,bashInteractive,coreutils,gnused,home-manager} \
--command \
sh <<-EOF
  { mkdir -pv /home/"$USER"/.config/nixpkgs \
  && ls -al /home/"$USER"/.config/nixpkgs \
  && tee /home/"$USER"/.config/nixpkgs/home.nix <<'NESTEDEOF'
  { pkgs, ... }:

  {

    home.packages = with pkgs; [
      coreutils
      curl
      btop
      jq
      tmate

      git
      openssh

      zsh
      shadow

      discord
      obsidian
      spotify
      tdesktop
      kolourpaint
      gitkraken
      btop
      vscodium
      google-chrome
      gimp
      slack
      qbittorrent
      nerdfonts

       (
         writeScriptBin "ix" ''
            "$@" | "curl" -F 'f:1=<-' ix.io
         ''
       )

       (
         writeScriptBin "gphms" ''
          echo $(cd "$HOME/.config/nixpkgs" && git pull) \
          && export NIXPKGS_ALLOW_UNFREE=1; \
          home-manager switch --impure --flake "$HOME/.config/nixpkgs"
         ''
       )

       (
         writeScriptBin "nr" ''
          nix repl --expr 'import <nixpkgs> {}'
         ''
       )

       (
         writeScriptBin "nfm" ''
           #! \${pkgs.runtimeShell} -e
           nix flake metadata $1 --json | jq -r '.url'
         ''
       )

    ];

    nix = {
      enable = true;
       package = pkgs.nixVersions.nix_2_10;
       extraOptions = ''
         experimental-features = nix-command flakes
       '';

      settings = {
                   # use-sandbox = true;
                   show-trace = false;
                   keep-outputs = true;
                   keep-derivations = true;

                   # One month: 60 * 60 * 24 * 7 * 4 = 2419200
                   tarball-ttl = 60 * 60 * 24 * 7 * 4;
                 };
    };

    nixpkgs.config = {
                              allowBroken = false;
                              allowUnfree = true;
    };


    fonts = {
      fontconfig = {
        enable = true;
      };
    };

    home.extraOutputsToInstall = [
      "/share/zsh"
      "/share/bash"
      "/share/fish"
      "/share/fonts" # fc-cache -frv
      # /etc/fonts
    ];

      # https://www.reddit.com/r/NixOS/comments/fenb4u/zsh_with_ohmyzsh_with_powerlevel10k_in_nix/
      programs.zsh = {
        # Your zsh config
        enable = true;
        enableCompletion = true;
        dotDir = ".config/zsh";
        enableAutosuggestions = true;
        enableSyntaxHighlighting = true;
        envExtra = ''
          if [ -e ~/.nix-profile/etc/profile.d/nix.sh ]; then
            . ~/.nix-profile/etc/profile.d/nix.sh
          fi
        '';

        initExtra = "\${pkgs.neofetch}/bin/neofetch";
        autocd = true;

         # > closed and reopened the terminal. Then it worked.
         # https://discourse.nixos.org/t/home-manager-doesnt-seem-to-recognize-sessionvariables/8488/8
         sessionVariables = {
           LANG = "en_US.utf8";
           # fc-match list
           FONTCONFIG_FILE = "\${pkgs.fontconfig.out}/etc/fonts/fonts.conf";
           FONTCONFIG_PATH = "\${pkgs.fontconfig.out}/etc/fonts/";
         };

        historySubstringSearch.enable = true;

        history = {
          save = 50000;
          size = 50000;
          path = "$HOME/.cache/zsh_history";
          expireDuplicatesFirst = true;
        };

        oh-my-zsh = {
          enable = true;
          # plugins = (import ./zsh/plugins.nix) pkgs;
          # https://github.com/Xychic/NixOSConfig/blob/76b638086dfcde981292831106a43022588dc670/home/home-manager.nix
          plugins = [
            # "autojump"
            "aws"
            # "cargo"
            "catimg"
            "colored-man-pages"
            "colorize"
            "command-not-found"
            "common-aliases"
            "copyfile"
            "copypath"
            "cp"
            "direnv"
            "docker"
            "docker-compose"
            "emacs"
            "encode64"
            "extract"
            "fancy-ctrl-z"
            "fzf"
            "gcloud"
            "git"
            "git-extras"
            "git-flow-avh"
            "github"
            "gitignore"
            "gradle"
            "history"
            "history-substring-search"
            "kubectl"
            "man"
            "mvn"
            "node"
            "npm"
            "pass"
            "pip"
            "poetry"
            "python"
            "ripgrep"
            "rsync"
            "rust"
            "scala"
            "ssh-agent"
            "sudo"
            "systemadmin" # https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/systemadmin
            "systemd"
            "terraform"
            # "thefuck"
            "tig"
            "timer"
            # "tmux" # It needs to be installed
            "vagrant"
            "vi-mode"
            "vim-interaction"
            "yarn"
            "z"
            "zsh-navigation-tools"
          ];
          theme = "robbyrussell";
          # theme = "bira";
          # theme = "powerlevel10k";
          # theme = "powerlevel9k/powerlevel9k";
          # theme = "agnoster";
          # theme = "gallois";
          # theme = "gentoo";
          # theme = "af-magic";
          # theme = "half-life";
          # theme = "rgm";
          # theme = "crcandy";
          # theme = "fishy";
        };
      };

    programs.starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        shell = { disabled = false; };
        rlang = { detect_files = [ ]; };
        python = { disabled = true; };
      };
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
} && cd /home/"$USER"/.config/nixpkgs/ \
&& sed -i 's/username = ".*";/username = "'$USER'";/g' flake.nix \
&& git init \
&& git add .
EOF



nix \
shell \
github:NixOS/nixpkgs/f5ffd5787786dde3a8bf648c7a1b5f78c4e01abb#{git,home-manager} \
--command \
sh \
-c \
'
  export NIXPKGS_ALLOW_UNFREE=1;
  home-manager switch -b backuphm --impure --flake ~/.config/nixpkgs ;
  home-manager generations
'

nix \
shell \
github:NixOS/nixpkgs/f5ffd5787786dde3a8bf648c7a1b5f78c4e01abb#{bashInteractive,coreutils,home-manager,shadow} \
--command \
sh <<-EOF
TARGET_SHELL='zsh'
FULL_TARGET_SHELL=/home/"$USER"/.nix-profile/bin/"\$TARGET_SHELL"

ls -al "\$FULL_TARGET_SHELL"

echo "\$FULL_TARGET_SHELL" | sudo tee -a /etc/shells

sudo \
-k \
usermod \
-s \
/home/"$USER"/.nix-profile/bin/"\$TARGET_SHELL" \
"$USER"
EOF

