def isWindows(){
  //If NODE_LABELS environment variable is null, we assume we are on master unix machine
  if (env.NODE_LABELS == null) {
    return false
  }
    return env.NODE_LABELS.toLowerCase().contains('windows')
}

def is32Bits(platform){
	return platform == 'Linux-armv7l'
}

def shell(params){
    if(isWindows()) bat(params) 
    else sh(params)
}

def isMainBranch(){
	return env.BRANCH_NAME.startsWith('pharo-')
}

def saveIsReleaseFlag(){
	def gitTags = sh(returnStdout: true, script: 'git tag --list --points-at HEAD').trim()
	def pattern = ~/^v[0-9]+\.[0-9]+.[0-9]+(\-[a-zA-Z0-9_]+)?$/
	def isReleaseFlag = false;

	gitTags.eachLine { line -> isReleaseFlag |= pattern.matcher(line).matches() }
	
	echo("Extracted versionTag: ${gitTags} is release: ${isReleaseFlag}")

	writeFile file: 'releaseFlag.txt', text: (isReleaseFlag?1:0).toString();
	
	stash includes: "releaseFlag.txt", name: "releaseFlag"
}

def isRelease(){
	unstash name: "releaseFlag"
	
	return readFile('releaseFlag.txt').trim() == "1"	
}

/**
  Returns pharo version for the current branch.
  Only valid if isMainBranch() is true.
**/
def mainBranchVersion(){
	return env.BRANCH_NAME.substring('pharo-'.length())
}

def runInCygwin(command){
	def c = """#!c:\\tools\\cygwin\\bin\\bash --login
    cd `cygpath \"$WORKSPACE\"`
    set -ex
    ${command}
    """
    
    echo("Executing: ${c}")
    withEnv(["PHARO_CI_TESTING_ENVIRONMENT=true"]) {    
      return sh(c)
    }
}

def buildGTKBundle(){
	node("unix"){
		cleanWs()
		stage("build-GTK-bundle"){

			def commitHash = checkout(scm).GIT_COMMIT

			unstash name: "packages-Windows-x86_64-CoInterpreter"
			def shortGitHash = commitHash.substring(0,8)
			def gtkBundleName = "PharoVM-8.1.0-GTK-${shortGitHash}-win64-bin.zip"

			dir("build"){
				shell "wget http://files.pharo.org/vm/pharo-spur64/win/third-party/Gtk3.zip"
				shell "unzip Gtk3.zip -d ./bundleGTK"
				shell "unzip -n build/packages/PharoVM-*-Windows-x86_64-bin.zip -d ./bundleGTK"

				dir("bundleGTK"){
					shell "zip -r -9 ../${gtkBundleName} *"
				}
			
				stash includes: "${gtkBundleName}", name: "packages-Windows-x86_64-gtkBundle"
				archiveArtifacts artifacts: "${gtkBundleName}"
				
				if(!isPullRequest() && isMainBranch()){
					sshagent (credentials: ['b5248b59-a193-4457-8459-e28e9eb29ed7']) {
						sh "scp -o StrictHostKeyChecking=no \
						${gtkBundleName} \
						pharoorgde@ssh.cluster023.hosting.ovh.net:/home/pharoorgde/files/vm/pharo-spur64-headless/win/${gtkBundleName}"

						sh "scp -o StrictHostKeyChecking=no \
						${gtkBundleName} \
						pharoorgde@ssh.cluster023.hosting.ovh.net:/home/pharoorgde/files/vm/pharo-spur64-headless/win/latest${mainBranchVersion()}-win64-GTK.zip"
					}
				}
			}
		}
	}
}
def recordCygwinVersions(buildDirectory){
    runInCygwin "cd ${buildDirectory} &&  cygcheck -c -d > cygwinVersions.txt"
	archiveArtifacts artifacts: "${buildDirectory}/cygwinVersions.txt"
}

