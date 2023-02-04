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
NIX_RELEASE_VERSION=2.10.2 \
&& curl -L https://releases.nixos.org/nix/nix-"${NIX_RELEASE_VERSION}"/install | sh -s -- --no-daemon

. "$HOME"/.nix-profile/etc/profile.d/nix.sh
nix --version

#nix \
#profile \
#install \
#nixpkgs#busybox \
#--option \
#experimental-features 'nix-command flakes'
#
#
#busybox test -d ~/.config/nix || busybox mkdir -p -m 0755 ~/.config/nix \
#&& busybox grep 'nixos' ~/.config/nix/nix.conf 1> /dev/null 2> /dev/null || busybox echo 'system-features = benchmark big-parallel kvm nixos-test' >> ~/.config/nix/nix.conf \
#&& busybox grep 'flakes' ~/.config/nix/nix.conf 1> /dev/null 2> /dev/null || busybox echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf \
#&& busybox grep 'trace' ~/.config/nix/nix.conf 1> /dev/null 2> /dev/null || busybox echo 'show-trace = true' >> ~/.config/nix/nix.conf \
#&& busybox test -d ~/.config/nixpkgs || busybox mkdir -p -m 0755 ~/.config/nixpkgs \
#&& busybox grep 'allowUnfree' ~/.config/nixpkgs/config.nix 1> /dev/null 2> /dev/null || busybox echo '{ allowUnfree = true; android_sdk.accept_license = true; }' >> ~/.config/nixpkgs/config.nix
#
#
#echo 'PATH="$HOME"/.nix-profile/bin:"$PATH"' >> ~/."$(busybox basename $SHELL)"rc && . ~/."$( busybox basename $SHELL)"rc
#
#nix \
#profile \
#remove \
#"$(nix eval --raw nixpkgs#busybox)"
#
## nix store gc --verbose
#systemctl status nix-daemon
#nix flake --version

export NIX_CONFIG='extra-experimental-features = nix-command flakes'


DESTINATION_FOLDER="$HOME/.config/nixpkgs"
rm -fr "${DESTINATION_FOLDER}"
mkdir -p "${DESTINATION_FOLDER}"
cd "${DESTINATION_FOLDER}"
nix flake clone github:ES-Nix/home-manager --dest "${DESTINATION_FOLDER}"

# nix-shell -p nix home-manager


nix shell nixpkgs#{nix,home-manager} --command sh -c 'nix profile remove 0 && home-manager switch'

#mv ~/.profile ~/.profile.bk
#mv ~/.bashrc ~/.bashrc.bk

# export NIXPKGS_ALLOW_UNFREE=1; $(nix build --impure --print-out-paths "${DESTINATION_FOLDER}"#homeConfigurations.$USER.activationPackage)/activate

echo /home/$USER/.nix-profile/bin/zsh | sudo tee -a /etc/shells
sudo usermod -s /home/$USER/.nix-profile/bin/zsh $USER
```

```bash
echo /home/$USER/.nix-profile/bin/zsh | sudo tee -a /etc/shells
sudo usermod -s /home/$USER/.nix-profile/bin/zsh $USER
```

nix-shell -p nix home-manager

export NIX_CONFIG='extra-experimental-features = nix-command flakes'


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
