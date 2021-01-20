{ buildFHSEnv
, lib
, videoDrivers ? []
}:

let
  generalPackageSelector = pkgs: with pkgs;
    [
      mesa
      mesa.drivers
      mesa.osmesa
      libva
      vaapiVdpau
      libvdpau
      libvdpau-va-gl
      egl-wayland
      libglvnd
      python3
      gcc10
      which
      acl
      attr
      zlib
      elfutils
      libelf
      freetype
      libcap
      udev
      vulkan-loader
      glib
      opencl-headers
      ocl-icd
      libGLU
      libGL
      libdrm
      util-linux
      libffi
      pcre
      libidn
      wayland
      xwayland
      expat
      llvm_11
      ncurses
      libxml2
      libselinux
    ]
    ++ (with gst_all_1;
      [ gstreamer gst-plugins-base gst-plugins-good gst-plugins-ugly gst-libav
        (gst-plugins-bad.override { enableZbar = false; }) ])
    ++ (with xorg;
      [ libXau libX11 libXinerama libXi libXcursor libXrandr libXrender
        libXxf86vm libXcomposite libXext libxcb libXdmcp libXfixes libxshmfence
        libXdamage libpciaccess ]);
in buildFHSEnv {
  name = "steamrt";
  targetPkgs = pkgs: with pkgs;
    [ intel-media-driver intel-gmmlib ]
    ++ generalPackageSelector pkgs
    ++ videoDrivers;
  multiPkgs = pkgs: with pkgs;
    [ vaapiIntel ]
    ++ generalPackageSelector pkgs
    ++ videoDrivers;
  noOutsideReferences = true;
  extraBuildCommands = ''
    rm $out/lib/ld-linux.so.2
    ln -s i386-linux-gnu/ld-linux.so.2 $out/lib/ld-linux.so.2
    escapedOut="''${out//\//\\\/}"
    chmod -R 777 $out/usr/share
    find $out/usr/share/{glvnd/egl_vendor.d,vulkan/*} -type f -exec sed -i "s/\/nix\/store\/.*\//\/usr\/lib\//g" {} \;
    chmod -R 777 $out/etc
    ldconfig -C /etc/ld.so.cache -r $out \
      /lib64 /lib32 /lib \
      /lib64/dri /lib32/dri /lib/dri
  '';
  extraOutputsToInstall = [ "lib32" ];
}
