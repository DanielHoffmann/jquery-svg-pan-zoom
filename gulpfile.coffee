gulp = require("gulp-help")(require "gulp")
coffee = require "gulp-coffee"
sourcemaps = require "gulp-sourcemaps"


gulp.task("build",
    "Build the package.",
    () ->
        gulp.src "src/**.coffee"
            .pipe sourcemaps.init()
            .pipe coffee()
            .pipe sourcemaps.write(".")
            .pipe gulp.dest("compiled")
);
