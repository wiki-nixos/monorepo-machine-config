# NixOS module that configures zsh
{ self }:
{ pkgs, config, lib, ... }:
let
  inherit (self) inputs;
  commonSettings = import ./common.nix {
    inherit pkgs; pkgs-unstable = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.system};
  };
  inherit (lib) concatMapStringsSep;
in
{
  programs.zsh = {
    enable = true;
    enableCompletion = lib.mkForce false;
    histFile = "~/.local/share/zsh/zsh_history";
    histSize = 10000;
    interactiveShellInit = commonSettings.initExtra
      + commonSettings.completionInit
      + (with commonSettings.plugins;
      ''
        fpath=(${baseDir} $fpath)
      ''
      + concatMapStringsSep "\n" (plugin: "autoload -Uz ${plugin}.zsh && ${plugin}.zsh") list)
      + "\n"
      +
      # Allows searching for completion
      ''
        zstyle ':completion:*:*:*:default' menu yes select search
      ''
    ;
    inherit (commonSettings) shellAliases;
    syntaxHighlighting = {
      enable = true;
    };
  };
  programs.starship.enable = true;
}
