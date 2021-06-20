
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
  home.packages = [
    pkgs.git
    pkgs.hello
  ];

  programs.git = {
    enable = true;
    userName  = "my_git_username";
    useEmail = "my_git_username@gmail.com";
  };

  programs.home-manager = {
    enable = true;
    path = "";
  };
}
EOF
```