def runBuild(platformName, configuration, headless = true, someAdditionalParameters = ""){
	cleanWs()
	
	def platform = headless ? platformName : "${platformName}-stockReplacement"
	def buildDirectory = headless ? "build" :"build-stockReplacement"
	def additionalParameters = someAdditionalParameters
	
	additionalParameters += headless ? "" : " -DALWAYS_INTERACTIVE=1 "
	additionalParameters += isRelease() ? " -DBUILD_IS_RELEASE=ON " : " -DBUILD_IS_RELEASE=OFF "

	if(configuration == 'StackVM'){
		additionalParameters += " -DFEATURE_MESSAGE_COUNT=TRUE "
		platform = "${platformName}-StackVM"
		buildDirectory = "build-StackVM"
	}

	stage("Checkout-${platform}"){
		dir('repository') {
			checkout scm
		}
	}
  
	stage("Build-${platform}-${configuration}"){
    if(isWindows()){
      runInCygwin "mkdir ${buildDirectory}"
      recordCygwinVersions(buildDirectory)
      runInCygwin "cd ${buildDirectory} && cmake -DFLAVOUR=${configuration} ${additionalParameters} -DPHARO_DEPENDENCIES_PREFER_DOWNLOAD_BINARIES=TRUE ../repository -DICEBERG_DEFAULT_REMOTE=httpsUrl"
      runInCygwin "cd ${buildDirectory} && VERBOSE=1 make install package"
      runInCygwin "mkdir -p artifacts-${platformName} && cp -a ${buildDirectory}/build/packages/* artifacts-${platformName}/"
    }else{
      cmakeBuild generator: "Unix Makefiles", cmakeArgs: "-DFLAVOUR=${configuration} ${additionalParameters} -DPHARO_DEPENDENCIES_PREFER_DOWNLOAD_BINARIES=TRUE -DICEBERG_DEFAULT_REMOTE=httpsUrl", sourceDir: "repository", buildDir: "${buildDirectory}", installation: "InSearchPath"
      dir("${buildDirectory}"){
        shell "VERBOSE=1 make install package"
      }
      shell "mkdir -p artifacts-${platformName} && cp -a ${buildDirectory}/build/packages/* artifacts-${platformName}/"
    }
	
		stash excludes: '_CPack_Packages', includes: "${buildDirectory}/build/packages/*", name: "packages-${platform}-${configuration}"
        stash includes: "repository/scripts/*", name: "scripts"
		archiveArtifacts artifacts: "${buildDirectory}/build/packages/*", excludes: '_CPack_Packages'
		archiveArtifacts artifacts: "artifacts-${platformName}/*", excludes: '_CPack_Packages'

	}
}

def runBuildFromSources(platformName, configuration, headless = true){
	cleanWs()
	
	def platform = headless ? platformName : "${platformName}-stockReplacement"
	def buildDirectory = headless ? "build" :"build-stockReplacement"
	def additionalParameters = headless ? "" : "-DALWAYS_INTERACTIVE=1"

	stage("Copy Sources-${platform}"){
		//We take the source code from Linux version
		//It is extracted and will create the pharo-vm subdirectory
		unstash name: "packages-Linux-x86_64-${configuration}"
		shell "unzip -d . build/build/packages/PharoVM-*-Linux-x86_64-c-src.zip"
		shell "mv pharo-vm repository"
	}

	stage("Build-${platform}-${configuration}"){
		cmakeBuild generator: "Unix Makefiles", cmakeArgs: "-DFLAVOUR=${configuration} ${additionalParameters} -DPHARO_DEPENDENCIES_PREFER_DOWNLOAD_BINARIES=TRUE -DICEBERG_DEFAULT_REMOTE=httpsUrl -DGENERATE_SOURCES=FALSE -DGENERATED_SOURCE_DIR=../repository/", sourceDir: "repository", buildDir: "${buildDirectory}", installation: "InLocalPath"
		
		dir("${buildDirectory}"){
			shell "VERBOSE=1 make install package"
		}
		
		stash excludes: '_CPack_Packages', includes: "${buildDirectory}/build/packages/*", name: "packages-${platform}-${configuration}"
		archiveArtifacts artifacts: "${buildDirectory}/build/packages/*", excludes: '_CPack_Packages'
	}
}

