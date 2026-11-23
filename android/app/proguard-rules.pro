# Keep ML Kit core & text recognition classes
-keep class com.google.mlkit.** { *; }

# Suppress R8 missing-class errors for optional non-Latin script recognizers
# not bundled by default (Chinese, Devanagari, Japanese, Korean)
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
