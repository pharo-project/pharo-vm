properties([disableConcurrentBuilds()])
def platforms = ['unix', 'osx', 'windows']
	def builders = [:]
	def tests = [:]

	for (platf in platforms) {
        // Need to bind the label variable before the closure - can't do 'for (label in labels)'
        def platform = platf
		
		builders[platform] = {
      def vmplatform = platform
			node(platform){
				timeout(30){
          cleanWs()
          dir('repository') {
            checkout scm
          }
          if(vmplatform == 'osx'){
            vmplatform = 'macos'
          }else if(vmplatform == 'unix'){
            vmplatform = 'linux'
          }else{
            vmDir = 'win'
          }
          dir('build.${vmplatform}64x64/pharo.cog.spur') {
            if(vmplatform == 'linux'){
              shell "./mvm"
            } else {
              shell "./mvm -f"
            }
            archiveArtifacts artifacts: "./vm"
          }
				}
			}
		}		
	}