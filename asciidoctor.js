const Asciidoctor = require('asciidoctor')
var asciidoctor = Asciidoctor()

var options = {
  'safe': 'unsafe',
  'standalone': true,
  'attributes': {
    'linkcss': true,
    'source-highlighter': 'highlight.js',
    'docinfodir': '../res/',
    'docinfo': 'shared',
    'stylesheet': '../res/asciidoc.css'
  }
}
asciidoctor.convertFile('blog/rop-cs.adoc', options)
