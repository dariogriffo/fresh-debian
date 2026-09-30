![GitHub Downloads (all assets, all releases)](https://img.shields.io/github/downloads/dariogriffo/fresh-debian/total)
![GitHub Downloads (all assets, latest release)](https://img.shields.io/github/downloads/dariogriffo/fresh-debian/latest/total)
![GitHub Release](https://img.shields.io/github/v/release/dariogriffo/fresh-debian)
![GitHub Release Date](https://img.shields.io/github/release-date/dariogriffo/fresh-debian)

<h1>
   <p align="center">
     <a href="https://getfresh.dev"><img src="https://github.com/dariogriffo/fresh-debian/blob/main/fresh.png" alt="Fresh Logo" width="128" style="margin-right: 20px"></a>
     <a href="https://www.debian.org/"><img src="https://github.com/dariogriffo/fresh-debian/blob/main/debian-logo.png" alt="Debian Logo" width="104" style="margin-left: 20px"></a>
     <br>Fresh for Debian
   </p>
</h1>
<p align="center">
 Fresh is a terminal-based IDE and text editor: easy, powerful and fast.
</p>

# Fresh for Debian

This repository contains build scripts to produce the _unofficial_ Debian packages
(.deb) for [Fresh](https://github.com/sinelaw/fresh/) hosted at [deb.griffo.io](https://deb.griffo.io)

Currently supported Debian distros are:
- Bookworm (v12)
- Trixie (v13)
- Forky (v14)
- Sid (testing)

Currently supported Ubuntu distros are:
- Jammy (22.04)
- Noble (24.04)
- Questing (25.10)
- Resolute (26.04)

Supported architectures:
- amd64 (x86_64) - All distributions
- arm64 (aarch64) - All distributions

Upstream publishes no i386, armel, armhf or riscv64 Linux builds, so those
architectures are not available.

> ℹ️ The package is called **`fresh-editor`**, but the command it installs is
> **`fresh`**.

The package installs:

- `/usr/bin/fresh`, the editor
- the `fresh(1)` man page
- a desktop entry and hicolor icons, so Fresh shows up in application menus
  (it opens in a terminal)

Upstream ships no shell completions.

> ℹ️ Upstream attaches a standalone `.deb` to every GitHub release but runs no
> apt repository, so those installs never get updates. These packages
> repackage that upstream `.deb` unchanged (same binary, man page, desktop
> entry and icons) as per-distribution builds served from an apt repository.
> They keep the same package name, so an existing upstream install is upgraded
> in place from the next Fresh release on. The binary only needs glibc 2.30 and
> libgcc, which every supported distribution already has installed.
>
> Fresh is told that it was installed through apt, so `fresh --cmd update` and
> the startup update check point to `sudo apt upgrade` instead of replacing
> the binary themselves.

This is an unofficial community project to provide a package that's easy to
install on Debian. If you're looking for the Fresh source code, see
[Fresh](https://github.com/sinelaw/fresh/).

## Install/Update

📖 **Step-by-step install guide:** [Debian](https://deb.griffo.io/install-latest-fresh-editor-in-debian.html) · [Ubuntu](https://deb.griffo.io/install-latest-fresh-editor-in-ubuntu.html)

### The Debian way

> ⚠️ **From 1 October 2026, apt access requires a yearly subscription**
> ([deb.griffo.io](https://deb.griffo.io)). To use this tool for free, download
> the .deb from the [Releases](https://github.com/dariogriffo/fresh-debian/releases) page
> and install it manually (see below).

```sh
sudo install -d -m 0755 /etc/apt/keyrings
curl -fsSL https://deb.griffo.io/EA0F721D231FDD3A0A17B9AC7808B4DD62C41256.asc | sudo gpg --dearmor --yes -o /etc/apt/keyrings/deb.griffo.io.gpg
echo "deb [signed-by=/etc/apt/keyrings/deb.griffo.io.gpg] https://deb.griffo.io/apt $(lsb_release -sc 2>/dev/null) main" | sudo tee /etc/apt/sources.list.d/deb.griffo.io.list
sudo apt update
sudo apt install -y fresh-editor
```

### Manual Installation

1. Download the .deb package for your Debian version available on
   the [Releases](https://github.com/dariogriffo/fresh-debian/releases) page.
2. Install the downloaded .deb package.

```sh
sudo dpkg -i <filename>.deb
```
## Updating

To update to a new version, just follow any of the installation methods above. There's no need to uninstall the old version; it will be updated correctly.

## Building

### Build for single architecture
```sh
./build.sh <fresh_version> <build_version> <architecture>
# Example: ./build.sh 0.5.2 1 arm64
```

### Build for all architectures
```sh
./build.sh <fresh_version> <build_version> all
# Example: ./build.sh 0.5.2 1 all
```

## Roadmap

- [x] Produce a .deb package on GitHub Releases
- [x] Set up a debian mirror for easier updates
- [x] Multi-architecture support (amd64, arm64)

## Disclaimer

- This repo is not open for issues related to Fresh. This repo is only for _unofficial_ Debian packaging.