def runUnitTests(platform){
  cleanWs()

  stage("VM Unit Tests"){
    dir('repository') {
      checkout scm
		//We stash the docker files so we can create docker images without checkout
		stash includes: "docker/**", name: "dockerfiles"
		
		//We register if the build is a stable release, we get the metadata from the repository and we stash it
		saveIsReleaseFlag()
    }

    cmakeBuild generator: "Unix Makefiles", sourceDir: "repository", buildDir: "runTests", installation: "InSearchPath", cmakeArgs: "-DPHARO_DEPENDENCIES_PREFER_DOWNLOAD_BINARIES=TRUE -DICEBERG_DEFAULT_REMOTE=httpsUrl"
    dir("runTests"){
      shell "VERBOSE=1 make vmmaker"
      dir("build/vmmaker"){
        shell "wget https://files.pharo.org/vm/pharo-spur64/Darwin-x86_64/third-party/libllvm-full.zip"
        shell "unzip libllvm-full.zip -d ./vm/Contents/MacOS/Plugins"
        shell "wget https://files.pharo.org/vm/pharo-spur64/Darwin-x86_64/third-party/libunicorn.2.zip"
        shell "unzip libunicorn.2.zip  -d ./vm/Contents/MacOS/Plugins"

        timeout(20){
          shell "PHARO_CI_TESTING_ENVIRONMENT=true  ./vm/Contents/MacOS/Pharo --headless --logLevel=4 ./image/VMMaker.image test --junit-xml-output 'VMMakerTests'"
          shell "PHARO_CI_TESTING_ENVIRONMENT=true  ./vm/Contents/MacOS/Pharo --headless --logLevel=4 ./image/VMMaker.image test --junit-xml-output 'Slang-Tests'"
         } 

        shell "zip ./VMMaker-Image.zip ./image/VMMaker.*"
        archiveArtifacts artifacts: 'VMMaker-Image.zip'

        // Stop if tests fail
        // Archive xml reports either case
        try {
          junit allowEmptyResults: true, testResults: "*.xml"
        } catch (ex) {
          if (currentBuild.result == 'UNSTABLE'){
            currentBuild.result = 'FAILURE'
          }
          archiveArtifacts artifacts: '*.xml'
        }
        
      }
    }
  }
}

def runTests(platform, configuration, packages, withWorker, additionalParameters = ""){
  cleanWs()

  def stageName = withWorker ? "Tests-${platform}-${configuration}-worker" : "Tests-${platform}-${configuration}"
  def hasWorker = withWorker ? "--worker" : ""

	stage(stageName){
		unstash name: "scripts"
        unstash name: "packages-${platform}-${configuration}"
		shell "mkdir runTests"
		dir("runTests"){
			try{
				shell "wget -O - get.pharo.org/64/110 | bash "
				shell "echo 110 > pharo.version"
          
				if(isWindows()){
					runInCygwin "cd runTests && unzip ../build/build/packages/PharoVM-*-${platform}-bin.zip -d ."
					// Disable testAfterSequence that creates incorrect bytecode sequences
                    runInCygwin "PHARO_CI_TESTING_ENVIRONMENT=true cd runTests && ./PharoConsole.exe  --logLevel=4 ${hasWorker} Pharo.image ${additionalParameters} ../repository/scripts/patchPharoPreTests.st"
                    runInCygwin "PHARO_CI_TESTING_ENVIRONMENT=true cd runTests && ./PharoConsole.exe  --logLevel=4 ${hasWorker} Pharo.image ${additionalParameters} test --junit-xml-output --stage-name=${stageName} '${packages}'"
					} else {
						shell "unzip ../build/build/packages/PharoVM-*-${platform}-bin.zip -d ."

						if(platform == 'Darwin-x86_64' || platform == 'Darwin-arm64'){
        					// Disable testAfterSequence that creates incorrect bytecode sequences
                            shell "PHARO_CI_TESTING_ENVIRONMENT=true ./Pharo.app/Contents/MacOS/Pharo --logLevel=4 ${hasWorker} Pharo.image ${additionalParameters} ../repository/scripts/patchPharoPreTests.st"
							shell "PHARO_CI_TESTING_ENVIRONMENT=true ./Pharo.app/Contents/MacOS/Pharo --logLevel=4 ${hasWorker} Pharo.image ${additionalParameters} test --junit-xml-output --stage-name=${stageName} '${packages}'"
						}

						if(platform == 'Linux-x86_64' || platform == 'Linux-aarch64' || platform == 'Linux-armv7l'){
        					// Disable testAfterSequence that creates incorrect bytecode sequences
                            shell "PHARO_CI_TESTING_ENVIRONMENT=true ./pharo --logLevel=4 ${hasWorker} Pharo.image ${additionalParameters} ../repository/scripts/patchPharoPreTests.st"
							shell "PHARO_CI_TESTING_ENVIRONMENT=true ./pharo --logLevel=4 ${hasWorker} Pharo.image ${additionalParameters} test --junit-xml-output --stage-name=${stageName} '${packages}'" 
						}
				}
                
                // If the tests fail, continue and just mark this as a failure
                try {
                  junit allowEmptyResults: true, testResults: "*.xml"
                } catch (ex) {
                  if (currentBuild.result == 'UNSTABLE'){
                    currentBuild.result = 'FAILURE'
                  }
                  archiveArtifacts artifacts: '*.xml', excludes: '_CPack_Packages'
                }
			} finally{
				if(fileExists('PharoDebug.log')){
					shell "mv PharoDebug.log PharoDebug-${stageName}.log"
					 archiveArtifacts allowEmptyArchive: true, artifacts: "PharoDebug-${stageName}.log", fingerprint: true
				}
				if(fileExists('crash.dmp')){
					shell "mv crash.dmp crash-${stageName}.dmp"
					archiveArtifacts allowEmptyArchive: true, artifacts: "crash-${stageName}.dmp", fingerprint: true
				}
				if(fileExists('progress.log')){
					shell "mv progress.log progress-${stageName}.log"
					shell "cat progress-${stageName}.log"
					archiveArtifacts allowEmptyArchive: true, artifacts: "progress-${stageName}.log", fingerprint: true
				}
			}
		}
	}
}

