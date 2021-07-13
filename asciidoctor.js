const Asciidoctor = require('asciidoctor')
var asciidoctor = Asciidoctor()
asciidoctor.convertFile('blog/rop-cs.adoc', { safe: 'unsafe', standalone: true })
