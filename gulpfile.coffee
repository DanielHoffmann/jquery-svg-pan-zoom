gulp = require("gulp-help")(require "gulp")
coffee = require "gulp-coffee"
sourcemaps = require "gulp-sourcemaps"
filter = require "gulp-filter"
uglify = require "gulp-uglify"
rename = require "gulp-rename"


gulp.task("build",
    "Build the package.",
    () ->
        gulp.src "src/**.coffee"
            .pipe sourcemaps.init()
            .pipe coffee()
            .pipe sourcemaps.write(".")
            .pipe gulp.dest("compiled")
            .pipe filter("*.js")
            .pipe uglify()
            .pipe rename(suffix: ".min")
            .pipe gulp.dest("compiled")
);
