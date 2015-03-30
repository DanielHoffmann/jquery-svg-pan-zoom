"use strict";

var gulp = require("gulp-help")(require("gulp"));
var coffee = require("gulp-coffee");
var sourcemaps = require("gulp-sourcemaps");


gulp.task("build",
  "Build the package.",
  function () {
    return gulp.src("src/**.coffee")
      .pipe(sourcemaps.init())
      .pipe(coffee())
      .pipe(sourcemaps.write("."))
      .pipe(gulp.dest("compiled"));
  }
);
