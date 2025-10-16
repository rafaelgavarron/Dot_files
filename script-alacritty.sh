#!/usr/bin/env bash
# ===========================================
# Instalador e atualizador automático do Alacritty
# ===========================================

set -e

# Diretório de instalação
INSTALL_DIR="$HOME/.local/bin"
BUILD_DIR="$HOME/.alacritty-build"
REPO_URL="https://github.com/alacritty/alacritty.git"

# Verifica dependências
echo "🧩 Verificando dependências..."
sudo apt update -qq
sudo apt install -y git curl cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev libxkbcommon-dev python3 rustc cargo

# Cria diretórios necessários
mkdir -p "$INSTALL_DIR"

# Função para buildar
build_alacritty() {
    echo "⚙️  Buildando Alacritty..."
    cd "$BUILD_DIR"
    cargo build --release
    cp target/release/alacritty "$INSTALL_DIR/"
}

# Se o diretório já existir, apenas atualiza
if [ -d "$BUILD_DIR/.git" ]; then
    echo "🔄 Atualizando Alacritty..."
    cd "$BUILD_DIR"
    git pull --rebase
    build_alacritty
else
    echo "⬇️  Clonando repositório..."
    git clone "$REPO_URL" "$BUILD_DIR"
    build_alacritty
fi

# Adiciona ao PATH (caso não esteja)
if ! grep -q "$INSTALL_DIR" <<< "$PATH"; then
    echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >> "$HOME/.bashrc"
    echo "✅ Caminho adicionado ao .bashrc (reinicie o terminal)"
fi

# Cria o .desktop no sistema (para aparecer no menu)
DESKTOP_FILE="$HOME/.local/share/applications/alacritty.desktop"
if [ ! -f "$DESKTOP_FILE" ]; then
    echo "🪟 Criando atalho no sistema..."
    mkdir -p "$(dirname "$DESKTOP_FILE")"
    cat > "$DESKTOP_FILE" <<EOF
[Desktop Entry]
Name=Alacritty
Comment=Terminal rápido e moderno
Exec=$INSTALL_DIR/alacritty
Icon=utilities-terminal
Terminal=false
Type=Application
Categories=System;TerminalEmulator;
EOF
    update-desktop-database ~/.local/share/applications/
fi

echo "✅ Alacritty instalado/atualizado com sucesso!"
alacritty --version

