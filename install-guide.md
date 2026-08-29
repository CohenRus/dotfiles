# Linux Migration

## Tasks

- Password manager: bit warden (migrated)
- Notes: simplenote (migrated)
- Cloud files: IDrive (migrated)
- Dot files:
- Installer script:

## OS Stuff

- **Distro:** EndeavourOS (install with no desktop environment)
- **Shell:** zsh
- **Application launcher:** walker
- **File manager:** Nautilus
- **Notification Daemon:** mako
- **Screen locking/power management:** hyprlock, hypridle, Greetd
- **Screenshots:** Hyprshot
- **System controls:**
  - audio: PipeWire & WirePlumber (pre-installed) + Pavucontrol
  - bluetooth: BlueZ Stack + Blueman
  - network: NetworkManager (pre installed) + nm-applet & nmtui2

## Package Managers

- **Packman** - pre-installed
- **Yay** - `git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si`
- **Flatpak** - `sudo pacman -S flatpak`

## Apps

- Ghostty
- Simplenotes
- Zen
- Zed
- Spotify
- Bitwarden
- Idrive
- Localsend
- Chrome
- Prism launcher
- Gemini
- Claude
- Discord
- Proton vpn

## Chrome PWAs

- Google calendar
- Google Docs
- Google Drive
- Google slides
- Gmail
- Sheets
- Outlook
- YouTube

## CLI Tools

- Arduino-cli
- Bat
- Cloc
- Ffmpeg
- Fmt
- Fzf
- Gh
- Git
- Lazygit
- Lua
- Java
- Gcc
- Nvm + newest node version
- Neovim
- Nmap
- Ollama
- Oh-my-pi
- Npm, pnpm
- Pyenv + newest python version
- Ripgrep
- Starship
- Supabase
- Sqlite
- Tmux
- Tree

---

## Corrected Master Execution Order

### Step 1: Pre-Install Prep (Windows & BIOS)

1. **Update Firmware:** Boot Windows and update SSD/BIOS via manufacturer tools (e.g., Lenovo Vantage).
2. **Partition Drive:** Shrink Windows partition to leave free unallocated space for Linux.
3. **BIOS Setup:** Disable Secure Boot, set SATA mode to AHCI/NVMe, and boot from your EndeavourOS USB.

### Step 2: Base System Installation

1. Boot the live USB.
2. Run the EndeavourOS installer and select No Desktop Environment (Headless Install).
3. Target the free unallocated partition, complete the installation, and reboot into the bare TTY prompt.

### Step 3: Core Packages & Tooling Setup

Log into the TTY and run your package installation. (Includes Ghostty, Flatpak, and Zsh early so they are ready before boot.)

> **Before you run this — check your GPU generation.** Arch's official `nvidia-open` package only supports Turing-generation NVIDIA GPUs and newer (RTX 20-series onward). If your GPU is a Maxwell or Pascal card (GTX 900/1000-series or older), `nvidia-open` will not work for it — those cards need the legacy `nvidia` driver line, which has moved to the AUR for unsupported cards. Run `lspci | grep -i nvidia` to confirm your GPU before proceeding, and swap `nvidia-open` for the correct AUR package in the AUR step below if needed.

```bash
# 1. Update system and install display, drivers, utilities, shell, & terminal
sudo pacman -Syu --needed --noconfirm \
    base-devel git stow hyprland hyprlock hypridle greetd \
    nautilus mako pavucontrol blueman bluez bluez-utils network-manager-applet hyprshot \
    ntfs-3g exfatprogs nvme-cli smartmontools gparted fwupd flatpak \
    nvidia-open nvidia-utils lib32-nvidia-utils nvidia-settings libva-nvidia-driver nvidia-prime \
    zsh zsh-autosuggestions zsh-syntax-highlighting starship ghostty \
    xdg-desktop-portal-hyprland xdg-desktop-portal-gtk file-roller

# 2. Install AUR Helper & AUR Packages
if ! command -v yay &> /dev/null; then
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay && makepkg -si --noconfirm && cd ~
fi

yay -S --needed --noconfirm walker-bin elephant-bin elephant-desktopapplications-bin elephant-calc-bin elephant-runner-bin elephant-providerlist-bin localsend-bin greetd-tuigreet
```