def upload(platform, configuration, archiveName, isStableRelease = false) {

	cleanWs()

	unstash name: "packages-${platform}-${configuration}"

	def wordSize = is32Bits(platform) ? "32" : "64"
	def expandedBinaryFileName = sh(returnStdout: true, script: "ls build/build/packages/PharoVM-*-${archiveName}-bin.zip").trim()
	def expandedCSourceFileName = sh(returnStdout: true, script: "ls build/build/packages/PharoVM-*-${archiveName}-c-src.zip").trim()
	def expandedCSourceTarName = sh(returnStdout: true, script: "ls build/build/packages/PharoVM-*-${archiveName}-c-src.tar.gz").trim()
	def expandedHeadersFileName = sh(returnStdout: true, script: "ls build/build/packages/PharoVM-*-${archiveName}-include.zip").trim()

	sshagent (credentials: ['b5248b59-a193-4457-8459-e28e9eb29ed7']) {
		sh "scp -o StrictHostKeyChecking=no \
		${expandedBinaryFileName} \
		pharoorgde@ssh.cluster023.hosting.ovh.net:/home/pharoorgde/files/vm/pharo-spur${wordSize}-headless/${platform}"
		sh "scp -o StrictHostKeyChecking=no \
		${expandedBinaryFileName} \
		pharoorgde@ssh.cluster023.hosting.ovh.net:/home/pharoorgde/files/vm/pharo-spur${wordSize}-headless/${platform}/latest${mainBranchVersion()}.zip"

		sh "scp -o StrictHostKeyChecking=no \
		${expandedHeadersFileName} \
		pharoorgde@ssh.cluster023.hosting.ovh.net:/home/pharoorgde/files/vm/pharo-spur${wordSize}-headless/${platform}/include"
		sh "scp -o StrictHostKeyChecking=no \
		${expandedHeadersFileName} \
		pharoorgde@ssh.cluster023.hosting.ovh.net:/home/pharoorgde/files/vm/pharo-spur${wordSize}-headless/${platform}/include/latest${mainBranchVersion()}.zip"

		// Upload Souces ZIP 
		sh "scp -o StrictHostKeyChecking=no \
		${expandedCSourceFileName} \
		pharoorgde@ssh.cluster023.hosting.ovh.net:/home/pharoorgde/files/vm/pharo-spur${wordSize}-headless/${platform}/source"
		sh "scp -o StrictHostKeyChecking=no \
		${expandedCSourceFileName} \
		pharoorgde@ssh.cluster023.hosting.ovh.net:/home/pharoorgde/files/vm/pharo-spur${wordSize}-headless/${platform}/source/latest${mainBranchVersion()}.zip"

		// Upload Sources TAR.GZ
		sh "scp -o StrictHostKeyChecking=no \
		${expandedCSourceTarName} \
		pharoorgde@ssh.cluster023.hosting.ovh.net:/home/pharoorgde/files/vm/pharo-spur${wordSize}-headless/${platform}/source"
		sh "scp -o StrictHostKeyChecking=no \
		${expandedCSourceTarName} \
		pharoorgde@ssh.cluster023.hosting.ovh.net:/home/pharoorgde/files/vm/pharo-spur${wordSize}-headless/${platform}/source/latest${mainBranchVersion()}.tar.gz"
		
		if(isStableRelease){
			sh "scp -o StrictHostKeyChecking=no \
			${expandedBinaryFileName} \
			pharoorgde@ssh.cluster023.hosting.ovh.net:/home/pharoorgde/files/vm/pharo-spur${wordSize}-headless/${platform}/stable${mainBranchVersion()}.zip"
		}
	}
}

