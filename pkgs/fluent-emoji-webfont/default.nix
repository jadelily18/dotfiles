{
  pkgs,
}:
let
  buildFluentEmoji = variant: pkgs.callPackage ./derivation.nix { inherit pkgs variant; };
in
{
  color = buildFluentEmoji "color";
  flat = buildFluentEmoji "flat";
  hc = buildFluentEmoji "hc";
  hc-inv = buildFluentEmoji "hc-inv";
}
