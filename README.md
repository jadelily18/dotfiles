# dotfiles

My NixOS stuff.

Run the following to build and switch to a specified system:

```sh
nh os switch ./ -H desktop # replace `desktop` with any host name
```

Run the following to build an ISO for a specified host:

```sh
nixos-generate --flake ./#media -f iso
```
