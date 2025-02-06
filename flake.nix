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
      ...
    }@inputs:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        system = system;
        modules = [
          ./hosts/desktop/configuration.nix
          ./modules
          inputs.stylix.nixosModules.stylix
          nix-flatpak.nixosModules.nix-flatpak
          home-manager.nixosModules.home-manager
          {
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.jade = {
              imports = [
                ./hosts/desktop/home.nix
              ];
            };
          }
        ];
      };

      nixosConfigurations.game-servers = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        system = system;
        modules = [
          ./hosts/game-servers/configuration.nix
          ./modules
          inputs.stylix.nixosModules.stylix
          nix-flatpak.nixosModules.nix-flatpak
          vscode-server.nixosModules.default
          home-manager.nixosModules.home-manager
          {
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.jade = {
              imports = [
                ./hosts/game-servers/home.nix
              ];
            };
          }
        ];
      };

      nixosConfigurations.media = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        system = system;
        modules = [
          ./hosts/media/configuration.nix
          ./modules
          inputs.stylix.nixosModules.stylix
          nix-flatpak.nixosModules.nix-flatpak
          home-manager.nixosModules.home-manager
          {
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.jade = {
              imports = [
                ./hosts/media/home.nix
              ];
            };
          }
        ];
      };

      homeManagerModules.default = ./modules/home;
    };
}
