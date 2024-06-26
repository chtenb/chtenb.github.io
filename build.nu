#!/usr/bin/env nu

# Watch files and run Pandoc command on changes
def "main" [] {
  print "building pandoc"
  ^pandoc blog/cat.md -o blog/cat.html -d pandoc/pandoc.yaml
}

def "main watch" [] {
  print "watching pandoc"
  watchexec --print-events --shell=nu -w . -e md,js,css,pikchr,lua,yaml "nu build.nu"
}

# def "main release" [] {
#   rm -rf docs
#   main
#   npm exec -- parcel build --no-optimize --no-source-maps --dist-dir docs/ './index.html' './blog/*.html' 
#   git checkout -- docs/CNAME
# }

# def "main publish" [] {
#   main release
#   # git add . 
#   # git commit -m publish
# }
