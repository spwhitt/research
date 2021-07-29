#! /usr/bin/env nix-shell
#! nix-shell -p maude -p rlwrap -i bash
# shellcheck shell=bash

rlwrap -c -a -A -b '.' -f commands.txt maude -no-tecla
