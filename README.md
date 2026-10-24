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
 
```bash
# 1. Clone the repo
git clone https://github.com/<your-username>/<repo-name>.git ~/bashrc-repo
cd ~/bashrc-repo
 
# 2. Back up your current config
[ -f ~/.bashrc ] && mv ~/.bashrc ~/.bashrc.bak
 
# 3. Link the files into place
ln -s "$PWD/bashrc" ~/.bashrc
mkdir -p ~/.config/oh-my-posh
ln -s "$PWD/oh-my-posh/config.omp.json" ~/.config/oh-my-posh/config.omp.json
 
# 4. Reload
source ~/.bashrc
```
 
Symlinks mean that any edit you make in the repo is live immediately, and you can `git pull` to update.
 
## Customization
 
- **Prompt theme:** edit `oh-my-posh/config.omp.json`. See the [Oh My Posh docs](https://ohmyposh.dev/docs/configuration/overview).
- **Aliases:** the `Aliases` section of `bashrc`. The `tarafetch` alias runs `countryfetch Romania`, so change it to whatever you like.
- **Less noise on startup:** remove or comment out the `fastfetch` block at the bottom.
- **Paths:** everything uses `$HOME`, so nothing needs changing for a different username.
