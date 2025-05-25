set shell := ["sh", "-cu"]
is-windows := `uname -s | grep -qi 'mingw\|msys' && echo true || echo false`

# Complete build and test
default: main

main:
  for file in blog/*.md; do \
    output="${file%.md}.html"; \
    echo "pandoc $file -o $output -d pandoc/pandoc.yaml"; \
    pandoc "$file" -o "$output" -d pandoc/pandoc.yaml; \
  done

watch:
  echo "watching pandoc"
  watchexec --print-events -w . -e md,pikchr,lua,yaml "just main"
