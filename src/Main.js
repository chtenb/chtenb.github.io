"use strict";

exports.executeJavascriptHacks = function () {
  // Hack to be able to use the right viewport height in the CSS, because the CSS vh value doesn't behave well on mobile.
  var root = document.querySelector(':root');
  window.addEventListener('resize', () => {
    root.style.setProperty('--app-height', vh() + 'px');
  });
  function vh() {
    // - 1 because sometimes the innerHeight doesn't seem to be rounded correctly or something
    return Math.max(document.documentElement.clientHeight, window.innerHeight || 0) - 1;
  }
};
