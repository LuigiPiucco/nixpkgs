{ mkXfceDerivation, docbook_xsl, glib, libxslt, gtk2, gtk3
, libxfce4ui, libxfce4util, perl }:

mkXfceDerivation {
  category = "xfce";
  pname = "exo";
  version = "0.12.11";

  sha256 = "1db7w6jk3i501x4qw0hs0ydrm1fjdkxmahzbv5iag859wnnlg0pd";

  nativeBuildInputs = [
    libxslt
    docbook_xsl
  ];

  buildInputs = [
    gtk2 # some xfce plugins still uses gtk2
    gtk3
    glib
    libxfce4ui
    libxfce4util

    (perl.withPackages(ps: with ps; [ URI ])) # for $out/lib/xfce4/exo/exo-compose-mail
  ];

  # Workaround https://bugzilla.xfce.org/show_bug.cgi?id=15825
  NIX_CFLAGS_COMPILE = "-I${glib.dev}/include/gio-unix-2.0";

  meta = {
    description = "Application library for Xfce";
  };
}
