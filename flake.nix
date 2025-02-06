{
  description = "Personal NixOS configs";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix.url = "github:danth/stylix";

    nix-flatpak.url = "github:gmodena/nix-flatpak";

    vscode-server.url = "github:nix-community/nixos-vscode-server";
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      nix-flatpak,
      vscode-server,
      stylix,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations =
        let
          mkConfig =
            name: extraModules:
            nixpkgs.lib.nixosSystem {
              specialArgs = { inherit inputs; };
              inherit system;
              modules = [
                ./hosts/${name}/configuration.nix
                ./modules
                stylix.nixosModules.stylix
                nix-flatpak.nixosModules.nix-flatpak
                home-manager.nixosModules.home-manager
                {
                  home-manager.extraSpecialArgs = { inherit inputs; };
                  home-manager.useGlobalPkgs = true;
                  home-manager.useUserPackages = true;
                  home-manager.users.jade = {
                    imports = [
                      ./hosts/${name}/home.nix
                    ];
                  };
                }
              ] ++ extraModules;
            };
        in
        {
          desktop = mkConfig "desktop" [ ];
          game-servers = mkConfig "game-servers" [ vscode-server.nixosModules.default ];
          media = mkConfig "media" [ vscode-server.nixosModules.default ];
        };

      homeManagerModules.default = ./modules/home;
    };
}
