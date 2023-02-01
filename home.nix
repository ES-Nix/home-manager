{ pkgs, ... }:

{

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  # home.username = "vagrant";
  # home.homeDirectory = "/home/vagrant";

  home.packages = with pkgs; [
    # Graphical packages
    #dbeaver
    #discord
    #gitkraken
    #gitkraken
    #insomnia
    #jetbrains.pycharm-community
    #keepassxc
    #kolourpaint
    #libreoffice
    #obsidian
    #okular
    #peek
    #spotify
    #tdesktop
    #vlc
    #vscodium

    xorg.xclock
    hello
    figlet
    cowsay
    ponysay

    coreutils
    binutils
    utillinux
    glibc.bin
    file
    findutils
    gnugrep
    gnumake
    curl
    wget
    lsof
    tree
    killall

    graphviz # dot command comes from here
    jq
    unixtools.xxd

    gzip
    # unrar
    unzip

    btop
    htop
    asciinema
    git
    openssh


    podman
    runc
    skopeo
    conmon
    slirp4netns
    shadow

     (
       writeScriptBin "ix" ''
          "$@" | "${curl}/bin/curl" -F 'f:1=<-' ix.io
       ''
     )
  ];

  # https://github.com/nix-community/home-manager/blob/782cb855b2f23c485011a196c593e2d7e4fce746/modules/targets/generic-linux.nix
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

  # Broken!
  # services.docker.enable = true;
  # pkgs.lib.fileSystems."/".neededForBoot = true;
  # fileSystems."/".neededForBoot = true;
  # virtualisation.podman.enable = true;

  # services.cachix-agent = { enable = true; name = "foo-bar-cachix"; };

  services.systembus-notify.enable = true;
  services.spotifyd.enable = true;

  fonts.fontconfig.enable = true;

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

  # https://nix-community.github.io/home-manager/options.html#opt-programs.direnv.config
  programs.direnv = {
    enable = true;
    nix-direnv = {
      enable = true;
    };
  };

  fzf = {
    enable = true;
    # enableBashIntegration = true;
    # enableFishIntegration = true;
  };

  # This makes it so that if you type the name of a program that
  # isn't installed, it will tell you which package contains it.
  # https://eevie.ro/posts/2022-01-24-how-i-nix.html
  nix-index = {
    enable = true;
    # enableFishIntegration = true;
    # enableBashIntegration = true;
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

  # programs.firefox = {
  #   enable = true;
  #   profiles = {
  #     myprofile = {
  #       settings = {
  #         "general.smoothScroll" = false;
  #       };
  #     };
  #   };
  # };

  #services.gpg-agent = {
    #enable = true;
    #defaultCacheTtl = 1800;
    #enableSshSupport = true;
  #};

  programs.home-manager = {
    enable = true;
  };
}
