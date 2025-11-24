#!/bin/bash

set -e

INSTALL_PATH="/usr/local/bin/protoc-gen-grpc-web"
DOWNLOAD_URL="https://github.com/grpc/grpc-web/releases/download/1.5.0/protoc-gen-grpc-web-1.5.0-linux-x86_64"
EXPECTED_VERSION="1.5.0"
TEMP_FILE="protoc-gen-grpc-web-1.5.0-linux-x86_64"

echo "=== Verification de protoc-gen-grpc-web ==="

# Fonction de verification
check_installation() {
    if [ ! -f "$INSTALL_PATH" ]; then
        echo "[X] protoc-gen-grpc-web n'est pas installe"
        return 1
    fi
    
    # Verifier que c'est un executable valide
    if ! file "$INSTALL_PATH" | grep -q "ELF 64-bit LSB executable"; then
        echo "[X] Le fichier existe mais n'est pas un executable valide"
        return 1
    fi
    
    # Verifier la version
    if ! command -v protoc-gen-grpc-web &> /dev/null; then
        echo "[X] protoc-gen-grpc-web n'est pas executable"
        return 1
    fi
    
    CURRENT_VERSION=$(protoc-gen-grpc-web --version 2>&1 | grep -oP '\d+\.\d+\.\d+' || echo "unknown")
    
    if [ "$CURRENT_VERSION" != "$EXPECTED_VERSION" ]; then
        echo "[!] Version installee: $CURRENT_VERSION (attendue: $EXPECTED_VERSION)"
        return 1
    fi
    
    echo "[OK] protoc-gen-grpc-web $CURRENT_VERSION est deja installe et fonctionnel"
    return 0
}

# Verifier l'installation existante
if check_installation; then
    echo "[OK] Aucune action necessaire"
    exit 0
fi

echo ""
echo "=== Installation de protoc-gen-grpc-web ==="

# Supprimer l'ancien fichier s'il existe
if [ -f "$INSTALL_PATH" ]; then
    echo "[INFO] Suppression de l'ancien fichier..."
    sudo rm -f "$INSTALL_PATH"
fi

# Supprimer le fichier temporaire s'il existe
if [ -f "$TEMP_FILE" ]; then
    echo "[INFO] Nettoyage du fichier temporaire existant..."
    rm -f "$TEMP_FILE"
fi

# Telecharger
echo "[INFO] Telechargement de protoc-gen-grpc-web $EXPECTED_VERSION..."
if ! wget -q --show-progress "$DOWNLOAD_URL"; then
    echo "[X] Echec du telechargement"
    exit 1
fi

# Verifier le telechargement
if [ ! -f "$TEMP_FILE" ]; then
    echo "[X] Le fichier telecharge n'existe pas"
    exit 1
fi

# Verifier la taille (doit etre ~31-33 MB)
FILE_SIZE=$(stat -f%z "$TEMP_FILE" 2>/dev/null || stat -c%s "$TEMP_FILE" 2>/dev/null)
if [ "$FILE_SIZE" -lt 30000000 ]; then
    echo "[X] Le fichier telecharge est trop petit ($FILE_SIZE bytes). Possible erreur de telechargement."
    rm -f "$TEMP_FILE"
    exit 1
fi

# Rendre executable
echo "[INFO] Configuration des permissions..."
chmod +x "$TEMP_FILE"

# Installer
echo "[INFO] Installation dans $INSTALL_PATH..."
sudo mv "$TEMP_FILE" "$INSTALL_PATH"

# Verification finale
echo ""
echo "=== Verification de l'installation ==="

if ! file "$INSTALL_PATH" | grep -q "ELF 64-bit LSB executable"; then
    echo "[X] Le fichier installe n'est pas un executable valide"
    exit 1
fi

INSTALLED_VERSION=$(protoc-gen-grpc-web --version 2>&1 | grep -oP '\d+\.\d+\.\d+' || echo "unknown")

if [ "$INSTALLED_VERSION" != "$EXPECTED_VERSION" ]; then
    echo "[X] Version installee incorrecte: $INSTALLED_VERSION (attendue: $EXPECTED_VERSION)"
    exit 1
fi

echo "[OK] Installation reussie!"
echo "[INFO] Type de fichier: $(file $INSTALL_PATH | cut -d: -f2)"
echo "[INFO] Version: $INSTALLED_VERSION"
echo ""
echo "[OK] protoc-gen-grpc-web est pret a l'emploi"

