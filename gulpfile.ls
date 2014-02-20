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

function getJsonFile
  fs.readFileSync './package.json', 'utf-8' |> JSON.parse

function getHeaderStream
  const jsonFile = getJsonFile!
  const date = new Date

  gulp-header """
/*! angular-ujs - v #{ jsonFile.version } - #{ date }
 * #{ jsonFile.homepage }
 * Copyright (c) #{ date.getFullYear! } [#{ jsonFile.author.name }](#{ jsonFile.author.url });
 * Licensed [#{ jsonFile.license.type }](#{ jsonFile.license.url })
 */
"""

gulp.task 'test:karma' ->
  stream = gulp.src 'package.json'
    .pipe gulp-exec('karma start test/karma.conf.js')
  
  return if process.env.TRAVIS
    const TO_COVERALLS = 'find ./coverage -name lcov.info -follow -type f -print0 | xargs -0 cat | node_modules/.bin/coveralls'
    stream.pipe gulp-exec(TO_COVERALLS) 
  else
    stream

gulp.task 'test:protractor' ->
  stream = gulp.src 'package.json'
  
  stream = stream.pipe gulp-exec [
    'cd test/scenario-rails'
    'bundle install'
    'RAILS_ENV=test rake db:drop db:migrate'
    'rails s -d -e test -p 2999'
    'cd ../..'
  ].join ' && ' unless process.env.TRAVIS
  
  stream = stream.pipe gulp-exec('protractor test/protractor.conf.js')
  stream = stream.pipe gulp-exec('kill $(lsof -i :2999 -t)') unless process.env.TRAVIS
  
  return stream

gulp.task 'release:bump' ->
  return gulp.src <[ package.json bower.json ]>
    .pipe gulp-bump type: 'patch'
    .pipe gulp.dest '.'

gulp.task 'release:build' <[ release:bump ]> ->
  return gulp.src 'src/angular-ujs.ls'
    .pipe gulp-livescript!
    .pipe getHeaderStream!
    .pipe gulp.dest '.'
    .pipe gulp.dest 'vendor/assets/javascripts/'
    .pipe gulp-uglify preserveComments: 'some'
    .pipe gulp-rename extname: '.min.js'
    .pipe gulp.dest '.'

gulp.task 'release:commit' <[ release:build ]> ->
  const jsonFile = getJsonFile!
  const commitMsg = "chore(release): v#{ jsonFile.version }"

  return gulp.src <[ package.json CHANGELOG.md ]>
    .pipe gulp-conventional-changelog!
    .pipe gulp.dest '.'
    .pipe gulp-exec('git add -A')
    .pipe gulp-exec("git commit -m '#{ commitMsg }'")
    .pipe gulp-exec("git tag -a v#{ jsonFile.version } -m '#{ commitMsg }'")

gulp.task 'publish:git' <[ release:commit ]> ->
  return gulp.src 'package.json'
    .pipe gulp-exec('git push')
    .pipe gulp-exec('git push --tags')

gulp.task 'publish:rubygems' <[ release:commit ]> ->
  return gulp.src 'package.json'
    .pipe gulp-exec('rake build release')
/*
 * Public tasks: 
 *
 * test, watch, release
 */
gulp.task 'test' <[ test:karma test:protractor ]>

gulp.task 'watch' <[ test ]> ->
  gulp.watch 'src/*.ls' <[ test:karma ]>

gulp.task 'release' <[ publish:git publish:rubygems ]>
/*
 * Public tasks end 
 *
 * 
 */
