path = require('path')

module.exports = (grunt) ->
  codeFiles = ['Gruntfile.coffee', 'src/**/*.coffee']
  allFiles = ['Gruntfile.coffee', 'src/**', 'dependencies/**']

  rebuildTasks = ['coffeelint', 'clean', 'coffee', 'copy', 'run:tests']

  watch =
    files: allFiles
    tasks: rebuildTasks

  coffeelint =
    extension:
      files:
        src: codeFiles
      options:
        configFile: './coffeelint.json'

  clean = ['./bin']

  coffee =
    files:
      expand: true
      cwd: 'src/js'
      src: ['**/*.coffee']
      dest: 'bin/js'
      ext: '.js'

  dependenciesConfig =
    expand: true
    cwd: 'dependencies/'
    src: ['**/*.js']
    dest: 'bin/js/deps/'

  resourcesConfig =
    expand: true
    cwd: 'src/'
    src: ['{manifest.json,html/**,resources/**}']
    dest: 'bin/'

  copy =
    main:
      files: [
        dependenciesConfig,
        resourcesConfig,
      ]

  # path normalization needed for Windows support
  # because Windows CMD doesn't support forward slashes
  runTestsCmd = path.normalize('../../node_modules/.bin/mocha')
  runTestsArgs = '--bail --recursive --reporter spec --ui bdd --timeout 2000 --slow 100'
  run =
    tests:
      exec: "cd bin && cd js && #{runTestsCmd} #{runTestsArgs}"

  config = {watch, coffeelint, clean, coffee, copy, run}
  grunt.initConfig(config)

  grunt.loadNpmTasks('grunt-contrib-watch')
  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-clean')
  grunt.loadNpmTasks('grunt-contrib-copy')
  grunt.loadNpmTasks('grunt-coffeelint')
  grunt.loadNpmTasks('grunt-run')
  # grunt.loadNpmTasks('grunt-contrib-uglify')

  grunt.registerTask('default', rebuildTasks)
