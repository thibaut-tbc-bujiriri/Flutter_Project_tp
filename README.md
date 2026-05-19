# mini_flutter_app

Mini Flutter app — projet d'exemple généré par Flutter.

## Objectif

Ce dépôt contient une application Flutter minimale utilisée pour le développement et les tests locaux (Android, Windows, Web).

## Prérequis

- Flutter SDK installé (vérifier avec `flutter --version`).
- Pour Android: Android SDK + platform-tools, et au moins un émulateur ou un appareil connecté (USB debugging activé).
- Pour Windows: activez le support desktop (`flutter config --enable-windows-desktop`).
- Un éditeur compatible (VS Code, Android Studio) est recommandé.

Exécutez `flutter doctor` pour vérifier et corriger les éventuels manquements.

## Commandes utiles

- Lancer l'app (choisir automatiquement ou via invite):

```powershell
flutter run
```

- Lancer sur un appareil spécifique (exemple avec l'ID détecté):

```powershell
flutter run -d 24071JEAR14179
```

- Lister les appareils disponibles:

```powershell
flutter devices
```

- Construire un APK Android:

```powershell
flutter build apk --release
```

- Lancer pour le web (Chrome):

```powershell
flutter run -d chrome
```

- Lancer pour Windows (si activé):

```powershell
flutter run -d windows
```

## Conseils de dépannage

- Si `flutter run -d android` retourne "No supported devices found":
	- Exécutez `flutter devices` et utilisez l'ID exact du device listé.
	- Assurez-vous que votre téléphone est en mode débogage USB et autorisé.
	- Redémarrez l'adb: `adb kill-server && adb start-server`.
- Exécutez `flutter doctor -v` pour obtenir des diagnostics détaillés.
- Si la compilation échoue sur Android, vérifiez le `local.properties` (chemin du SDK Android) et les versions du SDK dans `android/build.gradle.kts`.

## Tests

- Lancer les tests unitaires:

```powershell
flutter test
```

## Contribution et développement

- Ouvrez une nouvelle branche pour vos changements et soumettez une PR si besoin.
- Pour garder le code propre, exécutez `flutter format .` avant de committer.

Si tu veux, j'ajoute des instructions spécifiques pour ton environnement (émulateur Android, configuration Windows, ou déploiement), dis-moi ce que tu préfères.
