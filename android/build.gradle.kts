buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:9.0.1")
    }
}

import com.android.build.api.dsl.LibraryExtension

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// 1. Register the afterEvaluate configuration block BEFORE evaluationDependsOn.
// This ensures hooks are registered on all subprojects before evaluation starts.
subprojects {
    val subproject = this
    subproject.afterEvaluate {
        subproject.plugins.withId("com.android.library") {
            subproject.extensions.configure<LibraryExtension>("android") {
                compileSdk = 34
            }
        }
    }
}

// 2. evaluationDependsOn is defined AFTER the afterEvaluate configurations.
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
