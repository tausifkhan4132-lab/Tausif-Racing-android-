TAUSIF RACING — Godot 3D Android starter project

WHAT THIS IS
A small playable 3D track-racing prototype made with Godot 4. It has a 3D track,
a custom dark sports car, chase camera, speed display, touch buttons, steering,
accelerator, brake and nitro. It is a starter prototype, not a finished ultra-realistic
commercial racing game.

HOW TO OPEN
1. Install Godot 4.3 or newer on a computer.
2. Unzip this folder.
3. In Godot Project Manager choose Import, then select project.godot.
4. Open the project and press F6/F5 to run. Keyboard: arrows; mobile: on-screen buttons.

HOW TO EXPORT AN ANDROID APK
1. In Godot Editor open Editor > Manage Export Templates and install matching templates.
2. Install Android Studio and the Android SDK / build tools / platform tools / JDK version
   recommended in the Godot Android export documentation.
3. In Editor > Editor Settings > Export > Android, set the SDK, JDK and debug keystore paths.
4. Project > Export > Add... > Android. Set package name to com.tausif.racing.
5. For a personal test build, export a debug APK and install it on your Android phone.
6. For sharing/publishing, create your own release keystore and configure release signing.
   Never share your keystore or passwords.

IMPORTANT
This ZIP contains project source, not a compiled or signed APK. APK generation requires
Godot export templates and Android build tools on a computer. Do not install APK files
from unknown sources. Use your own release signing credentials.
