const Asciidoctor = require('asciidoctor');
const kroki = require('asciidoctor-kroki');
const highlightJsExt = require('asciidoctor-highlight.js');
const glob = require('glob');
const fs = require('fs');
const cheerio = require('cheerio');

const asciidoctor = Asciidoctor();
kroki.register(asciidoctor.Extensions);
highlightJsExt.register(asciidoctor.Extensions);

const options = {
  safe: 'unsafe',
  standalone: true,
  attributes: {
    linkcss: true,
    nofooter: true,
    'source-highlighter': 'highlightjs-ext',
    docinfodir: '../res/',
    docinfo: 'shared',
    stylesheet: '../res/asciidoc.css',
    'kroki-default-options': 'inline',
    'allow-uri-read': true,
  },
};

if (process.argv[2]) {
  options.to_file = false;
  const html = asciidoctor.convertFile(process.argv[2], options);
  console.log(addTargetBlankToExternalLinks(html));
} else {
  const path = require('path');

  // Change the current working directory to a new path
  const newPath = path.join(__dirname, 'blog');
  process.chdir(newPath);

  // Get the new current working directory
  console.log(process.cwd());

  glob('*.adoc', (err, files) => {
    if (err) {
      console.log(err);
      return;
    }

    files.forEach((file) => {
      fs.readFile(file, 'utf8', (err, asciiDocSource) => {
        if (err) {
          console.log(err);
          return;
        }

        const html = asciidoctor
          .convert(asciiDocSource.replace(/ /g, 'ツ'), options)
          .replace(/ツ/g, ' ');

        fs.writeFile(
          file.replace(/adoc$/, 'html'),
          addTargetBlankToExternalLinks(html),
          (err) => {
            if (err) {
              console.log(err);
              return;
            }
          }
        );
      });
    });
  });
}

function addTargetBlankToExternalLinks(html) {
  const $ = cheerio.load(html);

  $('a').each(function () {
    const href = $(this).attr('href');
    if (href) {
      if (/^https?:\/\//i.test(href)) {
        $(this).attr('target', '_blank');
      } else if (/^#/.test(href)) {
        $(this).attr('target', '_self');
      }
    }
  });

  return $.html();
}
