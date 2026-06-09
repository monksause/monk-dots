# monk-dots

a minimal, clean hyprland setup for wayland.

---

```
~/.dotfiles/
├── alacritty/    # terminal
├── fish/         # shell
├── hypr/         # compositor, bindings, animations
├── kitty/        # terminal (alt)
├── rofi/         # launcher & menus
├── swaync/       # notifications
└── swayosd/      # on-screen display
```

---

## install

```bash
git clone https://github.com/<your-username>/monk-dots.git ~/.dotfiles
cd ~/.dotfiles
chmod +x install.sh
./install.sh
```

supports **arch**, **fedora**, and **debian/ubuntu**.  
log out and back in after install to start hyprland.

```bash
./install.sh --restow   # re-link after a git pull
./install.sh --unstow   # remove all symlinks cleanly
```

---

## credits

rofi, swaync, and swayosd configs are lifted (with gratitude) from  
[vyrx-dev/symphony](https://github.com/vyrx-dev/symphony) — go star it.
