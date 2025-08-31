allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Global JVM toolchain configuration
tasks.withType<JavaCompile> {
    sourceCompatibility = JavaVersion.VERSION_21.toString()
    targetCompatibility = JavaVersion.VERSION_21.toString()
}

tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile> {
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_21.toString()
    }
}

// Configure Java version for all subprojects
subprojects {
    afterEvaluate {
        if (project.hasProperty("android")) {
            extensions.configure<com.android.build.gradle.BaseExtension>("android") {
                compileOptions {
                    sourceCompatibility = JavaVersion.VERSION_21
                    targetCompatibility = JavaVersion.VERSION_21
                }
            }
        }
        
        // Configure Kotlin JVM target for all subprojects
        if (project.hasProperty("kotlin")) {
            project.tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile> {
                kotlinOptions {
                    jvmTarget = JavaVersion.VERSION_21.toString()
                }
            }
        }
        
        // Configure Java toolchain for all subprojects
        if (project.hasProperty("java")) {
            project.tasks.withType<JavaCompile> {
                sourceCompatibility = JavaVersion.VERSION_21.toString()
                targetCompatibility = JavaVersion.VERSION_21.toString()
            }
        }
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

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
