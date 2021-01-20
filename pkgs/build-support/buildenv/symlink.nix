{ callPackage, substituteAll }:

let
  builder = substituteAll {
    src = ./builder.pl;
    addCommand = "symlink";
    extraImports = "";
    inherit (builtins) storeDir;
  };
in callPackage ./. { inherit builder;  }
