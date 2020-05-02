# MyScripts collection

A collection of scripts that facilitate some of everyday tasks of a Linux developer. Primarily it intended for use by the author himself.

Working capacity tested on platforms:

* Ubuntu 16.04
* Ubuntu 18.04

Written by MatrixDeity, 2020.

## Install

To install myscripts on your system, run:

```bash
make install
```

This command will make the following copies:

* `./scripts` -> `~/.myscripts`
* `./configs` -> `~/.config/myscripts`

It will also add necessary aliases to your `~/.bash_aliases` for quick access to scripts. They will be available in new bash sessions or in the current session after running:

```bash
source ~/.bash_aliases
```

## Uninstall

To uninstall myscripts just run:

```bash
make uninstall
```

This command will perform the opposite of actions described in the [Install section](#install).
