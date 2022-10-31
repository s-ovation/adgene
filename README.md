# Adgene Flutter Plugin

This is a Adgeneration plugin for Flutter.

## Usage in the app

Use the `FiveAd` widget to show a banner. For the production app, specify `false` for the isTest property.

```
AdgeneAd(slotId: "48547", width: 320, height: 50, isTest: true);
```

## Troubleshooting in Android 

Add the following repository by opening the `android/build.gradle`

```
allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url 'https://adgeneration.github.io/ADG-Android-SDK/repository' } # Add this!
    }
}
```