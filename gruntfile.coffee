module.exports = (grunt) ->

    # Configurable paths.
    yeomanConfig =
        app: 'app'
        dist: 'dist'
        test: 'test'



    # Show elapsed time at the end.
    if grunt.option 'timing'
        (require 'time-grunt') grunt

    # Load all grunt tasks.
    (require 'load-grunt-tasks') grunt

    grunt.initConfig

        yeoman: yeomanConfig

        watch:
            options:
                spawn: false
            coffeelint:
                files: [
                    '*.coffee'
                    '<%= yeoman.test %>/*.coffee'
                    '<%= yeoman.app %>/scripts/*.coffee'
                ]
                tasks: [
                    'coffee'
                    'coffeelint'
                    'karma:watch:run'
                ]
            jsonlint:
                files: [
                    '*.json'
                    '.*rc'
                    '<%= yeoman.app %>/*.json'
                    '<%= yeoman.test %>/fixtures/*.json'
                ]
                tasks: [
                    'jsonlint'
                    'karma:watch:run'
                ]
            csslint:
                files: ['<%= yeoman.app %>/styles/*.css']
                tasks: ['csslint']

        clean:
            dist:
                files: [
                    dot: true
                    src: [
                        '<%= yeoman.dist %>/*'
                        '!<%= yeoman.dist %>/.git*'
                    ]
                ]
            compress: ['zip/TabAhead.zip']
            coffee:
                src: ['<%= yeoman.app %>/scripts/*{.js,.js.map}']

        coffeelint:
            # `grunt-coffeelint` does not support this natively
            # [yet](https://github.com/vojtajina/grunt-coffeelint/pull/23).
            options: grunt.file.readJSON('.coffeelintrc')
            all: [
                '*.coffee',
                '<%= yeoman.test %>/*.coffee'
                '<%= yeoman.app %>/scripts/*.coffee'
            ]

        jsonlint:
            all: [
                '*.json'
                '.bower_rc'
                '.coffeelintrc'
                '<%= yeoman.app %>/*.json'
                '<%= yeoman.test %>/fixtures/*.json'
            ]

        csslint:
            options:
                csslintrc: '.csslintrc'
            all: ['<%= yeoman.app %>/styles/*.css']

        coffee:
            options:
                sourceMap: true
            compile:
                expand: true
                flatten: true
                cwd: '<%= yeoman.app %>/scripts'
                src: ['*.coffee']
                dest: '<%= yeoman.app %>/scripts'
                ext: '.js'

        karma:
            options:
                configFile: 'karma.conf.coffee'
            e2e: {}
            watch:
                browsers: ['Chrome', 'PhantomJS']
                autoWatch: false
                background: true
                singleRun: false

        gitclone:
            cssRatiocinator:
                options:
                    branch: 'master'
                    repository: 'https://github.com/begriffs/css-ratiocinator.git'
                    directory: 'util/css-ratiocinator'

        shell:
            options:
                stdout: true
                stderr: true
                failOnError: true
                execOptions:
                    cwd: 'util/css-ratiocinator'
            trashcss:
                command: [
                    'node'
                    '../../node_modules/phantomjs/bin/phantomjs'
                    'ratiocinate.js'
                    '../../app/options.html'
                    '>'
                    '../../dist/styles/options.css'
                ].join ' '


        useminPrepare:
            options:
                dest: '<%= yeoman.dist %>'
            html: [
                '<%= yeoman.app %>/popup.html'
                '<%= yeoman.app %>/options.html'
            ]

        usemin:
            options:
                dirs: ['<%= yeoman.dist %>']
            html: ['<%= yeoman.dist %>/{,*/}*.html']
            css: ['<%= yeoman.dist %>/styles/{,*/}*.css']

        imagemin:
            dist:
                files: [
                    expand: true
                    cwd: '<%= yeoman.app %>/images'
                    src: '{,*/}*.{png,jpg,jpeg}'
                    dest: '<%= yeoman.dist %>/images'
                ]

        htmlmin:
            dist:
                options:
                    # https://github.com/yeoman/grunt-usemin/issues/44
                    # collapseWhitespace: true
                    collapseBooleanAttributes: true
                    useShortDoctype: true
                    removeEmptyAttributes: true
                files: [
                    expand: true
                    cwd: '<%= yeoman.app %>'
                    src: '*.html'
                    dest: '<%= yeoman.dist %>'
                ]

        # Put files not handled in other tasks here
        copy:
            dist:
                files:
                    '<%= yeoman.dist %>/LICENSE': [
                        'LICENSE'
                    ]
                    '<%= yeoman.dist %>/manifest.json': [
                        '<%= yeoman.app %>/manifest.json'
                    ]

        concurrent:
            test: [
                'coffeelint'
                'jsonlint'
                'csslint'
                'karma:e2e'
            ]
            dist: [
                'imagemin'
                'htmlmin'
            ]

        compress:
            dist:
                options:
                    archive: 'zip/TabAhead.zip'
                files: [
                    expand: true
                    cwd: 'dist/'
                    src: ['**']
                    dest: ''
                ]

        updateVersion:
            all: [
                '<%= yeoman.app %>/manifest.json'
                'package.json'
                'bower.json'
            ]

    grunt.registerMultiTask 'updateVersion',
        'Update the version key of .json files.', ->

            versionnumber = grunt.option 'versionnumber'
            error = 'Use --versionnumber flag to specify the new version number.'

            grunt.log.error(error) unless versionnumber?

            @filesSrc.forEach (filepath) ->
                manifest = grunt.file.readJSON filepath
                manifest.version = versionnumber
                grunt.file.write filepath, JSON.stringify manifest, null, 2

    grunt.registerTask 'test', [
        'concurrent:test'
    ]

    grunt.registerTask 'build', [
        'test'
        'coffee'
        'clean:dist'
        'useminPrepare'
        'concurrent:dist'
        'concat'
        'cssmin'
        'uglify'
        'copy'
        'usemin'
        'clean:compress'
        'compress'
    ]

    grunt.registerTask 'default', [
        'build'
        'karma:watch'
        'watch'
    ]
