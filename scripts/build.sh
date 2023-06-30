#!/usr/bin/env bash

# Tell build process to exit if there are any errors.
set -oue pipefail

BUILD_TYPE="$1"

# Helper functions.
RECIPE_FILE="/usr/share/ublue-os/recipe.yml"
get_yaml_array() {
    mapfile -t "${1}" < <(yq -- "${2}" "${RECIPE_FILE}")
}
get_yaml_string() {
    yq -- "${1}" "${RECIPE_FILE}"
}

# Welcome.
echo "Building Lazulite."

# Add custom repos.
FEDORA_VERSION="$(cat /usr/lib/os-release | grep -Po '(?<=VERSION_ID=)\d+')"
get_yaml_array repos '.'${BUILD_TYPE}'.rpm.repos[]'
if [[ ${#repos[@]} -gt 0 ]]; then
    echo "-- Adding repos defined in recipe.yml --"
    for repo in "${repos[@]}"; do
        repo="${repo//%FEDORA_VERSION%/${FEDORA_VERSION}}"
        wget "${repo}" -P "/etc/yum.repos.d/"
    done
    echo "---"
fi

# Ensure that all script files are executable.
find /tmp/scripts -type f -exec chmod +x {} \;

# Run "pre" scripts.
run_scripts() {
    script_mode="$1"
    get_yaml_array buildscripts "."${BUILD_TYPE}".scripts.${script_mode}[]"
    if [[ ${#buildscripts[@]} -gt 0 ]]; then
        echo "-- Running [${script_mode}] scripts defined in recipe.yml --"
        for script in "${buildscripts[@]}"; do
            echo "Running [${script_mode}]: ${script}"
            "/tmp/scripts/${script_mode}/${script}" "${script_mode}"
        done
        echo "---"
    fi
}
run_scripts "pre"

# Install RPMs.
get_yaml_array install_rpms '.'${BUILD_TYPE}'.rpm.install[]'
if [[ ${#install_rpms[@]} -gt 0 ]]; then
    echo "-- Installing RPMs defined in recipe.yml --"
    echo "Installing: ${install_rpms[@]}"
    rpm-ostree install "${install_rpms[@]}"
    echo "---"
fi

# Remove RPMs.
get_yaml_array remove_rpms '.'${BUILD_TYPE}'.rpm.remove[]'
if [[ ${#remove_rpms[@]} -gt 0 ]]; then
    echo "-- Removing RPMs defined in recipe.yml --"
    echo "Removing: ${remove_rpms[@]}"
    rpm-ostree override remove "${remove_rpms[@]}"
    echo "---"
fi

if [[ ${BUILD_TYPE} == "main" ]]; then
    # Enable yafti: https://github.com/ublue-os/yafti.
    FIRSTBOOT_DATA="/usr/share/ublue-os/firstboot"
    FIRSTBOOT_LINK="/usr/etc/profile.d/ublue-firstboot.sh"
    pip install --prefix=/usr yafti
    # Create symlink to our profile script, which creates the per-user "autorun yafti" links.
    mkdir -p "$(dirname "${FIRSTBOOT_LINK}")"
    ln -s "${FIRSTBOOT_DATA}/launcher/login-profile.sh" "${FIRSTBOOT_LINK}"
fi

# Run "post" scripts.
run_scripts "post"
