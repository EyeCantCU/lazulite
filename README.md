# lazulite

**This image is considered Alpha**

[![release-please](https://github.com/EyeCantCU/lazulite/actions/workflows/release-please.yml/badge.svg)](https://github.com/EyeCantCU/lazulite/actions/workflows/release-please.yml)

An opinionated Fedora image with the Pantheon desktop environment.

# Usage

1. Download and install [the ISO from here](https://github.com/EyeCantCU/lazulite/releases/):
   - Select "Install eyecantcu/lazulite" from the menu
     - Choose "Install lazulite:38" if you have an AMD or Intel GPU
     - Choose "Install lazulite-nvidia:38" if you have an Nvidia GPU
   - [Follow the rest of the installation instructions](https://ublue.it/installation/)

### For existing rpm-ostree users

1. After you reboot you should [pin the working deployment](https://docs.fedoraproject.org/en-US/fedora-silverblue/faq/#_about_using_silverblue) so you can safely rollback. 
1. [AMD/Intel GPU users only] Open a terminal and rebase the OS to this image:

        sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/eyecantcu/lazulite:38

1. [Nvidia GPU users only] Open a terminal and rebase the OS to this image:

        sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/eyecantcu/lazulite-nvidia:38

1. Reboot the system and you're done!

1. To revert back:

        sudo rpm-ostree rebase fedora:fedora/38/x86_64/silverblue
        
Check the [Silverblue documentation](https://docs.fedoraproject.org/en-US/fedora-silverblue/) for instructions on how to use rpm-ostree. 
We build date tags as well, so if you want to rebase to a particular day's release you can use the version number and date to boot off of that specific image:
  
    sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/eyecantcu/lazulite:38-20230310

The `latest` tag will automatically point to the latest build. 

## Verification

These images are signed with sigstore's [cosign](https://docs.sigstore.dev/cosign/overview/). You can verify the signature by downloading the `cosign.pub` key from this repo and running the following command:

    cosign verify --key cosign.pub ghcr.io/eyecantcu/lazulite
    
## Building Locally

1. Clone this repository and cd into the working directory

       git clone https://github.com/eyecantcu/lazulite.git
       cd lazulite

1. Make modifications if desired
    
1. Build the image (Note that this will download and the entire image)

       podman build . -t lazulite
    
1. [Podman push](https://docs.podman.io/en/latest/markdown/podman-push.1.html) to a registry of your choice.
1. Rebase to your image to wherever you pushed it:

       sudo rpm-ostree rebase ostree-unverified-registry:whatever/lazulite:latest
