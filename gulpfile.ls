require! {
  fs
  'event-stream'
  gulp
  'gulp-livescript'
  'gulp-header'
  'gulp-uglify'
  'gulp-rename'
  'gulp-bump'
  'gulp-exec'
  'gulp-conventional-changelog'
}

const getJsonFile = ->
  fs.readFileSync './package.json', 'utf-8' |> JSON.parse

const getHeaderStream = ->
  const jsonFile = getJsonFile!

  gulp-header """
/*! angular-ujs - v #{ jsonFile.version } - {{ now }}
 * #{ jsonFile.homepage }
 * Copyright (c) {{ year }} [#{ jsonFile.author.name }](#{ jsonFile.author.url });
 * Licensed [#{ jsonFile.license.type }](#{ jsonFile.license.url })
 */
"""

const getBuildStream = ->
  return gulp.src 'src/angular-ujs.ls'
    .pipe gulp-livescript!
    .pipe getHeaderStream!
    .pipe gulp.dest '.'
    .pipe gulp.dest 'vendor/assets/javascripts/'

gulp.task 'karma' <[ build ]> ->
  return gulp.src 'src/angular-ujs.spec.ls'
    .pipe gulp-livescript!
    .pipe gulp.dest 'tmp/'
    .pipe gulp-exec('karma start misc/karma.conf.js')

gulp.task 'protractor' <[ build ]> ->
  return gulp.src 'src/angular-ujs.scenario.ls'
    .pipe gulp-livescript!
    .pipe gulp.dest 'tmp/'
    .pipe gulp-exec('cd misc/test-scenario && bundle && (RAILS_ENV=test rake db:drop db:migrate) && rails s -d -e test -p 2999 && cd ../..')   
    .pipe gulp-exec('protractor misc/protractor.conf.js')
    .pipe gulp-exec('kill $(lsof -i :2999 -t)')

gulp.task 'bump' ->
  return gulp.src 'package.json'
    .pipe gulp-bump type: 'patch'
    .pipe gulp.dest '.'

gulp.task 'uglify' <[ bump ]> ->
  return getBuildStream!
    .pipe gulp-uglify!
    .pipe getHeaderStream!
    .pipe gulp-rename ext: '.min.js'
    .pipe gulp.dest '.'

gulp.task 'before-release' <[ uglify ]> ->
  const jsonFile = getJsonFile!
  const commitMsg = "chore(release): v#{ jsonFile.version }"

  return gulp.src <[ package.json CHANGELOG.md ]>
    .pipe gulp-conventional-changelog!
    .pipe gulp.dest '.'
    .pipe gulp-exec('git add -A')
    .pipe gulp-exec("git commit -m '#{ commitMsg }'")
    .pipe gulp-exec("git tag -a v#{ jsonFile.version } -m '#{ commitMsg }'")
    .pipe gulp-exec('git push')

/*
 * Public tasks: 
 *
 * test, watch, release
 */
gulp.task 'test' <[ karma protractor ]>

gulp.task 'build' getBuildStream

gulp.task 'watch' ->
  gulp.run 'test'

  gulp.watch 'src/*.ls' !->
    gulp.run 'test' # optimize ...

gulp.task 'release' <[ before-release ]> ->
  return gulp.src 'package.json'
    .pipe gulp-exec('rake build release')
