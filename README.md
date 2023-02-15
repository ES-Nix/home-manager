# home-manager

It is an [POC](https://en.wikipedia.org/wiki/Proof_of_concept) repository that is still improving.

Mainly from [Example: Use nix-flakes with home-manager on non-nixos systems](https://discourse.nixos.org/t/example-use-nix-flakes-with-home-manager-on-non-nixos-systems/10185/9)




If you don't have nix installed:
```bash
NIX_RELEASE_VERSION=2.10.2 \
&& curl -L https://releases.nixos.org/nix/nix-"${NIX_RELEASE_VERSION}"/install | sh -s -- --daemon \
&& echo "Exiting the current shell session!" \
&& exit 0
```

Enabling flakes and some other stuff:
```bash
command -v curl || (command -v apt && sudo apt-get update && sudo apt-get install -y curl)
command -v git || (command -v apt && sudo apt-get update && sudo apt-get install -y git)


test -d /nix || (sudo mkdir -m 0755 /nix && sudo -k chown "$USER": /nix); \
test $(stat -c %a /nix) -eq 0755 || sudo -kv chmod 0755 /nix; \
BASE_URL='https://raw.githubusercontent.com/ES-Nix/get-nix/' \
&& SHA256=5443257f9e3ac31c5f0da60332d7c5bebfab1cdf \
&& NIX_RELEASE_VERSION='2.10.2' \
&& curl -fsSL "${BASE_URL}""$SHA256"/get-nix.sh | sh -s -- ${NIX_RELEASE_VERSION} \
&& . "$HOME"/.nix-profile/etc/profile.d/nix.sh \
&& . ~/."$(ps -ocomm= -q $$)"rc \
&& export TMPDIR=/tmp \
&& nix flake --version

# --ignore-environment
nix \
shell \
github:NixOS/nixpkgs/b7ce17b1ebf600a72178f6302c77b6382d09323f#{git,bashInteractive,coreutils} \
--command \
sh \
-c \
'
DESTINATION_FOLDER="$HOME/.config/nixpkgs" \
&& rm -fr "${DESTINATION_FOLDER}" \
&& mkdir -p "${DESTINATION_FOLDER}" \
&& cd "${DESTINATION_FOLDER}" \
&& nix flake clone github:ES-Nix/home-manager --dest "${DESTINATION_FOLDER}"
'

# Not so sure about it, seems like hacky
#git apply removes-nix.patch \
#&& nix build --impure --print-out-paths --no-link .#homeConfigurations.$USER.activationPackage \
#&& git apply adds-nix.patch

cd ~/.config/nixpkgs \
&& nix \
shell \
github:NixOS/nixpkgs/b7ce17b1ebf600a72178f6302c77b6382d09323f#{git,nix,home-manager,busybox} \
--command \
sh \
-c \
'nix profile remove ".*"; export NIXPKGS_ALLOW_UNFREE=1; home-manager switch -b backuphm --impure'

TARGET_SHELL='zsh'
echo /home/"$USER"/.nix-profile/bin/"$TARGET_SHELL" | sudo tee -a /etc/shells
# sudo usermod -s /home/"$USER"/.nix-profile/bin/"$TARGET_SHELL" "$USER"
sudo -k $(nix build --no-link --print-out-paths nixpkgs#shadow.out)/bin/usermod \
-s \
/home/"$USER"/.nix-profile/bin/"$TARGET_SHELL" \
"$USER"

#TARGET_SHELL='bash'
#echo /home/"$USER"/.nix-profile/bin/"$TARGET_SHELL" | sudo tee -a /etc/shells
#sudo usermod -s /home/"$USER"/.nix-profile/bin/"$TARGET_SHELL" "$USER"
```

> The chsh command only lets you change your login shell from a shell that's 
> listed in /etc/shells, to a shell that's listed in /etc/shells. This is a 
> security and safety feature: if an account has a restricted shell 
> (not listed in /etc/shells), they can't upgrade their access by switching to
> another shell; and a user can't lock themselves out by switching to a shell 
> that they can't change from. The root user is of course exempt from this restriction.

Refs.:
- https://unix.stackexchange.com/a/260661

```bash
echo '\u276F \ue0b0 \u00b1 \ue0a0 \u27a6 \u2718 \u26a1 \u2699'
```


```bash
# TODO: this is not recursive, files like 
# $XDG_CONFIG_HOME/nix/nix.conf and/or ~/.config/nix/nix.conf and others
# are not restored 
# for filename in .*.backuphm; do cp -fv "$filename" "${filename%.*}"; done
find $HOME -exec sh -c 'for filename in .*.backuphm; do test -f $filename && mv -fv "$filename" "${filename%.*}"; done' \;

# Some broken symlinks still exists 
# find -L $HOME -maxdepth 1 -type l -exec echo {} \; 
find -L $HOME -maxdepth 1 -type l -exec rm -v {} \;

# 
sudo sed -i '\#/home/'"$USER"'/.nix-profile/bin/#d' /etc/shells

# 
sed \
'/# It was inserted by the get-nix installer/,/# End of code inserted by the get-nix installer/d' \
~/.$(basename $SHELL)rc


# To revert to system shell, IF IT WAS BASH AND /bin/bash exists!
sudo usermod -s /bin/bash "$USER"
```
Refs.:
- https://stackoverflow.com/a/27658717
- https://www.redhat.com/sysadmin/bash-scripting-loops
- https://unix.stackexchange.com/a/49470
- https://stackoverflow.com/a/1797967
- https://backreference.org/2010/02/20/using-different-delimiters-in-sed/index.html
- https://unix.stackexchange.com/a/494436



Trick:
```bash
cat /etc/passwd | grep $(cd; pwd)
```


```bash
echo /home/$USER/.nix-profile/bin/zsh | sudo tee -a /etc/shells
sudo usermod -s /home/$USER/.nix-profile/bin/zsh $USER
```
Refs.:
- https://unix.stackexchange.com/a/226442


```bash
#curl -L https://hydra.nixos.org/build/"${BUILD_ID}"/download/1/nix > nix \
#&& chmod +x nix \
#&& ./nix flake --version

BUILD_ID='183946375' \
&& mkdir -pv "$HOME"/.local/bin \
&& export PATH="$HOME"/.local/bin:"$PATH" \
&& curl -L https://hydra.nixos.org/build/"${BUILD_ID}"/download/1/nix > nix \
&& mv nix "$HOME"/.local/bin \
&& chmod +x "$HOME"/.local/bin/nix \
&& export NIX_CONFIG='extra-experimental-features = nix-command flakes' \
&& nix flake --version

#'nix profile list | xargs -r nix profile remove 0; export NIXPKGS_ALLOW_UNFREE=1; home-manager switch --impure -b backup'
#error: setting up a private mount namespace: Operation not permitted
#ubuntu@ubuntu:~/.config/nixpkgs$ nix
#error: no subcommand specified
#Try 'nix --help' for more information.
#ubuntu@ubuntu:~/.config/nixpkgs$ sudo poweroff 
#sudo: /etc/sudo.conf is owned by uid 65534, should be 0
#sudo: /usr/bin/sudo must be owned by uid 0 and have the setuid bit set

```

```bash
DESTINATION_FOLDER="$HOME/.config/nixpkgs"

rm -rfv "$HOME"/{.nix-channels,.nix-defexpr,.nix-profile,.config/nixpkgs,.cache/nix} "$DESTINATION_FOLDER"

sudo rm -fr /nix
```


> As to having nix in home-manager itself, it is not necessary and up to the end user. 
> Having it in there automatically upgrades nix on new deployments, and builds it in 
> one go when building home-manager, but it also makes initial deployment trickier, as 
> the first time nix itself has to be uninstalled from the user environment.
> Refs.: https://hhoeflin.github.io/nix/home_folder_nix/


```bash
systemctl --user start systembus-notify.service
```

```bash
home-manager switch
```

```bash
export NIXPKGS_ALLOW_UNFREE=1; home-manager switch --impure
```

```bash
export NIXPKGS_ALLOW_UNFREE=1; home-manager switch --impure -b backup
```

github:NixOS/nixpkgs/release-20.03
github:NixOS/nixpkgs/release-20.09
github:NixOS/nixpkgs/release-21.05
github:NixOS/nixpkgs/release-21.11
github:NixOS/nixpkgs/release-22.05
github:NixOS/nixpkgs/release-22.11
github:NixOS/nixpkgs

```bash
# Wires the local nixpkgs clone input insteade
# nix flake update --override-input nixpkgs ~/nixpkgs ~/.config/nixpkgs#


#nix flake ~/.config/nixpkgs/ update --override-input nixpkgs github:NixOS/nixpkgs/"$(git rev-parse HEAD)" \
#&& home-manager switch --flake ~/.config/nixpkgs/

git bisect start

# git checkout master
git checkout 8304c7138e62d3223c5cbc9429806fc6eb04e210


# Oldest that still working
git checkout e912c7bfe93426c91d54662b1d98a18a08a50e57

git checkout HEAD~4901
git checkout HEAD~4902
git checkout HEAD~4925

nix flake update --override-input nixpkgs ~/nixpkgs ~/.config/nixpkgs# \
&& home-manager switch --flake ~/.config/nixpkgs/

git bisect good



# git checkout 0874168639713f547c05947c76124f78441ea46c
git checkout 5dc2630125007bc3d08381aebbf09ea99ff4e747

nix flake update --override-input nixpkgs ~/nixpkgs ~/.config/nixpkgs# \
&& home-manager switch --flake ~/.config/nixpkgs/

git bisect bad


git bisect run $(nix flake update --override-input nixpkgs ~/nixpkgs ~/.config/nixpkgs# \
&& home-manager switch --flake ~/.config/nixpkgs/)
```

```bash
git bisect reset
```

```bash
git log 5dc2630125007bc3d08381aebbf09ea99ff4e747..8304c7138e62d3223c5cbc9429806fc6eb04e210 --oneline | wc -l
```

```bash
sudo chmod -v 4511 "$HOME"/.nix-profile/bin/new{u,g}idmap
podman ps
```


```bash
home-manager switch
```

### Digging

```bash
find / -type f -perm -4000 -exec ls -al {} \; 2> /dev/null
```
Refs.:
- https://askubuntu.com/a/1083482

TODO:
loginctl enable-linger [USER]
https://discourse.nixos.org/t/replacing-docker-workflow-for-service-ops-with-nix/20753/2



###


```bash
DESTINATION_FOLDER="$HOME/.config/nixpkgs" \
&& rm -fr "${DESTINATION_FOLDER}" \
&& mkdir -p "${DESTINATION_FOLDER}" \
&& cd "${DESTINATION_FOLDER}"

cat << 'EOF' > ~/.config/nixpkgs/flake.nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-22.05";
    # nixpkgs-20-03.url = "github:NixOS/nixpkgs/nixos-20.03";
    nixpkgs-old.url = "github:NixOS/nixpkgs/nixos-21.11";
  };

  outputs = {
    nixpkgs,
    nixpkgs-old,
    home-manager,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    pkgs-old = nixpkgs-old.legacyPackages.${system};
  in {
    homeConfigurations.ubuntu = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        ./home.nix
      ];
      extraSpecialArgs = {
        inherit pkgs-old;
      };
    };
  };
}
EOF


cat << 'EOF' > ~/.config/nixpkgs/home.nix
{
  pkgs,
  pkgs-old,
  config,
  lib,
  ...
}: let 
     username = "ubuntu";
   in {
     home.username = "${username}";
     home.homeDirectory = "/home/${username}";
     home.stateVersion = "22.05";

     programs.home-manager.enable = true;
     home.packages = [
       # nix run github:NixOS/nixpkgs/nixos-21.11#nix_2_4 -- --version 
       pkgs.nixVersions.nix_2_10
       pkgs-old.hello
     ];

  # https://github.com/nix-community/home-manager/blob/782cb855b2f23c485011a196c593e2d7e4fce746/modules/targets/generic-linux.nix
  targets.genericLinux.enable = true;

  nix = {
    enable = true;
     # What about github:NixOS/nix#nix-static can it be injected here? What would break?
     # package = pkgs.pkgsStatic.nix;
     # package = pkgs.nix;
     package = pkgs.nixVersions.nix_2_10;
     # Could be useful:
     # export NIX_CONFIG='extra-experimental-features = nix-command flakes'
     extraOptions = ''
       experimental-features = nix-command flakes
     '';

    settings = {
                  # use-sandbox = true;
                  show-trace = true;
                  system-features = [ "big-parallel" "kvm" "recursive-nix" "nixos-test" ];
                 keep-outputs = true;
                 keep-derivations = true;
                # readOnlyStore = true;
                };
  };

  nixpkgs.config = {
                            allowBroken = false;
                            allowUnfree = true;
                            # TODO: test it
                            # android_sdk.accept_license = true;
  };
}
EOF

git init \
&& git add .

nix shell github:NixOS/nixpkgs/b7ce17b1ebf600a72178f6302c77b6382d09323f#{nix,home-manager} --command sh -c 'nix profile remove 0 && home-manager switch'
# nix shell github:NixOS/nixpkgs/5dc2630125007bc3d08381aebbf09ea99ff4e747#{nix,home-manager} --command sh -c 'nix profile remove 0 && home-manager switch'

```


```bash
home-manager switch --flake ~/.config/nixpkgs
```


## References

- [Home Manager](https://nixos.wiki/wiki/Home_Manager)
- https://rycee.gitlab.io/home-manager/options.html
- https://nix-community.github.io/home-manager/options.html#opt-programs.direnv.config
- lib.hm.dag.entryAfter ["writeBoundary"]: https://nix-community.github.io/home-manager/options.html#opt-home.activation
- https://discourse.nixos.org/t/activation-script-print-to-stdout/14401/5
- https://github.com/nix-community/home-manager/issues/2959#issuecomment-1155830902
- [Example: Use nix-flakes with home-manager on non-nixos systems](https://discourse.nixos.org/t/example-use-nix-flakes-with-home-manager-on-non-nixos-systems/10185/8)
- [How to do a flake build in non-nixos system?](https://discourse.nixos.org/t/how-to-do-a-flake-build-in-non-nixos-system/10450/7)
- https://www.reddit.com/r/NixOS/comments/mqw0cl/question_about_flakes_and_homemanager/h0oruzg/?utm_source=share&utm_medium=web2x&context=3
- https://discourse.nixos.org/t/starting-using-flakes-for-system-projects-and-home-manager/8844/7
- [Wrappers vs. Dotfiles](https://nixos.wiki/wiki/Wrappers_vs._Dotfiles)
- https://github.com/nix-community/home-manager#usage
- https://nixos.wiki/wiki/Home_Manager
- https://discourse.nixos.org/t/how-to-use-nixos-systemd-user-service-definiton-in-non-nixos-system-via-home-manager/19042
- https://www.reddit.com/r/NixOS/comments/qeien0/homemanager_and_configurationnix/
- https://news.ycombinator.com/item?id=28886435
- [A minimal Nix development environment on WSL](https://cbailey.co.uk/posts/a_minimal_nix_development_environment_on_wsl)
- https://discourse.nixos.org/t/fusermount-systemd-service-in-home-manager/5157
- https://mudrii.medium.com/nixos-home-manager-on-native-nix-flake-installation-and-configuration-22d018654f0c
- https://github.com/nix-community/home-manager/blob/782cb855b2f23c485011a196c593e2d7e4fce746/modules/services/lorri.nix#L100
- https://eevie.ro/posts/2022-01-24-how-i-nix.html


### security

- https://bugs.launchpad.net/calibre/+bug/885027

### History

- https://github.com/divnix/digga/issues/83#issuecomment-758300955
- https://github.com/divnix/digga/pull/93#issuecomment-761377665



