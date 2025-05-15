allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Configuration du dossier de build Flutter
val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    project.evaluationDependsOn(":app")
}

// Task pour nettoyer le projet
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
}