/*global module:false*/
module.exports = function(grunt) {
  // These plugins provide necessary tasks.
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-karma');
  grunt.loadNpmTasks('grunt-livescript');
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-contrib-copy');
  grunt.loadNpmTasks('grunt-bump');
  // Project configuration.
  /*jshint scripturl:true*/
  grunt.initConfig({
    // Metadata.
    pkg: grunt.file.readJSON('package.json'),
    fdr: {
      src:    'src/',
      tmp:    'tmp/',
      dest:   './'
    },
    banner: '' +
      '/*! <%= pkg.title || pkg.name %> - v<%= pkg.version %> - <%= grunt.template.today("yyyy-mm-dd") %>\n' +
      '<%= pkg.homepage ? " * " + pkg.homepage + "\\n" : "" %>' +
      ' * Copyright (c) <%= grunt.template.today("yyyy") %> [<%= pkg.author.name %>](<%= pkg.author.url %>);\n' +
      ' * Licensed [<%= pkg.license.type %>](<%= pkg.license.url %>)\n' +
      ' */\n',
    // Task configuration.
    delta: {
      ls: {
        files: ['<%= fdr.src %><%= pkg.name %>.*.ls'],
        tasks: ['livescript:watch']
      },
      js: {
        files: ['<%= fdr.tmp %><%= pkg.name %>.*.ls'],
        tasks: ['karma:watch:run']
      }
    },
    livescript: { watch: {
        expand: true,
        cwd: '<%= fdr.src %>',
        src: '<%= pkg.name %>.*.ls',
        dest: '<%= fdr.tmp %>',
        filter: 'isFile'
      },          compile: {
        src: '<%= fdr.src %><%= pkg.name %>.js.ls',
        dest: '<%= fdr.dest %><%= pkg.name %>.js'
      }
    },
    uglify: { compile: {
        src: '<%= livescript.compile.dest %>',
        dest: '<%= grunt.config.get("livescript.compile.dest").replace(".js", ".min.js") %>'
      },
      options: { banner: '<%= banner %>' }
    },
    copy: { rubygem: {
        expand: true,
        cwd: '<%= fdr.dest %>',
        src: '<%= pkg.name %>.js',
        dest: 'vendor/assets/javascripts/',
        filter: 'isFile'
      }
    },
    karma: {
      options: {
        frameworks: ['jasmine'],
        files: [
          'misc/test-lib/jquery-1.10.2.min.js',
          'misc/test-lib/angular.1.2.6.min.js',
          'misc/test-lib/angular-mocks.1.2.6.js',
          '<%= fdr.tmp %><%= pkg.name %>.*.ls'
        ],
        browsers: ['Chrome'],
        port: 9018,
        runnerPort: 9100,
        colors: true,
        autoWatch: false,
        singleRun: false
      },
      watch: {
        background: true
      },
      continuous: {
        singleRun: true
      }
    },
    bump: {
      options: {
        commit: true,
        commitMessage: 'Release v%VERSION%',
        commitFiles: ['-a'],
        tagName: 'v%VERSION%', // consistent with ruby gems
        pushTo: 'origin'
      }
    }
  });
  //
  grunt.renameTask('watch', 'delta');
  grunt.registerTask('watch', ['karma:watch', 'delta']);
  //
  grunt.registerTask('build', ['livescript:compile', 'uglify:compile', 'copy:rubygem'])
  grunt.registerTask('test', ['livescript:watch', 'karma:continuous']);
  grunt.registerTask('default', ['build', 'test']);
};
