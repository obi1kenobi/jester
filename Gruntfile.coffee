path = require('path')
os = require('os')

sourcePath = 'src'
outputPath = 'bin'
codeDir    = 'js'

# inside bin/
devDir  = 'unpacked-dev'
prodDir = 'unpacked-prod'
tempDir = 'tmp'

unpackedDevPath    = "#{outputPath}/#{devDir}"
unpackedProdPath   = "#{outputPath}/#{prodDir}"
tempPath           = "#{outputPath}/#{tempDir}"
tempCodePath       = "#{tempPath}/#{codeDir}"
codePath           = "#{sourcePath}/#{codeDir}"
outputCodePath     = "#{outputPath}/#{codeDir}"

packagePath        = 'package.json'
manifestPath       = "#{sourcePath}/manifest.json"
manifestOutputPath = "#{unpackedDevPath}/manifest.json"
coffeelintPath     = 'coffeelint.json'
gruntfilePath      = 'Gruntfile.coffee'
signingKeyPath     = 'signingKey.pem'

sourceResources = ['html/**', 'resources/**']

module.exports = (grunt) ->
  packageFile = grunt.file.readJSON(packagePath)
  manifestFile = grunt.file.readJSON(manifestPath)

  crxPath = path.normalize("#{outputPath}/#{packageFile.name}-#{packageFile.version}.crx")

  fileMaps =
    browserify: {}
    uglify: {}

  codeFiles = grunt.file.expand {cwd: codePath, matchBase: true}, ['*.coffee']
  nonTestCodeFiles = grunt.file.expand {cwd: codePath}, ['extension/**/*.coffee', 'lib/**/*.coffee']

  for file in nonTestCodeFiles
    jsFile = file.replace('.coffee', '.js')
    browserfied = "#{unpackedDevPath}/#{codeDir}/#{jsFile}"
    fileMaps.browserify[browserfied] = "#{tempCodePath}/#{jsFile}"
    fileMaps.uglify["#{unpackedProdPath}/#{codeDir}/#{jsFile}"] = browserfied

  # grunt-contrib-clean
  clean =
    all: [unpackedDevPath, unpackedProdPath, tempPath, "#{outputPath}/*.crx"]
    temp: [tempPath]

  # grunt-coffeelint
  coffeelint =
    all:
      files:
        src: ["#{sourcePath}/**/*.coffee"]
      options:
        configFile: coffeelintPath

  # grunt-contrib-coffee
  coffee =
    files:
      expand: true
      cwd: codePath
      src: ['**/*.coffee']
      dest: tempCodePath
      ext: '.js'

  # grunt-mkdir
  mkdir =
    unpacked:
      options:
        create: [unpackedDevPath, unpackedProdPath]
    js:
      options:
        create: ["#{unpackedDevPath}/#{codeDir}"]

  # grunt-contrib-copy
  copy =
    main:
      files: [ {
        expand: true
        cwd: sourcePath
        src: sourceResources
        dest: unpackedDevPath
      } ]
    prod:
      files: [ {
        # the manifest is generated directly into the output directory
        # copy the dev directory minus compiled js to prevent code duplication
        expand: true
        cwd: unpackedDevPath
        src: ['**', '!js/*.js']
        dest: unpackedProdPath
      }]

  # grunt-browserify
  browserify =
    build:
      files: fileMaps.browserify
      options:
        browserifyOptions:
          debug: true
          standalone: packageFile['export-symbol']

  # grunt-contrib-uglify
  uglify =
    min:
      files: fileMaps.uglify

  # grunt-contrib-watch
  watch =
    files: [gruntfilePath, "#{sourcePath}/**"]
    tasks: ['test']

  if os.platform().indexOf('win') == 0
    mvCommand = 'move /Y'
    crxmakeCommand = 'sh crxmake.sh'
  else
    mvCommand = 'mv -v'
    crxmakeCommand = './crxmake.sh'

  # grunt-run
  run =
    tests:
      exec: []
    crx:
      exec: [
        "#{crxmakeCommand} #{unpackedProdPath} #{signingKeyPath}",
        "#{mvCommand} #{prodDir}.crx #{crxPath}"
      ].join(' && ')


  config = {clean, coffeelint, coffee, mkdir, copy, browserify, uglify, watch, run}
  grunt.initConfig(config)

  grunt.loadNpmTasks('grunt-contrib-watch')
  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-clean')
  grunt.loadNpmTasks('grunt-contrib-copy')
  grunt.loadNpmTasks('grunt-contrib-uglify')
  grunt.loadNpmTasks('grunt-coffeelint')
  grunt.loadNpmTasks('grunt-browserify')
  grunt.loadNpmTasks('grunt-run')
  grunt.loadNpmTasks('grunt-mkdir')


  #
  # custom tasks
  #

  grunt.registerTask 'manifest', 'Extend manifest.json with extra fields from package.json', () ->
    for field in ['name', 'version', 'description']
      manifestFile[field] = packageFile[field]
    grunt.file.write(manifestOutputPath, JSON.stringify(manifestFile, null, 4) + '\n')
    grunt.log.ok('manifest.json generated')

  grunt.registerTask('build',
    ['clean:all', 'coffeelint', 'coffee', 'copy:main', 'manifest', 'mkdir:js', 'browserify'])

  grunt.registerTask('test', ['build', 'run:tests'])

  grunt.registerTask('release', ['build', 'run:tests', 'copy:prod', 'uglify', 'run:crx'])

  grunt.registerTask('default', 'release')

  grunt.registerTask('test-cont', ['test', 'watch'])
