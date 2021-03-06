/* Notes:
   - gulp/tasks/browserify.js handles js recompiling with watchify
   - gulp/tasks/browserSync.js watches and reloads compiled files
*/

var gulp  = require('gulp');
var config= require('../config');

gulp.task('watch', ['setWatch', 'browserSync'], function() {
  gulp.watch(config.sass.src,   ['sass']);
  gulp.watch(config.images.src, ['images']);
  gulp.watch(config.sounds.src, ['sounds']);
  gulp.watch(config.fonts.src,  ['fonts']);
  gulp.watch(config.markup.src, ['markup']);
  // gulp.watch(config.mapConvert.src, ['mapConvert']);
  gulp.watch(["./src/javascript/**/*.coffee", config.spec.src],  ['spec']);
});

gulp.task('watch-spec', [], function() {
  gulp.watch(["./src/javascript/**/*.coffee", config.spec.src],  ['spec']);
});

