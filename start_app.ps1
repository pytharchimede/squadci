# Script de démarrage de SQUAD CI
Write-Host "🚀 Démarrage de SQUAD CI..." -ForegroundColor Green

# Vérification de l'environnement
Write-Host "📋 Vérification de l'environnement Flutter..." -ForegroundColor Yellow
flutter doctor --verbose

# Nettoyage et installation des dépendances
Write-Host "🧹 Nettoyage du projet..." -ForegroundColor Yellow
flutter clean
flutter pub get

# Analyse du code
Write-Host "🔍 Analyse du code..." -ForegroundColor Yellow
flutter analyze --no-congratulate

# Lancement de l'application
Write-Host "🌐 Lancement sur Chrome..." -ForegroundColor Green
flutter run -d chrome --web-renderer canvaskit

Write-Host "✅ SQUAD CI est maintenant en cours d'exécution !" -ForegroundColor Green
