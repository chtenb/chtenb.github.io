#!/usr/bin/env nu

# Watch files and run Pandoc command on changes
def main [] {
  ls blog/*.md | each {|file|
    print $"Converting ($file.name) to html"
    let output = ($file.name | str replace ".md" ".html")
    ^pandoc $file.name -o $output -d pandoc/pandoc.yaml
  }
  ()
}

def "main watch" [] {
  print "watching pandoc"
  watchexec --print-events --shell=nu -w . -e md,pikchr,lua,yaml "nu build.nu"
}

