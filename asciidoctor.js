const Asciidoctor = require('asciidoctor')
const kroki = require('asciidoctor-kroki')

var asciidoctor = Asciidoctor()

kroki.register(asciidoctor.Extensions)

var options = {
  'safe': 'unsafe',
  'standalone': true,
  'attributes': {
    'linkcss': true,
    'source-highlighter': 'highlight.js',
    'docinfodir': '../res/',
    'docinfo': 'shared',
    'stylesheet': '../res/asciidoc.css',
    'kroki-fetch-diagram': true
  }
}
asciidoctor.convertFile('blog/rop-cs.adoc', options)
