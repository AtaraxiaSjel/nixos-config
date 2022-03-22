(self: super: {
  roundcubePlugins.carddav = self.callPackage ./carddav.nix { };
  roundcubePlugins.persistent_login = self.callPackage ./persistent_login.nix { };
})