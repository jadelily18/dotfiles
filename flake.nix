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

    nixos-cosmic.url = "github:lilyinstarlight/nixos-cosmic";

    nix-darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vscode-server.url = "github:nix-community/nixos-vscode-server";
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      nix-flatpak,
      nixos-cosmic,
      nix-darwin,
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
          mkNixosConfig =
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
                  home-manager.backupFileExtension = "backup";
                }
              ] ++ extraModules;
            };
        in
        {
          desktop = mkNixosConfig "desktop" [ ];
          game-servers = mkNixosConfig "game-servers" [ vscode-server.nixosModules.default ];
          media = mkNixosConfig "media" [ vscode-server.nixosModules.default ];
          /*
            Cosmic stuff is adapted from FelixSchausberger's Cosmic configuration
            https://github.com/FelixSchausberger/nixos
          */
          t480 = mkNixosConfig "t480" [
            {
              nix.settings = {
                substituters = [ "https://cosmic.cachix.org/" ];
                trusted-public-keys = [ "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE=" ];
              };
            }
            nixos-cosmic.nixosModules.default
          ];
        };

      # MacBook configuration
      darwinConfigurations."macbook" = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/macbook/configuration.nix
          # stylix.nixosModules.stylix
          # nix-flatpak.nixosModules.nix-flatpak
          # home-manager.nixosModules.home-manager
          # {
          #   home-manager.extraSpecialArgs = { inherit inputs; };
          #   home-manager.useGlobalPkgs = true;
          #   home-manager.useUserPackages = true;
          #   home-manager.users.jade = {
          #     imports = [
          #       ./hosts/macbook/home.nix
          #     ];
          #   };
          #   home-manager.backupFileExtension = "backup";
          # }
        ];
      };

      homeModules.default = ./modules/home;
    };
}
