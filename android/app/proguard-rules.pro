# Flutter's Gradle plugin supplies flutter_proguard_rules.pro; Firebase and
# Google Maps ship their own consumer rules. Avoid blanket package keep rules.
# Preserve generic signatures and annotations used by SDK reflection.
-keepattributes Signature,*Annotation*
