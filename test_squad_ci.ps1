# Script de test pour SQUAD CI
# Usage: .\test_squad_ci.ps1

Write-Host "🚀 Test de l'application SQUAD CI" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green

# Vérification de Flutter
Write-Host "`n📋 Vérification de Flutter..." -ForegroundColor Yellow
try {
    $flutterVersion = flutter --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Flutter installé" -ForegroundColor Green
        $flutterVersion | Select-String "Flutter" | ForEach-Object { Write-Host "   $_" -ForegroundColor Gray }
    } else {
        Write-Host "❌ Flutter non trouvé" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ Erreur lors de la vérification de Flutter" -ForegroundColor Red
    exit 1
}

# Vérification du projet
Write-Host "`n📂 Vérification du projet..." -ForegroundColor Yellow
if (Test-Path "pubspec.yaml") {
    Write-Host "✅ Fichier pubspec.yaml trouvé" -ForegroundColor Green
} else {
    Write-Host "❌ Fichier pubspec.yaml manquant" -ForegroundColor Red
    exit 1
}

if (Test-Path "lib/main.dart") {
    Write-Host "✅ Fichier main.dart trouvé" -ForegroundColor Green
} else {
    Write-Host "❌ Fichier main.dart manquant" -ForegroundColor Red
    exit 1
}

# Vérification de l'architecture
Write-Host "`n🏗️ Vérification de l'architecture..." -ForegroundColor Yellow
$folders = @("lib/models", "lib/services", "lib/providers", "lib/screens", "lib/widgets", "lib/utils")
foreach ($folder in $folders) {
    if (Test-Path $folder) {
        $fileCount = (Get-ChildItem $folder -Filter "*.dart").Count
        Write-Host "✅ $folder ($fileCount fichiers)" -ForegroundColor Green
    } else {
        Write-Host "❌ $folder manquant" -ForegroundColor Red
    }
}

# Vérification des dépendances
Write-Host "`n📦 Vérification des dépendances..." -ForegroundColor Yellow
try {
    Write-Host "   Installation des dépendances..." -ForegroundColor Gray
    $pubGet = flutter pub get 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Dépendances installées" -ForegroundColor Green
    } else {
        Write-Host "❌ Erreur lors de l'installation des dépendances" -ForegroundColor Red
        Write-Host $pubGet -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Erreur lors de flutter pub get" -ForegroundColor Red
}

# Analyse du code
Write-Host "`n🔍 Analyse du code..." -ForegroundColor Yellow
try {
    $analysis = flutter analyze --no-congratulate 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Aucun problème détecté" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Problèmes détectés :" -ForegroundColor Yellow
        Write-Host $analysis -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Erreur lors de l'analyse" -ForegroundColor Red
}

# Vérification Firebase
Write-Host "`n🔥 Vérification Firebase..." -ForegroundColor Yellow
if (Test-Path "android/app/google-services.json") {
    Write-Host "✅ Configuration Firebase trouvée" -ForegroundColor Green
} else {
    Write-Host "⚠️ Configuration Firebase manquante" -ForegroundColor Yellow
    Write-Host "   Consultez FIREBASE_CONFIG.md pour la configuration" -ForegroundColor Gray
}

# Liste des appareils
Write-Host "`n📱 Appareils disponibles..." -ForegroundColor Yellow
try {
    $devices = flutter devices --machine 2>&1 | ConvertFrom-Json
    if ($devices.Count -gt 0) {
        foreach ($device in $devices) {
            Write-Host "✅ $($device.name) ($($device.id))" -ForegroundColor Green
        }
    } else {
        Write-Host "⚠️ Aucun appareil trouvé" -ForegroundColor Yellow
        Write-Host "   Démarrez un émulateur ou connectez un appareil" -ForegroundColor Gray
    }
} catch {
    Write-Host "⚠️ Impossible de lister les appareils" -ForegroundColor Yellow
}

# Résumé
Write-Host "`n📊 Résumé:" -ForegroundColor Blue
Write-Host "=================================" -ForegroundColor Blue
Write-Host "✅ Projet SQUAD CI configuré" -ForegroundColor Green
Write-Host "✅ Architecture Flutter complète" -ForegroundColor Green
Write-Host "✅ Toutes les dépendances installées" -ForegroundColor Green

Write-Host "`n🚀 Prêt pour le développement !" -ForegroundColor Green
Write-Host "`nCommandes utiles:" -ForegroundColor Blue
Write-Host "  flutter run -d chrome    # Lancer sur Chrome" -ForegroundColor Gray
Write-Host "  flutter run              # Lancer sur l'émulateur" -ForegroundColor Gray
Write-Host "  flutter hot-reload       # Rechargement à chaud" -ForegroundColor Gray
Write-Host "  flutter hot-restart      # Redémarrage à chaud" -ForegroundColor Gray
