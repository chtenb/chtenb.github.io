const Asciidoctor = require('asciidoctor')
var asciidoctor = Asciidoctor()

var options = {
  'safe': 'unsafe',
  'standalone': true,
  'extension_registry': registry,
  'attributes': {
    'linkcss': true,
    'source-highlighter': 'highlight.js',
    'docinfodir': '../res/',
    'docinfo': 'shared'
  }
}
asciidoctor.convertFile('blog/rop-cs.adoc', options)