> **Note on Walker:** Walker is only the search window — the actual searching (finding apps, running commands, calculator, etc.) is handled by a separate backend daemon called Elephant, plus small provider plugins. Walker will not return any results without Elephant + at least the `desktopapplications` provider running, regardless of whether you have a Walker config file. The packages above cover the basics (app launching, calculator, running commands, switching providers).

### Step 4: System Drivers, Power, & Services

1. **NVIDIA KMS:** Update `/etc/mkinitcpio.conf` -> `MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)`.
   - Rebuild initramfs: `sudo mkinitcpio -P`
2. **DRM Boot Option:** Add `nvidia_drm.modeset=1` to kernel parameters.
   - If using GRUB: add to `GRUB_CMDLINE_LINUX_DEFAULT` in `/etc/default/grub` and run `sudo grub-mkconfig -o /boot/grub/grub.cfg`.
   - If using systemd-boot: add to `/boot/loader/entries/options`.
3. **NVIDIA Power Management:** Create `/etc/modprobe.d/nvidia-pm.conf` with:
   ```
   options nvidia NVreg_DynamicPowerManagement=0x02
   ```
4. **Enable Services:**
   ```bash
   sudo systemctl enable --now bluetooth
   sudo systemctl enable --now fstrim.timer
   sudo systemctl enable --now nvidia-persistenced.service
   sudo systemctl enable nvidia-suspend.service nvidia-hibernate.service nvidia-resume.service
   sudo systemctl enable greetd
   ```
5. **Configure greetd:** Edit `/etc/greetd/config.toml`:
   ```toml
   [default_session]
   command = "tuigreet --time --cmd Hyprland"
   user = "greeter"
   ```

### Step 5: Shell, Dotfiles (via Stow), & Hyprland Config (BEFORE Reboot)

1. **Change Shell to Zsh:**
   ```bash
   chsh -s $(which zsh)
   ```
