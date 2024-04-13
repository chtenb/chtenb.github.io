#!/usr/bin/env nu

# Watch files and run Pandoc command on changes
watchexec --print-events --shell=nu -w . -e md,js,css,pikchr,lua,yaml "pandoc blog/cat.md -o blog/cat.html -d pandoc/pandoc.yaml"
