{
  description = "space-shutter";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in
      {
        name = "space-shutter";

        devShell = pkgs.mkShell {
          buildInputs = [
            pkgs.go
            pkgs.steam-run
          ];

          shellHook = ''
            function wrapProgram() {
              local directory="$(dirname $1)"
              local file="$(basename $1)"
              mv $directory/$file $directory/.unwrapped_$file
              cat <<EOF > $directory/$file
            #!/usr/bin/env bash
            steam-run $directory/.unwrapped_$file "\$@"
            EOF
            chmod a+x $directory/$file
            }

            # Add a directory for binaries that will be linked into path
            mkdir -p ~/.cache/hackyJaguarFlake/bin
            export PATH=~/.cache/hackyJaguarFlake/bin:$PATH

            # Install the latest jag via go into the user home
            go install github.com/toitlang/jaguar/cmd/jag@v1.41.0 

            # Create a steam-run wrapper in our bin directory
            cat <<EOF > ~/.cache/hackyJaguarFlake/bin/jag
            #!/usr/bin/env bash
            steam-run $HOME/go/bin/jag "\$@"
            EOF
            chmod a+x ~/.cache/hackyJaguarFlake/bin/jag

            # Download toit and jaguar tools
            # And wrap them in steam-run
            if ! jag setup --check ; then
              jag setup
              find $HOME/.cache/jaguar/sdk -type f -executable | while read line ; do
                wrapProgram $line
              done
            fi

            # Link jaguar tools into temporary bin
            find $HOME/.cache/jaguar/sdk/bin $HOME/.cache/jaguar/sdk/tools -type f -executable | while read line ; do
              ln -sf $line ~/.cache/hackyJaguarFlake/bin/$(basename $line)
            done

            # Open udp port 1990 for finding jaguar devices
            if which nft ; then
              sudo nft add rule inet nixos-fw input-allow udp dport 1990 accept
            else
              echo Make sure that UDP port 1990 is open, otherwise scanning for esp devices wont work
            fi

            # kicad does not work well with wayland and hidpi displays
            export GDK_BACKEND=x11
          '';
        };

        formatter = pkgs.nixfmt-rfc-style;
      }
    );
}
