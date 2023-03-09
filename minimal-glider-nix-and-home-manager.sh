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

  echo $PATH | tr ':' '\n'

  {
  mkdir -pv /home/"$USER"/.config/nixpkgs \
  && ls -al /home/"$USER"/.config/nixpkgs \
  && tee /home/"$USER"/.config/nixpkgs/home.nix <<'NESTEDEOF'
  { pkgs, ... }:

  {

    home.packages = with pkgs; [
      btop
      coreutils
      curl
      git
      jq
      neovim
      openssh
      shadow
      tmate
      zsh

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
       extraOptions = "experimental-features = nix-command flakes";
    };

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

         # > closed and reopened the terminal. Then it worked.
         # https://discourse.nixos.org/t/home-manager-doesnt-seem-to-recognize-sessionvariables/8488/8
         sessionVariables = {
           LANG = "en_US.utf8";
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
            "colored-man-pages"
            "colorize"
            "fzf"
            "git"
            "git-extras"
            "github"
            "gitignore"
            "history"
            "history-substring-search"
            "man"
            "ssh-agent"
            "sudo"
            "systemadmin" # https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/systemadmin
            "zsh-navigation-tools"
          ];
          theme = "robbyrussell";
        };
      };

    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
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
} && echo 1234 \
&& cd /home/"$USER"/.config/nixpkgs/ \
&& echo 5678 \
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


#
TARGET_SHELL='zsh' \
&& FULL_TARGET_SHELL=/home/"$USER"/.nix-profile/bin/"\$TARGET_SHELL" \
&& echo \
&& ls -al "\$FULL_TARGET_SHELL" \
&& echo \
&& echo "\$FULL_TARGET_SHELL" | sudo tee -a /etc/shells \
&& echo \
&& sudo \
      -k \
      usermod \
      -s \
      /home/"$USER"/.nix-profile/bin/"\$TARGET_SHELL" \
      "$USER"
EOF

# sudo reboot
