#
# Portal Ochotnicy - http://ochotnicy.pl
#
# Copyright (C) Pracownia badań i innowacji społecznych Stocznia
#
# Development: TEONITE - http://teonite.com
#
module.exports = (grunt) ->

  # load all grunt tasks
  (require 'matchdep').filterDev('grunt-*').forEach(grunt.loadNpmTasks)
  (require 'time-grunt')(grunt);

  modRewrite = require('connect-modrewrite')

  grunt.initConfig
    pkg: grunt.file.readJSON("package.json")

  # configuration
    config:
      dev:
        options:
          variables:
            env: "app_conf/conf_dev.js"

      prod:
        options:
          variables:
            env: "app_conf/conf_prod.js"

      uat:
        options:
          variables:
            env: "app_conf/conf_uat.js"

      docker:
        options:
          variables:
            env: "app_conf/conf_docker.js"

    inject:
      single:
        scriptSrc: "<%= grunt.config.get('env') %>"
        files:
          "dist/index.html": "src/index.html"

  # coffee compilation
    coffee:
      compileWithMaps:
        options:
          sourceMap: true
        files: [
          expand: true
          cwd: 'src'
          src: ["**/*.coffee"]
          dest: 'tmp/coffee'
          ext: '.js'
        ]

    "git-describe":
      options:
        template: "{%=tag%}-{%=object%}"
      me: {}

    replace:
      dist:
        options:
          patterns: [
            {
              match: 'version'
              replacement: "<%= grunt.option('gitRevision') %>"
            }
          ]
        files: [
          {expand: true, flatten: true, src: ["<%= grunt.config.get('env') %>"], dest: 'app_conf/'}
        ]

    cacheBust:
      options:
        encoding: 'utf8',
        algorithm: 'md5',
        length: 16,
        deleteOriginals: true
      files:
        src: ['dist/index.html']

    uglify:
      dist:
        options:
          mangle: true
          sourceMap: true
          compress:
            dead_code: true
            drop_debugger: true
            booleans: true
            loops: true
            if_return: true
            drop_console: true
#          screwIE8: true
          preserveComments: false
        files:
          'dist/js/app.min.js': ['dist/js/app.js'],


    ngAnnotate:
      options:
        singleQuotes: true
      app:
        files:
          'dist/js/app.js': ['dist/js/app.js']

    htmlmin:
      dist:
        options:
          removeComments: true
          collapseWhitespace: true
          removeEmptyAttributes: true
