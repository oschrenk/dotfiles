// https://github.com/scalameta/sbt-scalafmt
//
// tasks
//   myproject/scalafmt: Format main sources of myproject project
//   myproject/Test/scalafmt: Format test sources of myproject project
//   scalafmtCheck: Check if the scala sources under the project have been formatted
//   scalafmtSbt: Format *.sbt and project/*.scala files
//   scalafmtSbtCheck: Check if the files have been formatted by scalafmtSbt
//   scalafmtOnly <file>...: Format specified files listed.
//   scalafmtAll or scalafmtCheckAll: Execute the scalafmt or scalafmtCheck task for all configurations
addSbtPlugin("org.scalameta" % "sbt-scalafmt" % "2.5.0")
