module.exports = function(grunt) {

  // Project configuration.
  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    clean: ["dist"],
    compress: {
      dist: {
        options: {
          mode: "tgz",
          archive: 'dist/ami-scripts.tar.gz'
        },
        files: [{
            expand: true,
            src: ['**/*'],
            cwd: "src",
            dest: '',
          }
        ]
      }
    },
  });

  grunt.loadNpmTasks('grunt-haven');
  grunt.loadNpmTasks('grunt-contrib-clean');
  grunt.loadNpmTasks('grunt-contrib-compress');

  // Tasks

  grunt.registerTask('dist', ['clean', 'compress']);
  grunt.registerTask('deploy', ['dist', 'haven:deploy']);
  grunt.registerTask('ci', ['dist', 'haven:deployOnly']);

  // Default task(s).
  grunt.registerTask('default', ['deploy']);

};