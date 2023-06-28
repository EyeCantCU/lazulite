set -oue pipefail

systemctl disable --now --no-reload gdm.service
systemctl enable lightdm.service
systemctl enable lightdm-workaround.service
systemctl enable touchegg.service
