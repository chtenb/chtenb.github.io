const Asciidoctor = require('asciidoctor')
const kroki = require('asciidoctor-kroki')
const glob = require('glob')

var asciidoctor = Asciidoctor()

kroki.register(asciidoctor.Extensions)

var options = {
  'safe': 'unsafe',
  'standalone': true,
  'attributes': {
    'linkcss': true,
    'source-highlighter': 'highlight.js',
    // 'highlightjs-theme': 'solarized-light',
    'docinfodir': '../res/',
    'docinfo': 'shared',
    'stylesheet': '../res/asciidoc.css',
    'kroki-default-options': 'inline',
    'allow-uri-read': true
  }
}

glob('blog/*.adoc', function (err, files) {
  if (err) {
    console.log(err)
  } else {
    files.forEach(function (file) {
      asciidoctor.convertFile(file, options)
    });
  }
});