2. **Clone & Symlink Dotfiles with GNU Stow:**

   GNU Stow manages dotfiles by symlinking files out of a Git repo into your home directory, so your live configs are just symlinks pointing back into the repo (easy to version, sync, and roll back). Stow expects the repo to be organized into "packages" — top-level folders that mirror the path structure they should end up at relative to your home directory (`~`).

   For this setup, the repo should look like:
   ```
   ~/dotfiles/
   ├── hypr/
   │   └── .config/
   │       └── hypr/
   │           ├── hyprland.conf
   │           └── hypridle.conf
   ├── walker/
   │   └── .config/
   │       └── walker/
   │           └── config.toml
   └── zsh/
       └── .zshrc
   ```

   Clone the repo and stow each package:
   ```bash
   git clone https://github.com/CohenRus/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   stow -t ~ hypr walker zsh
   ```
   - `-t ~` tells Stow to target your home directory (this is the default target, but it's worth being explicit).
   - Each argument after `-t ~` (`hypr`, `walker`, `zsh`) is a package — Stow symlinks its contents into `~`, recreating the folder structure (e.g., `~/dotfiles/hypr/.config/hypr/hyprland.conf` becomes a symlink at `~/.config/hypr/hyprland.conf`).
   - **If a target file already exists and isn't a symlink** (e.g., you created `~/.config/hypr/hyprland.conf` by hand before setting up Stow), Stow will refuse to overwrite it and error out. Either delete/move the conflicting file first, or run `stow --adopt -t ~ hypr` once to pull the existing file *into* the repo (check `git diff` afterward to make sure nothing unexpected got adopted).
   - To reverse a package (remove its symlinks), run `stow -D -t ~ hypr`.

   If you don't have a dotfiles repo yet, create one and populate it with the config content shown in the steps below, placed at the paths in the tree above, then run `git init`, commit, and push it before stowing.
3. **`~/.config/hypr/hyprland.conf`** (lives in the dotfiles repo, symlinked into place by Stow): Ensure iGPU variables, keybindings, autostart programs (mako, nm-applet, blueman-applet, elephant, walker, hypridle), and `cursor { no_hardware_cursors = true }` are saved.

   ```
   # Primary rendering on iGPU
   env = AQ_DRM_DEVICES,/dev/dri/card0:/dev/dri/card1

   # Cursor visibility fix
   cursor {
       no_hardware_cursors = true
   }

   # --- Autostart Background Services ---
   exec-once = mako
   exec-once = nm-applet --indicator
   exec-once = blueman-applet
   exec-once = elephant
   exec-once = walker --gapplication-service
   exec-once = hypridle

   # --- Keybindings (Functional Defaults) ---
   $mainMod = SUPER

   # Applications
   bind = $mainMod, Return, exec, ghostty
   bind = $mainMod, E, exec, nautilus
   bind = $mainMod, SPACE, exec, walker

   # Audio / Volume Controls (Pipewire/Wireplumber)
   bindel = , XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
   bindel = , XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
   bindl  = , XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle

   # Screenshots (Hyprshot)
   # Print Screen: Full monitor | Super+Print: Region selection
   bind = , PRINT, exec, hyprshot -m output
   bind = $mainMod, PRINT, exec, hyprshot -m region
   ```
4. **`~/.config/hypr/hypridle.conf`** (dotfiles repo, symlinked by Stow): Save your lock screen and DPMS timeout rules.

   ```
   general {
       lock_cmd = pidof hyprlock || hyprlock
       before_sleep_cmd = loginctl lock-session
   }

   listener {
       timeout = 300                             # 5 minutes
       on-timeout = loginctl lock-session        # Lock screen
   }

   listener {
       timeout = 600                             # 10 minutes
       on-timeout = hyprctl dispatch dpms off    # Turn off display
       on-resume = hyprctl dispatch dpms on      # Turn on display
   }
   ```
5. **`~/.zshrc`** (dotfiles repo, symlinked by Stow): Add `compinit`, source autosuggestions/syntax-highlighting, and initialize starship.

   ```bash
   # Enable completion system
   autoload -U compinit && compinit

   # Source Arch plugins
   source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
   source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

   # Initialize starship prompt
   eval "$(starship init zsh)"
   ```

   > Once a package is stowed, `~/.zshrc` (and the hypr configs) are symlinks pointing back into `~/dotfiles`. You can edit them at either path — the change lands in the repo either way, so just re-run `stow` after adding brand-new files to a package, not after editing existing ones.

### Step 6: First Reboot & Graphical Verification

```bash
sudo reboot
```

- Log in via tuigreet.
- Test `Super + Return` (opens Ghostty), `Super + Space` (opens Walker), and `Super + E` (opens Nautilus).

### Step 7: Application & CLI Bulk Installation

Now that you are inside your functional GUI desktop with terminal access, batch-install your remaining apps and developer tools:

```bash
# GUI Applications (Pacman, Flatpak, AUR)
yay -S --needed --noconfirm \
    zen-browser-bin zed spotify bitwarden idrive-bin \
    google-chrome prism-launcher discord proton-vpn-gtk-app

# CLI & Development Tools
sudo pacman -S --needed --noconfirm \
    bat cloc ffmpeg fmt fzf github-cli lazygit lua jdk-openjdk gcc \
    neovim nmap ripgrep tmux tree sqlite

# Node / Python Version Managers
yay -S --needed --noconfirm nvm pyenv

# Oh-my-pi (terminal AI coding agent, installed via its official script —
# no Arch package exists for it)
curl -fsSL https://omp.sh/install | sh
```
