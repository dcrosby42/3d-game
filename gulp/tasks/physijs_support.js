var changed    = require('gulp-changed');
var gulp       = require('gulp');
var merge       = require('merge-stream');

gulp.task('physijs_support', function() {
  var worker = gulp.src('node_modules/physijs-browserify/libs/physi-worker.js')
    .pipe(gulp.dest('build'));

  var ammo = gulp.src('node_modules/physijs-browserify/libs/ammo.js')
    .pipe(gulp.dest('build'));

  return merge(worker, ammo);
});
