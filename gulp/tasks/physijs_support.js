var changed    = require('gulp-changed');
var gulp       = require('gulp');
var merge       = require('merge-stream');

gulp.task('physijs_support', function() {
  var worker = gulp.src('src/javascript/vendor/physijs_worker.js')
    .pipe(gulp.dest('build'));

  var ammo = gulp.src('src/javascript/vendor/ammo.js')
    .pipe(gulp.dest('build'));

  return merge(worker, ammo);
});
