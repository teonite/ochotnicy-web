/*
*
* Portal Ochotnicy - http://ochotnicy.pl
*
* Copyright (C) Pracownia badań i innowacji społecznych Stocznia
*
* Development: TEONITE - http://teonite.com
*
*/
exports.config = {
  allScriptsTimeout: 11000,

  specs: [
    '*.js'
  ],

  capabilities: {
    'browserName': 'chrome'
  },

  baseUrl: 'http://localhost:8000/app/',

  framework: 'jasmine',

  jasmineNodeOpts: {
    defaultTimeoutInterval: 30000
  }
};
