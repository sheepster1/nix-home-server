# nix-home-server
Simple home server with nix, k3s and flux

## Features

1. Arr suite
2. Homeassistant with HACS preinstalled and a zwave-js deployment
3. homer as a dashboard
4. pihole that also works as a local dns. But it is recommended to use a public dns for better compatibility
5. Web based file browser for easy management of media and config

## Installation

1. Fork this repo (You probably want it private) 
2. Install nixos on the server
3. Update the config in [nix/configuration.nix](/nix/configuration.nix) according to comments, and copy it over to the server, and rebuild the system.
4. You should now have a server with k3s running.
5. Config
  a.  Set cluster domain both in [gotk-sync.yaml](./clusters/cluster/flux-system/gotk-sync.yaml) and in [create-self-signed-tls.sh](./scripts/create-self-signed-tls.sh)
  b. Update git repo [gotk-sync.yaml](./clusters/cluster/flux-system/gotk-sync.yaml)
  c. Adjust volume configuration to match your hardware [volumes](clusters/cluster/apps/media/volumes)
6. Create the homeassistant https secret with the [create-self-signed-tls.sh](./scripts/create-self-signed-tls.sh) script
7. Open a shell on the server, and run
    ```
    # Here is an example installation command, update the values with your fork.
    export GITHUB_TOKEN=
    export BRANCH_NAME=main
    flux bootstrap github \
      --token-auth \
      --owner=sheepster1 \
      --repository=nix-home-server \
      --branch="$BRANCH_NAME" \
      --path=clusters/cluster \
      --personal
    ```

    You may run into issues with the order of installation in flux causing errors around the ${domain_name} variable not being replaced. If that happens, simple add it yourself to the kustomization for the first run, or just remove the usage for the first reconciliation.
8. Optional, Copy kube config from the server at `/etc/rancher/k3s/k3s.yaml` to another machine for easy access.
9. You should now have a cluster with the arr suite installed and a few other tools. open homer which is the cluster dashboard, for easy links for everything.

## TODO

1. Automate arr suite configuration. the suite uses an internal database for configuration, and doesn't support config files, so first config isn't as easy.
2. Convert secrets to sealed secrets
3. Make install easier, a little too many things that have to happen in order that can be improved.

