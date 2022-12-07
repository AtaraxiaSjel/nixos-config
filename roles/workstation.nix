{ inputs, ... }: {
  imports = with inputs.self; with inputs.self.nixosProfiles; [
    inputs.self.nixosRoles.desktop
  ];
}
