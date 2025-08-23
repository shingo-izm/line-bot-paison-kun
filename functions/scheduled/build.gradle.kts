plugins {
    kotlin("jvm") version "2.1.0"
    id("com.github.johnrengelman.shadow") version "8.1.1"
}

repositories {
    mavenCentral()
}

dependencies {
    implementation("com.amazonaws:aws-lambda-java-core:1.3.0")
    implementation("com.linecorp.bot:line-bot-messaging-api-client:9.9.1")
    implementation("com.google.api-client:google-api-client:2.8.0")
    implementation("com.google.apis:google-api-services-sheets:v4-rev614-1.18.0-rc")
    implementation("com.google.api-client:google-api-client-jackson2:2.8.0")
}

tasks.shadowJar {
    archiveBaseName.set("monthly-schedule-task")
    archiveClassifier.set("all")
}
