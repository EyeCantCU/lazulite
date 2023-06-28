set -oue pipefail

systemctl enable lightdm.service
systemctl enable lightdm-workaround.service
systemctl enable touchegg.service
