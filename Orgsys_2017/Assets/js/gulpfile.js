const gulp = require('gulp');
const less = require('gulp-less');

// Where your Less files are located
const srcDir = './src/assets/style/less';
// Where your CSS files will be generated
const dstDir = './src/assets/style/css';

gulp.task('less', function () {
    gulp
        .src(`${srcDir}/*.less`)
        .pipe(less())
        .pipe(gulp.dest(dstDir));
});

gulp.task('default', ['less'], function () {
    gulp.watch(`${srcDir}/*.less`, ['less']);
});