#          lint: true
        files:
          'dist/index.html': 'dist/index.html'

    html2js:
      commonDirectives:
        options:
          module: "wolontariat.templates.directives" # ANGULAR MODULE NAME
          base: "src/app/directives" # REMOVE PATH FROM FILE
          htmlmin:
            collapseWhitespace: true
            removeComments: true
            removeEmptyAttributes: true

        dest: "tmp/commonDirectives.js"
        src: [
          "src/app/directives/*/*.html"
          "src/app/templates/*/*.html"
        ]

      commonTemplates:
        options:
          module: "wolontariat.templates" # ANGULAR MODULE NAME
          base: "src/app/templates" # REMOVE PATH FROM FILE
          htmlmin:
            collapseWhitespace: true
            removeComments: true
            removeEmptyAttributes: true

        dest: "tmp/commonTemplates.js"
        src: ["src/app/templates/*.html"]

    cssmin:
      dist:
        options:
          keepSpecialComments: false

        files:
          'dist/css/css.css': ['dist/css/css.css']
          'dist/css/bootstrap-chosen.css': ['dist/css/bootstrap-chosen.css']


    bowercopy:
      dist:
        options:
          srcPrefix: "bower_components"
          destPrefix: "dist/lib"
          runBower: false
          report: true
        files:
          "jquery/jquery.min.js": "jquery/jquery.min.js"
          "angular-notify/angular-notify.min.js": "angular-notify/dist/angular-notify.min.js"
          "angular-cookie/angular-cookie.min.js": "angular-cookie/angular-cookie.min.js"
          "chosen/chosen.jquery.min.js": "chosen/chosen.jquery.min.js"
          "moment/moment.min.js": "moment/min/moment.min.js"
          "moment/locale/pl.js": "moment/locale/pl.js"
          "chartjs/Chart.min.js": "chartjs/Chart.min.js"
          "lodash/lodash.min.js": "lodash/dist/lodash.min.js"
          "tinymce/tinymce.min.js": "tinymce-builded/js/tinymce/tinymce.min.js"
          "angular/angular.min.js": "angular/angular.min.js"
          "angular-i18n/angular-locale_pl-pl.js": "angular-i18n/angular-locale_pl-pl.js"
          "angular-aria/angular-aria.min.js": "angular-aria/angular-aria.min.js"
          "angular-messages/angular-messages.min.js": "angular-messages/angular-messages.min.js"
          "angular-ui-router/angular-ui-router.min.js": "angular-ui-router/release/angular-ui-router.min.js"
          "angular-bootstrap/ui-bootstrap-tpls.min.js": "angular-bootstrap/ui-bootstrap-tpls.min.js"
          "angular-resource/angular-resource.min.js": "angular-resource/angular-resource.min.js"
          "angular-cookies/angular-cookies.min.js": "angular-cookies/angular-cookies.min.js"
          "angular-chosen-localytics/chosen.js": "angular-chosen-localytics/chosen.js"
          "angular-auth/angular-auth.js": "angular-auth/dist/angular-auth.js"
          "angular-moment/angular-moment.min.js": "angular-moment/angular-moment.min.js"
          "angles/angles.js": "angles/angles.js"
          "angular-google-maps/angular-google-maps.min.js": "angular-google-maps/dist/angular-google-maps.min.js"
          "angular-utils-pagination/dirPagination.js": "angular-utils-pagination/dirPagination.js"
          "ng-file-upload-shim/angular-file-upload.min.js": "ng-file-upload-shim/angular-file-upload.min.js"
          "angular-ui-tinymce/tinymce.js": "angular-ui-tinymce/src/tinymce.js"
          "angular-sanitize/angular-sanitize.min.js": "angular-sanitize/angular-sanitize.min.js"
          "angular-ui-utils/ui-utils.min.js": "angular-ui-utils/ui-utils.min.js"
          "ngstorage/ngStorage.min.js": "ngstorage/ngStorage.min.js"
          "angular/angular-csp.css": "angular/angular-csp.css"
          "bootstrap/css/bootstrap.min.css": "bootstrap/dist/css/bootstrap.min.css"
          "chosen/chosen.min.css": "chosen/chosen.min.css"
          "font-awesome/css/font-awesome.min.css": "font-awesome/css/font-awesome.min.css"
          "bootstrap/fonts/": "bootstrap/fonts/*"
          "font-awesome/fonts/": "font-awesome/fonts/*"
          "tinymce/langs/": "tinymce-builded/js/tinymce/langs/*.js"
          "tinymce/plugins/": "tinymce-builded/js/tinymce/plugins/"
          "tinymce/themes/modern/theme.min.js": "tinymce-builded/js/tinymce/themes/modern/theme.min.js"
          "tinymce/skins/lightgray/": "tinymce-builded/js/tinymce/skins/lightgray/*.min.css"
          "tinymce/skins/lightgray/fonts/": "tinymce-builded/js/tinymce/skins/lightgray/fonts/"
          "tinymce/skins/lightgray/img/": "tinymce-builded/js/tinymce/skins/lightgray/img/"
    copy:
      main:
        files: [
          {
            src: "src/index.html"
            dest: "dist/index.html"
          }
          {
            expand: true
            cwd: "src/css/"
            src: ["**"]
            dest: "dist/css/"
          }
          {
            expand: true
            cwd: "src/img/"
            src: ["**"]
            dest: "dist/img/"
          }
          {
            expand: true
            cwd: 'src/fonts/'
            src: ["**"]
            dest: 'dist/fonts'
          }
        ]

  # group compiled js files (tmp dir)
    common:
      directives: ["tmp/coffee/app/directives/*/*.js"]
      services: ["tmp/coffee/app/services/*.js"]
      filters: ["tmp/coffee/app/filters/*.js"]
      controllers: ["tmp/coffee/app/controllers/*.js"]

    dashboard: {}
    configuration: {}

  # CONCAT GROUPED FILES IN SEPARATED FILES
    concat:
      dist:
        files:
          "dist/js/app.js": [
            "tmp/intro.js"
            "tmp/coffee/app/app.js"
            "<%= common.directives %>"
            "<%= common.services %>"
            "<%= common.filters %>"
            "<%= common.controllers %>"
            "tmp/commonDirectives.js"
            "tmp/commonTemplates.js"
          ]

  # WATCH CHANGES
    watch:
      options:
        livereload: true #works with Chrome LiveReload extension. See: https://github.com/gruntjs/grunt-contrib-watch

      files: [
        "src/scss/*.scss"
        "src/**/*.html"
        "src/**/*.js"
        "src/**/*.coffee"
        "src/**/*.html"
        "src/**/*.css"
      ]
      tasks: ['default']

    clean:
      tmp: ["tmp"]
      dist: ["dist"]
      appjs: ["dist/js/app.js"]

    connect:
      dev:
        options:
          port: 8888
          hostname: "0.0.0.0"
          base: "dist"
          keepalive: true
          middleware: (connect, options, middlewares) ->
            rules = [
                "!\\.html|\\.js|\\.css|\\.svg|\\.jp(e?)g|\\.png|\\.gif|\\.woff|\\.eot|\\.ttf$ /index.html"
            ];
            middlewares.unshift( modRewrite( rules ) );
            return middlewares;

        livereload:
          options:
            open: true

  # TASKS
  grunt.registerTask "saveRevision", ->
    grunt.event.once('git-describe', (rev) ->
        grunt.option('gitRevision', rev);
    );
    grunt.task.run('git-describe');
    return

  grunt.registerTask "dist", [
    "saveRevision"
    "coffee"
    "html2js"
    "replace"
    "concat"
    "copy"
    "bowercopy:dist"
    "inject"
    "ngAnnotate"
    "uglify:dist"
    "htmlmin:dist"
    "cssmin:dist"
    "cacheBust"
    "clean:tmp"
    "clean:appjs"
  ]
  grunt.registerTask "dev", [
    "config:dev"
    "dist"
  ]
  grunt.registerTask "prod", [
    "config:prod"
    "dist"
  ]
  grunt.registerTask "uat", [
    "config:uat"
    "dist"
  ]
  grunt.registerTask "docker", [
    "config:docker"
    "dist"
  ]
  grunt.registerTask "default", [
    "clean"
    "dev"
  ]
  grunt.registerTask "start", [
    'dev',
    'connect'
  ]

  return
