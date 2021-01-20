{ callPackage, substituteAll, file, perl, perl532Packages }:

let
  builder = substituteAll {
    src = ./builder.pl;
    addCommand = "rcopy";
    extraImports = ''

      use File::Copy::Recursive qw(rcopy);
    '';
    inherit (builtins) storeDir;
  };

  defaultPostBuild = ''
    filecmd="${file}/bin/file"

    chmod -R 744 $out/

    links=$(find $out -type l)
    for link in $links; do
      target=$(readlink "$link")
      if [[ -n "''${target##*$out*}" ]] && [[ -z "''${target##/nix/store*}" ]]; then
        fullTarget=$(readlink -e "$link")
        rm "$link"
        cp -r "$fullTarget" "$link"
      fi
    done

    files=$(find $out -type f)
    for file in $files; do
      if [[ -n "''${file##*ld-linux*}" ]] && [[ -n "''${file#*ld-2.32.so*}" ]]; then
        kind=$($filecmd "$file")
        if  [[ -z "''${kind##*ELF 32-bit*}" ]]; then
          patchelf --set-rpath '/lib32:/usr/lib32:$ORIGIN:$ORIGIN/../lib32' "$file" || true
          patchelf --set-interpreter '/lib32/ld-linux.so.2' "$file" || true
        else
          if [[ -z "''${kind##*ELF 64-bit*}" ]]; then
            patchelf --set-rpath '/lib64:/usr/lib64:$ORIGIN:$ORIGIN/../lib64' "$file" || true
            patchelf --set-interpreter '/lib64/ld-linux-x86-64.so.2' "$file" || true
          fi
        fi
      fi
    done
  '';

  defaultBuildInputs = [ perl perl532Packages.FileCopyRecursive ];
in callPackage ./. { inherit builder defaultPostBuild defaultBuildInputs; }
