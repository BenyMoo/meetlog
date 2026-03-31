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
subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    fun Project.applyNamespaceFallback() {
        val androidExtension = extensions.findByName("android") ?: return

        val namespace = runCatching {
            androidExtension.javaClass.getMethod("getNamespace").invoke(androidExtension) as? String
        }.getOrNull()

        if (!namespace.isNullOrBlank()) {
            return
        }

        val manifestFile = project.file("src/main/AndroidManifest.xml")
        if (!manifestFile.exists()) {
            return
        }

        val manifestPackage = Regex("""package\s*=\s*"([^"]+)"""")
            .find(manifestFile.readText())
            ?.groupValues
            ?.getOrNull(1)

        if (!manifestPackage.isNullOrBlank()) {
            runCatching {
                androidExtension.javaClass
                    .getMethod("setNamespace", String::class.java)
                    .invoke(androidExtension, manifestPackage)
            }
        }
    }

    pluginManager.withPlugin("com.android.application") {
        applyNamespaceFallback()
    }

    pluginManager.withPlugin("com.android.library") {
        applyNamespaceFallback()
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
