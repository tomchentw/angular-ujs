/*global module:false*/
module.exports = function(grunt) {
  // These plugins provide necessary tasks.
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-karma');
  grunt.loadNpmTasks('grunt-shell');
  grunt.loadNpmTasks('grunt-protractor-runner');

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
          '<%= fdr.tmp %><%= pkg.name %>.js.ls',
          '<%= fdr.tmp %><%= pkg.name %>.spec.ls'
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
      travis: {
        singleRun: true,
        browsers: ['Firefox']
      },
      continuous: {
        singleRun: true
      }
    },
    shell: {
      options: {
        stdout: true
      },
      rubygem: {
        command: 'rake build'
      },
      'rubygem-release': {
        command: 'rake release'
      },
      'pre-continuous': {
        command: 'cd misc/test-scenario && bundle && (RAILS_ENV=test rake db:drop db:migrate) && rails s -d -e test -p 2999 && cd ../..'
      },
      'post-continuous': {
        command: 'kill $(lsof -i :2999 -t)'
      }
    },
    protractor: {
      options: {
        noColor: false
      },
      travis: {
        options: {
          configFile: 'misc/protractorConf.travis.js',
          keepAlive: false
        }
      },
      continuous: {
        options: {
          configFile: 'misc/protractorConf.js',
          keepAlive: true
        }
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
  grunt.registerTask('watch', ['livescript:watch', 'karma:watch', 'delta']);
  //
  grunt.registerTask('build', ['livescript:compile', 'uglify:compile', 'copy:rubygem', 'shell:rubygem'])
  grunt.registerTask('continuous', ['livescript:watch', 'test-karma', 'test-protractor']);
  grunt.registerTask('default', ['build', 'continuous']);
  //
  grunt.registerTask('release', ['bump-only:patch', 'default', 'bump-commit', 'shell:rubygem-release']);

  // from: https://github.com/angular-ui/bootstrap/blob/master/Gruntfile.js
  grunt.registerTask('test-karma', 'Run tests on singleRun karma server', function () {
    //this task can be executed in 3 different environments: local, Travis-CI and Jenkins-CI
    //we need to take settings for each one into account
    if (process.env.TRAVIS) {
      grunt.task.run('karma:travis');
    } else {
      // var isToRunJenkinsTask = !!this.args.length;
      // if(grunt.option('coverage')) {
      //   var karmaOptions = grunt.config.get('karma.options'),
      //     coverageOpts = grunt.config.get('karma.coverage');
      //   grunt.util._.extend(karmaOptions, coverageOpts);
      //   grunt.config.set('karma.options', karmaOptions);
      // }
      // grunt.task.run(this.args.length ? 'karma:jenkins' : 'karma:continuous');
      grunt.task.run('karma:continuous');
    }
  });
  //
  // run ruby + nodejs on travis-ci
  //
  // http://stackoverflow.com/a/18457016/1458162
  //
  grunt.registerTask('test-protractor', 'Run tests on protractor server', function () {
    //this task can be executed in 3 different environments: local, Travis-CI and Jenkins-CI
    //we need to take settings for each one into account
    if (process.env.TRAVIS) {
      grunt.task.run('protractor:travis');
    } else {
      grunt.task.run('shell:pre-continuous', 'protractor:continuous', 'shell:post-continuous');
    }
  });
};
