"use strict";

export const executeJavascriptHacks = function () {
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

export const executeSiteAnalytics = function () {
  window.dataLayer = window.dataLayer || [];
  function gtag() { dataLayer.push(arguments); }
  gtag('js', new Date());

  gtag('config', 'G-ZNEGXK8M3D');
}

export const spy = function (x) {
  return function () {
    console.log(x);
  }
}
