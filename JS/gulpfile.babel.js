const gulp            = require('gulp'),
      babelify        = require('babelify'),
      browserify      = require('browserify'),
      buffer          = require('vinyl-buffer'),
      del             = require('del'),
      minify          = require('gulp-minify'),
      runSequence     = require('run-sequence'),
      size            = require('gulp-size'),
      source          = require('vinyl-source-stream'),
      config = {
          name: 'trust',
          fileTypes: {
            all: '**/*',
            js: '**/*.js',
            main: 'index.js'
          },
          source: {
            baseDir: 'src'
          },
          staging: {
            baseDir: 'staging'
          },
          distribution: {
            baseDir: 'dist',
            javascript: 'js'
          }
        };

gulp.task('clean', function (callback) {
  runSequence('clean:dist', 'clean:stage', callback);
});

gulp.task('clean:stage', function () {
  let stagingDir = `${config.staging.baseDir}/${config.fileTypes.all}`;
  return del.sync(stagingDir);
});

gulp.task('clean:dist', function () {
  let distributionDir = `${config.distribution.baseDir}/${config.fileTypes.all}`;
  return del.sync(distributionDir);
});

gulp.task('javascript', function () {
  let sourceDir  = `${config.source.baseDir}/${config.fileTypes.js}`,
      stagingDir = `${config.staging.baseDir}`;
  return gulp.src(sourceDir)
  .pipe(gulp.dest(stagingDir));
});

gulp.task('bundle:javascript', ['javascript', ], function () {
  let mainFile = `${config.staging.baseDir}/${config.fileTypes.main}`,
      distributionDir = `${config.distribution.baseDir}`;
  return browserify(mainFile)
  .transform(babelify, { presets: ['env'] })
  .bundle()
  .pipe(source(config.name + '.js'))
  .pipe(buffer())
  .pipe(minify())
  .pipe(size())
  .pipe(gulp.dest(distributionDir));
});

gulp.task('build', function (callback) {
  runSequence('clean:dist', 'clean:stage', ['bundle:javascript'],
    callback);
});
 
