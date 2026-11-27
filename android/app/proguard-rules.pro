# Reglas de R8 para los builds de release (APK de prueba y Release).
#
# google_mlkit_text_recognition (bitácora, V2-M18) nombra en su código las
# clases de los reconocedores de chino, devanagari, japonés y coreano, pero la
# app solo trae el latino (modelo incluido): esas clases no existen en el APK y
# nunca se cargan. Sin estas reglas R8 aborta con «Missing classes» y el APK de
# release no se genera.
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
