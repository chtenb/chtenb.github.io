set shell := ["sh", "-cu"]
is-windows := `uname -s | grep -qi 'mingw\|msys' && echo true || echo false`

html:
  for file in blog/*.md; do \
    output="${file%.md}.html"; \
    echo "pandoc $file -o $output -d pandoc/pandoc.yaml"; \
    pandoc "$file" -o "$output" -d pandoc/pandoc.yaml; \
  done

watch-html:
  echo "watching pandoc html"
  watchexec --print-events -w . -e md,pikchr,lua,yaml "just html"

pdf:
  echo "pandoc --data-dir=pandoc/mathdown -d mathdown -d mathdown-default blog/obs.md -o blog/obs.pdf"; \
  pandoc --data-dir=pandoc/mathdown -d mathdown -d mathdown-default blog/obs.md -o blog/obs.pdf

watch-pdf:
  echo "watching pandoc pdf"
  watchexec --print-events -w . -e md,pikchr,lua,yaml "just pdf"

publish-pdf:
  echo "cp ./blog/*.pdf ./docs/blog/"
  cp ./blog/*.pdf ./docs/blog/ 
