{ inputs, ... }: {
  imports = with inputs.self; [
    customRoles.desktop
  ];
}
