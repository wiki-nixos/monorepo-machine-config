# TODO: add home-manager as an explicit parameter instead of passing it through inputs
{
  withSystem,
  self,
  importApply,
}:
{
  perSystem =
    { system, ... }:
    {
      packages = withSystem system (
        { inputs', pkgs, ... }:
        let
          inherit (pkgs) lib; # TODO: check if lib is part of standard args in flake parts
        in
        {
          modVim =
            let
              # Compute the base module options
              baseModConfig =
                (lib.evalModules {
                  modules = [
                    self.inputs.home-manager.nixosModules.home-manager
                    { _module.check = false; } # This skips some checks that can be (probably) safely bypassed
                    self.homeManagerModules.modVim
                  ];
                  specialArgs = {
                    inherit pkgs lib;
                    config = { };
                  };
                }).config;
            in
            ((builtins.head self.homeManagerModules.modVim.imports) {
              inherit pkgs lib;
              config = lib.recursiveUpdate baseModConfig { programs.myNvim.withLangServers = true; };
            }).config.content.programs.myNvim.package;
        }
      );
    };
  flake =
    let
      # Both modules are very similar, so just build them using a "mode" flag below
      moduleBuilder = import ./modules self;
    in
    {
      nixosModules.modVim = moduleBuilder "nixOS";
      homeManagerModules.modVim = moduleBuilder "homeManager";
    };
}
