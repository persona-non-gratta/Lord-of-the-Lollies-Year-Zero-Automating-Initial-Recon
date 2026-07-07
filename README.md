# Lord of the Lollies: Year Zero

A lightweight Bash tool that automates the default web enumeration workflow by wrapping **ffuf**, **nmap**, and **nikto** into a single command.
[working && output image](https://imgur.com/a/u8i8jgL)

---

## Features

- Automated port/service scanning with `nmap`
- Directory & content discovery with `ffuf`
- Web server vulnerability checks with `nikto`
- Silent mode for clean, non-banner output

---

## Prerequisites

Make sure the following tools are installed and available in your `$PATH`:

| Tool  | Purpose                     | Source |
|-------|------------------------------|--------|
| `nmap`  | Port and service scanning   | [nmap.org](https://nmap.org/) |
| `ffuf`  | Web content fuzzing         | [AUR](https://aur.archlinux.org/packages/ffuf) |
| `nikto` | Web vulnerability scanning  | [AUR](https://aur.archlinux.org/packages/nikto) |

```bash
# Arch Linux (nmap from official repos)
sudo pacman -S nmap

# ffuf and nikto are only available via the AUR — install with yay
yay -S ffuf nikto

# Debian/Ubuntu
sudo apt install nmap ffuf nikto
```

### Recommended wordlists

For best results with `ffuf`, grab [SecLists](https://github.com/danielmiessler/SecLists) — a solid, community-maintained collection of wordlists for fuzzing, discovery, and more.

```bash
git clone https://github.com/danielmiessler/SecLists.git
```

---

## Usage

```bash
./lolyz.sh [target] [options] # or bash lolyz.sh
```

### Options

| Flag | Description |
|------|-------------|
| `-s`, `--silent` | Run in silent mode (no banner output) |

---

## Contributing

Contributions are very welcome! This script was originally built as part of a Bash scripting learning process, so there's plenty of room to grow — better error handling, more scan profiles, config file support, you name it.

Feel free to open an issue or submit a pull request.

> **A note on AI assistance:** Some features (like timestamped logging) and several bug fixes were developed with help from Claude, in the interest of making the tool safer and more convenient to use. Contributions and reviews from the community are still very much encouraged.

---

### Personally from me:

I have just finished the Bash Scripting course (101), and honestly, this project is just to test my knowledge for myself. I'm not counting on any career in scripting — it's just my fun little project :) Thanks for your attention!

## License

This project is licensed under the MIT License.

```
Copyright (c) 2026 Alexandr Bolsoi

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

<p align="center">
Built by <a href="https://github.com/persona-non-gratta">PERSONV NON GRATTA</a>
</p>
