# Home manager module that configures git
{ pkgs, lib, config, ... }:
let
  inherit (lib) getExe;
  inherit (config) semanticColorScheme rawColorScheme;

  inherit (semanticColorScheme) activeFrameBorder inactiveFrameBorder;
in
{
  home.packages = builtins.attrValues {
    inherit (pkgs) git git-crypt;
  };

  # Directory where local overrides can be places
  xdg.configFile."git/local.d/.keep".source = builtins.toFile "keep" "";
  programs = {
    git = {
      enable = true;
      aliases = {
        ci = "commit";
        st = "status";
        co = "checkout";
        rv = "remote --verbose";
        unstage = "reset HEAD --";
        # NOTE: Needs findutils xargs for -L1 argument
        pushall = "!git remote | ${pkgs.findutils}/bin/xargs -L1 git push --all";
        branch-note = "!git config branch.$(git symbolic-ref --short HEAD).note $( if [ $# -gt 0 ]; then $1; fi)";
      };
      userEmail = "id@vtimofeenko.com";
      userName = "Vladimir Timofeenko";
      ignores = [
        # Vim swap files
        "*.swp"
        # For Mac
        ".DS_STORE"
        # where envrc stores its stuff
        ".direnv/"
      ];
      extraConfig.url."https://github.com/" = {
        insteadOf = [
          "gh:"
          "github:"
        ];
      };
      includes = [
        { path = "~/.config/git/local.d/gitconfig"; } # Local ad-hoc overrides for git config
      ];
    };
    gh = {
      enable = true;
      settings.prompt = "enabled";
      settings.aliases.prco = "pr checkout";
    };
    lazygit = {
      # TODO: Lazygit color scheme to match the rest. Needs semantic colors?
      enable = true;
      settings = {
        gui.theme = {
          selectedLineBgColor = [ "#${inactiveFrameBorder}" ];
          selectedRangeBgColor = [ "#${inactiveFrameBorder}" ];
          activeBorderColor = [
            "#${activeFrameBorder}"
            "bold" # Otherwise strikethrough creeps in for some reason
          ];
          inactiveBorderColor = [ "#${inactiveFrameBorder}" ];
          optionsTextColor = [ "#${rawColorScheme.fg-main}" ];
        };
        git.paging.pager = "${getExe pkgs.diff-so-fancy}";
      };
    };
  };
}
# Git:1 ends here
