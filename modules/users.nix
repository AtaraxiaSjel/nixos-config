{ lib, ... }: {
  options = {
    mainuser = lib.mkOption { type = lib.types.str; };
  };
}