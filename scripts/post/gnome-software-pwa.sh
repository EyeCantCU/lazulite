set -oue pipefail

rpm-ostree override replace --experimental --from \
    repo=copr:copr.fedorainfracloud.org:ublue-os:gnome-software \
    gnome-software gnome-software-rpm-ostree
