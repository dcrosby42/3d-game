var gulp = require('gulp');

gulp.task('build', [
    'browserify',
    'sass',
    'images',
    'sounds',
    'fonts',
    'markup',
    'physijs_support'
    // 'mapConvert'
    ]);
