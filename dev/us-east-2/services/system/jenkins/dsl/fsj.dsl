freeStyleJob('example') {
    logRotator(-1, 10)
    jdk('Java 8')
    scm {
        git {
            remote {
                url('https://github.com/ArthurMaverick/devops_project.git')
                credentials('git')
                branch('main')
            }
        }
    }
    triggers {
        githubPush()
    }
    steps {
        gradle('clean build')
    }
    publishers {
        archiveArtifacts('job-dsl-plugin/build/libs/job-dsl.hpi')
    }
}