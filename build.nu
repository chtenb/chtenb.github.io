#!/usr/bin/env nu

# Watch files and run Pandoc command on changes
def main [] {
  ls blog/*.md | each {|file|
    let output = ($file.name | str replace ".md" ".html")
    print $"pandoc ($file.name) -o ($output) -d pandoc/pandoc.yaml"
    ^pandoc $file.name -o $output -d pandoc/pandoc.yaml
  }
}

def "main watch" [] {
  print "watching pandoc"
  watchexec --print-events --shell=nu -w . -e md,pikchr,lua,yaml "nu build.nu"
}

