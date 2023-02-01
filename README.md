# home-manager

It is an POC repository that is still improving

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
systemctl --user start systembus-notify.service
```


```bash
sudo chmod -v 4511 "$HOME"/.nix-profile/bin/new{u,g}idmap
podman ps
```


## References

- [Home Manager](https://nixos.wiki/wiki/Home_Manager)
- https://rycee.gitlab.io/home-manager/options.html
- [Example: Use nix-flakes with home-manager on non-nixos systems](https://discourse.nixos.org/t/example-use-nix-flakes-with-home-manager-on-non-nixos-systems/10185/8)
- [How to do a flake build in non-nixos system?](https://discourse.nixos.org/t/how-to-do-a-flake-build-in-non-nixos-system/10450/7)
- https://www.reddit.com/r/NixOS/comments/mqw0cl/question_about_flakes_and_homemanager/h0oruzg/?utm_source=share&utm_medium=web2x&context=3
- https://discourse.nixos.org/t/starting-using-flakes-for-system-projects-and-home-manager/8844/7
- [Wrappers vs. Dotfiles](https://nixos.wiki/wiki/Wrappers_vs._Dotfiles)
- https://github.com/nix-community/home-manager#usage
- https://nixos.wiki/wiki/Home_Manager
