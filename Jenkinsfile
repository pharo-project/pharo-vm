properties([disableConcurrentBuilds()])
def platforms = ['unix', 'osx', 'windows']
def builders = [:]

	for (platf in platforms) {
    // Need to bind the label variable before the closure - can't do 'for (label in labels)'
    def platform = platf
		
		builders[platform] = {
      def vmplatform = platform
			node(platform){
				timeout(30){
          stage("Checkout-${vmplatform}"){
            cleanWs()
            dir('repository') {
              checkout scm
              sh "./scripts/updateSCCSVersions || true"
            }
          }
          if(vmplatform == 'osx'){
            vmplatform = 'macos'
          }else if(vmplatform == 'unix'){
            vmplatform = 'linux'
          }else{
            vmplatform = 'win'
          }
          stage("Build-${vmplatform}"){
            def build_directory = "repository/build.${vmplatform}64x64/pharo.cog.spur"
            if(vmplatform == 'linux'){
              build_directory = "${build_directory}/build"
            }
            dir(build_directory) {
              if(vmplatform == 'linux'){
                sh "echo n | bash -e ./mvm"
              } else {
                sh "bash -e ./mvm -f"
              }
              archiveArtifacts artifacts: "./vm"
            }
          }
        }
      }
    }
	}
  parallel builders