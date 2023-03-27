{ inputs, ... }: {
  imports = with inputs.self; [
    nixosRoles.desktop
  ];
}
