#!/bin/bash

function show_header() {
    echo -e "\n\e[1;35m====================================================\e[0m"
    echo -e "\e[1;33m  $1\e[0m"
    echo -e "\e[1;35m====================================================\e[0m\n"
}

clear
echo -e "\e[1;32mPRE-RECAPITULATIF DE L'INSTALLATION\e[0m"
echo -e "-----------------------------------"
echo -e "1. Mise à jour système (DNF & Flatpak)"
echo -e "2. Applications : Zen Browser, Vesktop, Spotify, Planify, Tuba,"
echo -e "   NewsFlash, Obsidian, Termius, Extension Manager, GNOME Builder"
echo -e "3. RPM : VSCodium, GParted, Wireguard"
echo -e "4. Config GNOME : Boutons (min/max), Raccourcis (Win+E/I), Zen par défaut"
echo -e "5. Pilotes NVIDIA : Optimisation de la mémoire vidéo (veille)"
echo -e "6. Dev : Java (OpenJDK), Rust (Rustup), GTK4 & Libadwaita SDK"
echo -e "-----------------------------------"
read -p "Voulez-vous lancer l'installation ? (y/n) " -n 1 -r
echo
[[ ! $REPLY =~ ^[Yy]$ ]] && exit 1

show_header "MISE À JOUR DU SYSTÈME"
sudo dnf upgrade -y
flatpak update -y

show_header "INSTALLATION DES FLATPAKS"
apps=(
    "io.github.zen_browser.zen"
    "dev.vencord.Vesktop"
    "com.spotify.Client"
    "io.github.alainm23.planify"
    "dev.geopjr.Tuba"
    "io.gitlab.news_flash.NewsFlash"
    "md.obsidian.Obsidian"
    "com.termius.Termius"
    "com.mattjakeman.ExtensionManager"
    "org.gnome.Builder"
)
for app in "${apps[@]}"; do
    flatpak install -y flathub "$app"
done

show_header "CONFIGURATION NAVIGATEUR (ZEN)"
BROWSER_ID="io.github.zen_browser.zen.desktop"
xdg-settings set default-web-browser $BROWSER_ID
xdg-mime default $BROWSER_ID x-scheme-handler/http
xdg-mime default $BROWSER_ID x-scheme-handler/https
xdg-mime default $BROWSER_ID text/html

show_header "INSTALLATION DES PAQUETS RPM"
sudo rpm --import https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg
printf "[vscodium]\nname=vscodium\nbaseurl=https://download.vscodium.com/rpms/\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/-/raw/master/pub.gpg" | sudo tee /etc/yum.repos.d/vscodium.repo
sudo dnf install -y codium gparted wireguard-tools

show_header "CONFIGURATION INTERFACE GNOME"
gsettings set org.gnome.desktop.wm.preferences button-layout ":minimize,maximize,close"
gsettings set org.gnome.settings-daemon.plugins.media-keys home "['<Super>e']"
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/']"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name 'Settings'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command 'gnome-control-center'
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding '<Super>i'

show_header "OPTIMISATION NVIDIA"
sudo systemctl enable nvidia-suspend.service nvidia-resume.service
echo "options nvidia NVreg_PreserveVideoMemoryAllocations=1" | sudo tee /etc/modprobe.d/nvidia-power-management.conf

show_header "INSTALLATION DES SDK (DEV)"
sudo dnf install -y java-latest-openjdk-devel gtk4-devel libadwaita-devel pkgconf-pkg-config meson git
if ! command -v rustc &> /dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source $HOME/.cargo/env
fi

show_header "INSTALLATION TERMINÉE !"
echo -e "\e[1;32mRedémarrez votre PC pour appliquer les changements NVIDIA et GNOME.\e[0m"
