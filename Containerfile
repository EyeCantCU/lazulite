# Lazulite Containerfile

ARG BASE_IMAGE_NAME="${BASE_IMAGE_NAME:-base}"
ARG IMAGE_FLAVOR="${IMAGE_FLAVOR:-main}"
ARG SOURCE_IMAGE="${SOURCE_IMAGE:-$BASE_IMAGE_NAME-$IMAGE_FLAVOR}"
ARG BASE_IMAGE="ghcr.io/ublue-os/${SOURCE_IMAGE}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION:-38}"

FROM ${BASE_IMAGE}:${FEDORA_MAJOR_VERSION} AS lazulite

ARG IMAGE_NAME="${IMAGE_NAME}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION}"

# The default recipe set to the recipe's default filename
# so that `podman build` should just work.
ARG RECIPE=./recipe.yml

# Copy static configurations and component files.
COPY etc /etc
COPY usr /usr

# Copy the recipe that we're building.
COPY ${RECIPE} /usr/share/ublue-os/recipe.yml

# "yq" used in build.sh and the "setup-flatpaks" just-action to read recipe.yml.
COPY --from=docker.io/mikefarah/yq /usr/bin/yq /usr/bin/yq

# Copy the build script and all custom scripts.
COPY scripts /tmp/scripts

# Fonts
ARG FONTS=/usr/share/fonts
RUN mkdir -p ${FONTS}/{inter,ubuntu}
COPY --from=ghcr.io/ublue-os/bling:latest /files${FONTS} ${FONTS}/inter
COPY --from=ghcr.io/ublue-os/bling:latest /files${FONTS} ${FONTS}/ubuntu

# Run the build script, then clean up temp files and finalize container build.
RUN chmod +x /tmp/scripts/build.sh && \
    /tmp/scripts/build.sh && \
    fc-cache -f /usr/share/fonts/ubuntu && \
    fc-cache -f /usr/share/fonts/inter && \
    systemctl disable gdm.service && \
    systemctl enable lightdm.service && \
    systemctl enable lightdm-workaround.service && \
    systemctl enable touchegg.service && \
    rm -rf /tmp/* /var/* && \
    ostree container commit && \
    mkdir -p /var/tmp && \
    chmod -R 1777 /var/tmp

# Lazulite DX
FROM lazulite as lazulite-dx

ARG IMAGE_NAME="${IMAGE_NAME}"
ARG FEDORA_MAJOR_VERSION="${FEDORA_MAJOR_VERSION}"

ARG RECIPE=dx/recipe.yml
COPY ${RECIPE} /usr/share/ublue-os/recipe-dx.yml

# Copy latest "cosign"
COPY --from=cgr.dev/chainguard/cosign:latest /usr/bin/cosign /usr/bin/cosign

# Intel Mono
ARG MONO=/usr/share/fonts/intel-one-mono
RUN mkdir -p ${MONO}
COPY --from=ghcr.io/ublue-os/bling:latest /files${MONO} ${MONO}

COPY dx/scripts /tmp/dx

RUN chmod +x /tmp/dx/build.sh && \
    /tmp/dx/build.sh && \
    fc-cache -f /usr/share/fonts/intelmono && \
    rm -rf /tmp/* /var/* && \
    ostree container commit
