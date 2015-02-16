path = require('path')

module.exports = (grunt) ->
  files = ['Gruntfile.coffee', 'src/**/*.coffee']

  watch =
    files: files
    tasks: ['coffeelint', 'clean', 'coffee', 'run:tests']

  coffeelint =
    extension:
      files:
        src: files
      options:
        configFile: './coffeelint.json'

  clean = ["./bin"]

  coffee =
    files:
      expand: true,
      cwd: 'src/js',
      src: ['**/*.coffee'],
      dest: 'bin/js',
      ext: '.js'

  # path normalization needed for Windows support
  # because Windows CMD doesn't support forward slashes
  run_tests_cmd = path.normalize('../../node_modules/.bin/mocha')
  run_tests_args = '--bail --recursive --reporter spec --ui bdd --timeout 2000 --slow 100'
  run =
    tests:
      exec: "cd bin && cd js && #{run_tests_cmd} #{run_tests_args}"

  config = {watch, coffeelint, clean, coffee, run}
  grunt.initConfig(config)

  grunt.loadNpmTasks('grunt-contrib-watch')
  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-clean')
  grunt.loadNpmTasks('grunt-coffeelint')
  grunt.loadNpmTasks('grunt-run')
  # grunt.loadNpmTasks('grunt-contrib-uglify')

  grunt.registerTask('default', ['coffeelint', 'clean', 'coffee', 'run:tests'])
