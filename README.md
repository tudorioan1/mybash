# Tudor's custom bash setup
<img width="1350" height="599" alt="image" src="https://github.com/user-attachments/assets/81a84c0b-fef0-474f-92c8-30828669296a" />

My personal Bash configuration for Arch Linux: a clean prompt, a smarter `cd`, a nicer `cat`, and a system summary every time I open a terminal.
## What's inside
 
- **Prompt:** [Oh My Posh](https://ohmyposh.dev/) with a custom theme (`oh-my-posh/config.omp.json`)
- **Navigation:** [zoxide](https://github.com/ajeetdsouza/zoxide) for jumping between directories
- **Viewing files:** `cat` is aliased to [bat](https://github.com/sharkdp/bat)
- **Greeting:** [fastfetch](https://github.com/fastfetch-cli/fastfetch) on every new terminal
- **History:** 10,000 entries, duplicates ignored, appended across sessions
- **PATH setup:** pipx, pnpm, Homebrew (Linuxbrew) and LM Studio CLI
Every tool is wrapped in a `command -v` check, so if something isn't installed, the shell simply skips it instead of throwing errors.

## Requirements
 
Required for the full experience:
 
| Tool | Purpose |
|------|---------|
| `oh-my-posh` | prompt |
| `zoxide` | smart `cd` |
| `bat` | `cat` replacement |
| `fastfetch` | system info on startup |

For `oh-my-posh`, follow the [official installation guide](https://ohmyposh.dev/docs/installation/linux) or use your AUR helper of choice.
 
You also need a [Nerd Font](https://www.nerdfonts.com/) set in your terminal emulator, otherwise the prompt icons won't render properly.
 
## Installation

Supported distros: Arch, Debian/Ubuntu, Fedora and openSUSE.

```bash
git clone https://github.com/tudorioan1/mybash.git ~/mybash
cd ~/mybash
chmod +x install.sh
./install.sh
```

The script detects your package manager (`pacman`, `apt`, `dnf` or `zypper`), installs the dependencies (`zoxide`, `bat`, `fastfetch`, `oh-my-posh`) and symlinks the config files into place. Anything already there is moved to `<file>.bak.<timestamp>`, never deleted.

Options:

| Flag | What it does |
|------|--------------|
| `--no-deps` | only link the config files, don't install packages |
| `-y`, `--yes` | don't ask for confirmation before installing |
| `-h`, `--help` | show help |

Then open a new terminal or run `source ~/.bashrc`.

> `oh-my-posh` is installed with its [official installer](https://ohmyposh.dev/docs/installation/linux), which is downloaded and run with `curl | bash`. Use `--no-deps` and install it yourself if you'd rather not.

### Manual installation

```bash
git clone https://github.com/tudorioan1/mybash.git ~/mybash
cd ~/mybash

# Back up your current config
[ -e ~/.bashrc ] && mv ~/.bashrc ~/.bashrc.bak
[ -e ~/.config/oh-my-posh ] && mv ~/.config/oh-my-posh ~/.config/oh-my-posh.bak
[ -e ~/.config/fastfetch ] && mv ~/.config/fastfetch ~/.config/fastfetch.bak

# Link the files into place
mkdir -p ~/.config
ln -s "$PWD/.bashrc" ~/.bashrc
ln -s "$PWD/config/oh-my-posh" ~/.config/oh-my-posh
ln -s "$PWD/fastfetch" ~/.config/fastfetch

# Reload
source ~/.bashrc
```

Install the dependencies (`zoxide`, `bat`, `fastfetch`, `oh-my-posh`) with your package manager. On Debian/Ubuntu `bat` is called `batcat`, so also run `mkdir -p ~/.local/bin && ln -s "$(command -v batcat)" ~/.local/bin/bat`.
 
Symlinks mean that any edit you make in the repo is live immediately, and you can `git pull` to update.
 
## Customization
 
- **Prompt theme:** edit `oh-my-posh/config.omp.json`. See the [Oh My Posh docs](https://ohmyposh.dev/docs/configuration/overview).
- **Aliases:** the `Aliases` section of `bashrc`. The `tarafetch` alias runs `countryfetch Romania`, so change it to whatever you like.
- **Less noise on startup:** remove or comment out the `fastfetch` block at the bottom.
- **Paths:** everything uses `$HOME`, so nothing needs changing for a different username.