def uploadStockReplacement(platform, configuration, archiveName, isStableRelease = false) {

	cleanWs()

	unstash name: "packages-${archiveName}-${configuration}"

	def wordSize = is32Bits(platform) ? "32" : "64"
	def expandedBinaryFileName = sh(returnStdout: true, script: "ls build-stockReplacement/build/packages/PharoVM-*-${archiveName}-bin.zip").trim()

	sshagent (credentials: ['b5248b59-a193-4457-8459-e28e9eb29ed7']) {
		sh "scp -o StrictHostKeyChecking=no \
		${expandedBinaryFileName} \
		pharoorgde@ssh.cluster023.hosting.ovh.net:/home/pharoorgde/files/vm/pharo-spur${wordSize}/${platform}"
		sh "scp -o StrictHostKeyChecking=no \
		${expandedBinaryFileName} \
		pharoorgde@ssh.cluster023.hosting.ovh.net:/home/pharoorgde/files/vm/pharo-spur${wordSize}/${platform}/latestReplacement${mainBranchVersion()}.zip"

		if(isStableRelease){
			sh "scp -o StrictHostKeyChecking=no \
			${expandedBinaryFileName} \
			pharoorgde@ssh.cluster023.hosting.ovh.net:/home/pharoorgde/files/vm/pharo-spur${wordSize}/${platform}/stable${mainBranchVersion()}.zip"
		}
	}
}

def uploadStackVM(platform, configuration, archiveName, isStableRelease = false){

	if(platform == 'Linux-aarch64' || platform == 'Linux-armv7l')
		return;

	cleanWs()

	unstash name: "packages-${archiveName}-StackVM-${configuration}"

	def wordSize = is32Bits(platform) ? "32" : "64"
	def oldName = sh(returnStdout: true, script: "ls build-StackVM/build/packages/PharoVM-*-${archiveName}-bin.zip").trim()
	def expandedBinaryFileName = oldName.replaceAll("-bin.zip", "-StackVM-bin.zip")
	
	sh(script: "cp ${oldName} ${expandedBinaryFileName}")
	
	sshagent (credentials: ['b5248b59-a193-4457-8459-e28e9eb29ed7']) {
		sh "scp -o StrictHostKeyChecking=no \
		${expandedBinaryFileName} \
		pharoorgde@ssh.cluster023.hosting.ovh.net:/home/pharoorgde/files/vm/pharo-spur${wordSize}-headless/${platform}"
		sh "scp -o StrictHostKeyChecking=no \
		${expandedBinaryFileName} \
		pharoorgde@ssh.cluster023.hosting.ovh.net:/home/pharoorgde/files/vm/pharo-spur${wordSize}-headless/${platform}/latestStackVM${mainBranchVersion()}.zip"

		if(isStableRelease){
			sh "scp -o StrictHostKeyChecking=no \
			${expandedBinaryFileName} \
			pharoorgde@ssh.cluster023.hosting.ovh.net:/home/pharoorgde/files/vm/pharo-spur${wordSize}-headless/${platform}/stableStackVM${mainBranchVersion()}.zip"
		}
	}
}

def isPullRequest() {
  return env.CHANGE_ID != null
}

