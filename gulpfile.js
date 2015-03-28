"use strict";

var gulp = require("gulp-help")(require("gulp"));
var coffee = require("gulp-coffee");


gulp.task("build",
  "Build the package.",
  function () {
    return gulp.src("src/**.coffee")
      .pipe(coffee())
      .pipe(gulp.dest("compiled"));
  }
);
