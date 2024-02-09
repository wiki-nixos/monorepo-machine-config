# Produces NixOS or Home Manager module with the custom neovim
localFlake: # Reference to the flake
mode: # "homeManager" or "nixOS". Since the code is essentially the same, the difference is just a matter of paths

{
  pkgs,
  config,
  lib,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf mkPackageOption;
  cfg = config.programs.myNvim;

  # Decide where to add the packages
  outer = if mode == "homeManager" then "home" else "environment";
  inner = if mode == "homeManager" then "packages" else "systemPackages";
in
{
  # TODO: proper opts for plugins and init lua
  options.programs.myNvim = {
    enable = mkEnableOption "My neovim with plugins";
    # package = localFlake.inputs.nvim-nightly.packages.${pkgs.system}.default;
    basePackage = mkPackageOption localFlake.inputs.nvim-nightly.packages.${pkgs.system} "default" { };
    # basePackage = mkPackageOption pkgs "neovim" { };
    withLangServers = mkEnableOption "Enable language server plugins";
  };

  config =
    let
      finalPackage = if cfg.withLangServers then cfg.basePackage else pkgs.cowsay;
    in
    mkIf cfg.enable {
      ${outer}.${inner} = [ finalPackage ];
      programs.myNvim.package = finalPackage;
    };
}
