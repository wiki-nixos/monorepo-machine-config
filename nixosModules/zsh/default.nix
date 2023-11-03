# [[file:../../new_project.org::*zsh (system)][zsh (system):2]]
inputs:
{ pkgs, config, lib, ... }:
let
  # This kinda imports the user module and exposes the parameters through userConfig attrset
  userConfig = import ../../modules/home-manager/zsh { inherit pkgs config inputs lib; };
in
{
  environment.systemPackages = userConfig.home.packages;
  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    # Enabled inside the hm module
    syntaxHighlighting.enable = false;
    # Enabled inside the hm module
    enableCompletion = false;
    inherit (userConfig.programs.zsh) shellAliases;
    interactiveShellInit = userConfig.programs.zsh.initExtra;
    promptInit =
      builtins.concatStringsSep
        "\n"
        (
          map
            (x:
              ''
                if [[ $TERM != "dumb" && (-z $INSIDE_EMACS || $INSIDE_EMACS == "vterm") ]]; then
                  ${x}
                fi
              ''
            )
            [
              # Enable starship prompt
              ''eval "$(${pkgs.starship}/bin/starship init zsh)"''
              # Direnv setup
              ''eval "$(${pkgs.direnv}/bin/direnv hook zsh)"''
            ]
        );
  };
  # System-level completions need this
  environment.pathsToLink = [ "/share/zsh" ];
}
# zsh (system):2 ends here
