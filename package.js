Package.describe({
  name: 'oorabona:spider-seo',
  version: '0.0.1',
  summary: 'All-in-One crawler friendly and SEO toolkit',
  git: '',
  documentation: 'README.md'
});

Package.onUse(function(api) {
  api.versionsFrom('1.5');
  api.use('ecmascript');
  api.use('blaze-html-templates@1.0.4');
  api.use('underscore');
  api.use('webapp');
  api.use('coffeescript@1.0.17');
  api.use('mdg:validated-method@1.1.0');
  api.use('mongo');
  api.mainModule('spider-seo.coffee', ['client', 'server']);
  api.mainModule('client/main.coffee', 'client');
  api.mainModule('server/main.coffee', 'server');
});

Npm.depends({
  'js-sha256': '0.6.0'
});

Package.onTest(function(api) {
  api.use('ecmascript');
  api.use('coffeescript');
  api.use('tinytest');
  api.use('oorabona:spider-seo');
  api.mainModule('spider-seo-tests.js');
});
