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
    shadow

     (
       writeScriptBin "ix" ''
          "$@" | "${curl}/bin/curl" -F 'f:1=<-' ix.io
       ''
     )
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

  # Broken!
  # services.docker.enable = true;
  # pkgs.lib.fileSystems."/".neededForBoot = true;
  # fileSystems."/".neededForBoot = true;
  # virtualisation.podman.enable = true;

  # services.cachix-agent = { enable = true; name = "foo-bar-cachix"; };

  services.systembus-notify.enable = true;
  services.spotifyd.enable = true;

  fonts.fontconfig.enable = true;

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
