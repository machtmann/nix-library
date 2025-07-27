{
  description = "nix-library: dev environment flake templates";

  outputs = { self }: {
    templates = {
      bevy = {
        path = ./templates/bevy;
        description = "Rust / Bevy Engine development environment";
      };
    };
  };
}

