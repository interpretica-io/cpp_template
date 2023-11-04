pipeline {
  agent {
    dockerfile {
      filename 'Dockerfile_ubuntu_2204'
      dir 'tools/build-env'
    }
  }

  environment {
    FULL_VERSION = sh(script: "./tools/get_version.sh full", returnStdout: true).trim()
  }

  stages {
    stage('Download prerequisites') {
      steps {
        dir('ttg') {
          git url: 'https://github.com/interpretica-io/ttg.git',
              branch: 'main'
        }
      }
    }
    stage('Build for all platforms') {
      parallel {
        stage('Build (Linux)') {
          steps {
            sh './tools/run_make.sh'
          }
        }
        stage('Build (Win32)') {
          steps {
            sh './tools/run_make.sh --win32'
          }
        }
        stage('Build (Mac/X86_64)') {
          steps {
            sh './tools/run_make.sh --mac'
          }
        }
        stage('Build (Mac/ARM64)') {
          steps {
            sh './tools/run_make.sh --mac-arm64'
          }
        }
      }
    }

    stage('Unit testing') {
      stages {
        stage('Unit testing (Linux)') {
          steps {
            sh './build/fs/bin/cpp_template_test --gtest_output=xml:./build/unittest-linux.xml || return 0'
          }
        }
        stage('Unit testing (Win32)') {
          steps {
            sh 'mkdir -p .wineprefix && export WINEPREFIX=$(pwd)/.wineprefix && winecfg && wine ./build-win32/fs/bin/cpp_template_test.exe --gtest_output=xml:./build/unittest-win32.xml || return 0'
          }
        }
      }
    }

    stage('Prepare bundle') {
      stages {
        stage('Generate documentation') {
          steps {
            sh './tools/generate_doc.sh'
          }
        }
        stage('Prepare artifacts (branch)') {
          steps {
            /* Create branch-build-linux and doc-branch-build */
            sh './tools/release.sh --out build/cpp_template-${BRANCH_NAME}-${BUILD_NUMBER}-linux-x86_64.tar.xz --doc build/cpp_template-doc-${BRANCH_NAME}-${BUILD_NUMBER}.tar.xz'
            /* Copy branch-build-linux to branch-latest-linux */
            sh 'cp build/cpp_template-${BRANCH_NAME}-${BUILD_NUMBER}-linux-x86_64.tar.xz build/cpp_template-${BRANCH_NAME}-latest-linux-x86_64.tar.xz'
            /* Copy doc-branch-build to doc-branch-latest */
            sh 'cp build/cpp_template-doc-${BRANCH_NAME}-${BUILD_NUMBER}.tar.xz build/cpp_template-doc-${BRANCH_NAME}-latest.tar.xz'

            /* Create branch-build-win32  */
            sh './tools/release.sh --win32 --out build/cpp_template-${BRANCH_NAME}-${BUILD_NUMBER}-win32-x86_64.tar.xz'
            /* Copy branch-build-win32 to doc-branch-latest-win32 */
            sh 'cp build/cpp_template-${BRANCH_NAME}-${BUILD_NUMBER}-win32-x86_64.tar.xz build/cpp_template-${BRANCH_NAME}-latest-win32-x86_64.tar.xz'

            /* Create branch-build-win32  */
            sh './tools/release.sh --mac-x86_64 --out build/cpp_template-${BRANCH_NAME}-${BUILD_NUMBER}-macos-x86_64.tar.xz'
            /* Copy branch-build-macos to doc-branch-latest-macos */
            sh 'cp build/cpp_template-${BRANCH_NAME}-${BUILD_NUMBER}-macos-x86_64.tar.xz build/cpp_template-${BRANCH_NAME}-latest-macos-x86_64.tar.xz'

            /* Create branch-build-arm64  */
            sh './tools/release.sh --mac-arm64 --out build/cpp_template-${BRANCH_NAME}-${BUILD_NUMBER}-macos-arm64.tar.xz'
            /* Copy branch-build-macos to doc-branch-latest-macos */
            sh 'cp build/cpp_template-${BRANCH_NAME}-${BUILD_NUMBER}-macos-arm64.tar.xz build/cpp_template-${BRANCH_NAME}-latest-macos-arm64.tar.xz'
          }
        }
        stage('Prepare artifacts (versioned)') {
          when {
            expression {
              BRANCH_NAME == 'main'
            }
          }
          steps {
          /* Create versioned artifacts */
            sh 'mkdir -p build/versioned_artifacts'

            /* Copy branch-latest-linux to fullver-linux */
            sh 'cp build/cpp_template-${BRANCH_NAME}-latest-linux-x86_64.tar.xz build/versioned_artifacts/cpp_template-${FULL_VERSION}-linux-x86_64.tar.xz'

            /* Copy branch-latest-win32 to fullver-win32 */
            sh 'cp build/cpp_template-${BRANCH_NAME}-latest-win32-x86_64.tar.xz build/versioned_artifacts/cpp_template-${FULL_VERSION}-win32-x86_64.tar.xz'

            /* Copy branch-latest-macos (x86_64) to fullver-macos */
            sh 'cp build/cpp_template-${BRANCH_NAME}-latest-macos-x86_64.tar.xz build/versioned_artifacts/cpp_template-${FULL_VERSION}-macos-x86_64.tar.xz'

            /* Copy branch-latest-macos (arm64) to fullver-macos */
            sh 'cp build/cpp_template-${BRANCH_NAME}-latest-macos-arm64.tar.xz build/versioned_artifacts/cpp_template-${FULL_VERSION}-macos-arm64.tar.xz'

            /* Copy doc-branch-build to doc-fullver */
            sh 'cp build/cpp_template-doc-${BRANCH_NAME}-${BUILD_NUMBER}.tar.xz build/versioned_artifacts/cpp_template-doc-${FULL_VERSION}.tar.xz'
          }
        }
      }
    }
    stage('Publish artifacts') {
      parallel {
        stage('Publish artifacts (branch)') {
          steps {
            ftpPublisher alwaysPublishFromMaster: true,
                         continueOnError: false,
                         failOnError: false,
                         masterNodeName: '',
                         paramPublish: null,
                         publishers: [
                          [
                            configName: 'Cpp Template releases',
                            transfers:
                              [[
                                asciiMode: false,
                                cleanRemote: false,
                                excludes: '',
                                flatten: false,
                                makeEmptyDirs: false,
                                noDefaultExcludes: false,
                                patternSeparator: '[, ]+',
                                remoteDirectory: 'branches/${BRANCH_NAME}-${BUILD_NUMBER}',
                                remoteDirectorySDF: false,
                                removePrefix: 'build',
                                sourceFiles: 'build/cpp_template-*${BRANCH_NAME}-${BUILD_NUMBER}*.tar.xz'
                              ]],
                            usePromotionTimestamp: false,
                            useWorkspaceInPromotion: false,
                            verbose: true
                          ]
                        ]
            ftpPublisher alwaysPublishFromMaster: true,
                         continueOnError: false,
                         failOnError: false,
                         masterNodeName: '',
                         paramPublish: null,
                         publishers: [
                          [
                            configName: 'Cpp Template releases',
                            transfers:
                              [[
                                asciiMode: false,
                                cleanRemote: false,
                                excludes: '',
                                flatten: false,
                                makeEmptyDirs: false,
                                noDefaultExcludes: false,
                                patternSeparator: '[, ]+',
                                remoteDirectory: 'branches/${BRANCH_NAME}',
                                remoteDirectorySDF: false,
                                removePrefix: 'build',
                                sourceFiles: 'build/cpp_template-*${BRANCH_NAME}-latest*.tar.xz'
                              ]],
                            usePromotionTimestamp: false,
                            useWorkspaceInPromotion: false,
                            verbose: true
                          ]
                        ]
          }
        }
        stage('Publish artifacts (versioned)') {
          when {
            expression {
              BRANCH_NAME == 'main'
            }
          }
          steps {
            ftpPublisher alwaysPublishFromMaster: true,
                         continueOnError: false,
                         failOnError: false,
                         masterNodeName: '',
                         paramPublish: null,
                         publishers: [
                          [
                            configName: 'Cpp Template releases',
                            transfers:
                              [[
                                asciiMode: false,
                                cleanRemote: false,
                                excludes: '',
                                flatten: false,
                                makeEmptyDirs: false,
                                noDefaultExcludes: false,
                                patternSeparator: '[, ]+',
                                remoteDirectory: "${FULL_VERSION}",
                                remoteDirectorySDF: false,
                                removePrefix: 'build/versioned_artifacts',
                                sourceFiles: 'build/versioned_artifacts/cpp_template-*.tar.xz'
                              ]],
                            usePromotionTimestamp: false,
                            useWorkspaceInPromotion: false,
                            verbose: true
                          ]
                        ]
          }
        }
        stage('Archive artifacts for Jenkins') {
          steps {
            archiveArtifacts artifacts: 'build/cpp_template-*.tar.xz'
          }
        }
      }
    }
  }
  post {
    always {
      junit 'build/unittest*.xml'
    }
    success {
      sh './ttg/ttg_send_notification --env --ignore-bad -- "${JOB_NAME}/${BUILD_NUMBER}: PASSED"'
    }
    failure {
      sh './ttg/ttg_send_notification --env --ignore-bad -- "${JOB_NAME}/${BUILD_NUMBER}: FAILED. See details in ${BUILD_URL}"'
    }
  }
}