def uploadPackages(platformNames){
	node('unix'){
		stage('Upload'){
			
			def releaseFlag = isRelease();
			echo "Readed releaseFlag: ${releaseFlag}"
			
			if (isPullRequest()) {
				//Only upload files if not in a PR (i.e., CHANGE_ID not empty)
				echo "[DO NO UPLOAD] In PR " + (env.CHANGE_ID?.trim())
				return;
			}

			if(!isMainBranch()){
				echo "[DO NO UPLOAD] The branch is not a main Pharo version branch (starts with 'pharo-'): ${env.BRANCH_NAME}";
				return;
			}

			for (platformName in platformNames) {
				upload(platformName, "CoInterpreter", platformName, releaseFlag)
				uploadStockReplacement(platformName, "CoInterpreter", "${platformName}-stockReplacement",releaseFlag)
				uploadStackVM(platformName, "StackVM", platformName, releaseFlag)
			}
		}
	}
}

def runInsideDocker(platform, imageName, closure){
	node('docker20'){
		cleanWs()
		def image;
		stage("Build Image ${platform}"){
			unstash name: "dockerfiles"
			image = docker.build("pharo-${imageName}","./docker/${imageName}/")
		}
		
		echo "Building using workspace " + env.WORKSPACE
			
		image.inside("-v /tmp:/tmp -e HOME=/opt/pharo -u pharo", closure)
	}
}

def runTestsUsingDocker(platform, imageName, configuration, packages, withWorker){
	
	runInsideDocker(platform, imageName){
		timeout(45){
			runTests(platform, configuration, packages, withWorker, "--no-default-preferences")
		}
	}
}

def buildUsingDocker(platform, imageName, configuration, headless=true){

	runInsideDocker(platform, imageName){
		timeout(45){
			runBuildFromSources(platform, configuration, headless)
		}
	}
}

try{
	properties([disableConcurrentBuilds()])

	def parallelBuilderPlatforms = ['Linux-x86_64', 'Darwin-x86_64', 'Windows-x86_64', 'Darwin-arm64']
	def platforms = parallelBuilderPlatforms + ['Linux-aarch64', 'Linux-armv7l']
	def builders = [:]
	def dockerBuilders = [:]

	node('Darwin-x86_64'){
		runUnitTests('Darwin-x86_64')
	}

	for (platf in parallelBuilderPlatforms) {
		// Need to bind the label variable before the closure - can't do 'for (label in labels)'
		def platform = platf
		
		builders[platform] = {
			node(platform){
				timeout(30){
					runBuild(platform, "CoInterpreter")
				}
				timeout(30){
					runBuild(platform, "StackVM")
				}
				timeout(45){
					runTests(platform, "CoInterpreter", ".*", false)
				}
				timeout(45){
					runTests(platform, "CoInterpreter", ".*", true)
				}
				timeout(30){
					runBuild("${platform}-ComposedFormat", "CoInterpreter", true, " -DIMAGE_FORMAT=ComposedFormat ")
				}
				timeout(30){
					// Only build the Stock replacement version in the main branch
					if(isMainBranch()){
						runBuild(platform, "CoInterpreter", false)
					}
				}
			}
		}		
	}

	dockerBuilders['Linux-aarch64'] = {
		buildUsingDocker('Linux-aarch64', 'ubuntu-arm64', "CoInterpreter")
        runTestsUsingDocker('Linux-aarch64', 'ubuntu-arm64', "CoInterpreter", "Kernel.*|Zinc.*", false)
		if(isMainBranch()){
			buildUsingDocker('Linux-aarch64', 'ubuntu-arm64', "CoInterpreter", false)
		}
	}

	dockerBuilders['Linux-armv7l'] = {
		buildUsingDocker('Linux-armv7l', 'debian10-armv7', "CoInterpreter")	
        runTestsUsingDocker('Linux-armv7l', 'debian10-armv7', "CoInterpreter", "Kernel.*|Zinc.*", false)
		if(isMainBranch()){
			buildUsingDocker('Linux-armv7l', 'debian10-armv7', "CoInterpreter", false)
		}
	}

	parallel builders

	parallel dockerBuilders
		
	uploadPackages(platforms)

	buildGTKBundle()

} catch (e) {
  throw e
}
