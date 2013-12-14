/*global module:false*/
module.exports = function(grunt) {
  // Project configuration.
  /*jshint scripturl:true*/
  grunt.initConfig({
    // Metadata.
    pkg: grunt.file.readJSON('package.json'),
    fdr: {
      src:    'src/',
      dest:   './'
    },
    banner: '' +
      '/*! <%= pkg.title || pkg.name %> - v<%= pkg.version %> - <%= grunt.template.today("yyyy-mm-dd") %>\n' +
      '<%= pkg.homepage ? " * " + pkg.homepage + "\\n" : "" %>' +
      ' * Copyright (c) <%= grunt.template.today("yyyy") %> [<%= pkg.author.name %>](<%= pkg.author.url %>);\n' +
      ' * Licensed [<%= pkg.license.type %>](<%= pkg.license.url %>)\n' +
      ' */\n',
    // Task configuration.
    livescript: { compile: {
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
        src: '<%= pkg.name %>*.js',
        dest: 'vendor/assets/javascripts/',
        filter: 'isFile'
      }
    }
  });
  // These plugins provide necessary tasks.
  grunt.loadNpmTasks('grunt-livescript');
  grunt.loadNpmTasks('grunt-contrib-uglify');
  grunt.loadNpmTasks('grunt-contrib-copy');
  //
  grunt.registerTask('default', ['livescript:compile', 'uglify:compile', 'copy:rubygem'])
};
