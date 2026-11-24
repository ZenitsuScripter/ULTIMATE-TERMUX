#!/data/data/com.termux/files/usr/bin/bash

# ==========================================
#          ULTIMATE SYSTEM 5.0
#          ANDROID DEVELOPMENT
# ==========================================

VERSION="5.0.0"
NAME="ULTIMATE"

# CONFIGURACAO DO GITHUB
REPO_USER="ZenitsuScripter"
REPO_NAME="ULTIMATE"
BRANCH="main"

REMOTE_URL="https://raw.githubusercontent.com/${REPO_USER}/${REPO_NAME}/${BRANCH}/ultimate.sh"

HOME_ULT="$HOME/.ultimate"
INSTALL_FILE="$HOME_ULT/ultimate.sh"
BACKUP_DIR="$HOME_ULT/backups"
PROJECT_DIR="$HOME/Projects"

mkdir -p "$HOME_ULT" "$BACKUP_DIR" "$PROJECT_DIR"

# CORES
G='\033[1;32m'
C='\033[1;36m'
P='\033[1;35m'
Y='\033[1;33m'
R='\033[1;31m'
W='\033[1;37m'
D='\033[0;37m'
N='\033[0m'

# ==========================================
# FUNCOES VISUAIS
# ==========================================

line() {
    echo -e "${C}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
}

pause() {
    echo ""
    read -rp "PRESSIONE ENTER PARA CONTINUAR..."
}

loading() {
    echo -ne "${C}$1 ${N}"
    for i in 1 2 3; do
        echo -ne "● "
        sleep 0.15
    done
    echo ""
}

banner() {
    clear

    echo ""

    if command -v figlet >/dev/null 2>&1; then
        figlet -f slant ULTIMATE 2>/dev/null |
            while IFS= read -r line; do
                echo -e "${C}${line}${N}"
            done
    else
        echo -e "${G}██╗   ██╗██╗  ████████╗${N}"
        echo -e "${C}██║   ██║██║  ╚══██╔══╝${N}"
        echo -e "${P}██║   ██║██║     ██║${N}"
        echo -e "${G}╚██████╔╝███████╗██║${N}"
        echo -e "${C} ╚═════╝ ╚══════╝╚═╝${N}"
    fi

    line

    echo -e "${G}       ULTIMATE DEVELOPMENT SYSTEM${N}"
    echo -e "${C}       ANDROID TERMINAL ENVIRONMENT${N}"

    line

    echo -e "${D} VERSION: ${VERSION} | STATUS: ONLINE${N}"

    echo ""
}

# ==========================================
# INFORMACOES DO SISTEMA
# ==========================================

system_info() {
    clear

    banner

    if command -v fastfetch >/dev/null 2>&1; then
        fastfetch
    else
        echo "Dispositivo: $(getprop ro.product.model)"
        echo "Android: $(getprop ro.build.version.release)"
        echo "Arquitetura: $(uname -m)"
        echo "Kernel: $(uname -r)"
    fi

    pause
}

# ==========================================
# MONITOR DO DISPOSITIVO
# ==========================================

monitor() {
    while true; do

        clear

        banner

        echo -e "${G}       SYSTEM MONITOR${N}"

        line

        echo -e "${C}BATERIA${N}"

        if command -v termux-battery-status >/dev/null 2>&1; then
            termux-battery-status
        else
            echo "Instale o aplicativo Termux:API."
        fi

        echo ""

        echo -e "${C}MEMORIA RAM${N}"

        grep -E 'MemTotal|MemAvailable' /proc/meminfo

        echo ""

        echo -e "${C}ARMAZENAMENTO${N}"

        df -h "$HOME"

        echo ""

        echo -e "${C}PROCESSOS${N}"

        uptime

        echo ""

        echo "[1] Atualizar monitor"
        echo "[0] Voltar"

        read -rp "MONITOR > " op

        case "$op" in
            1) continue ;;
            0) break ;;
            *) continue ;;
        esac

    done
}

# ==========================================
# AREA DE COMANDOS
# ==========================================

command_area() {
    clear

    banner

    echo -e "${G}       ULTIMATE COMMAND TERMINAL${N}"

    line

    echo -e "${Y}Digite exit para retornar ao ULTIMATE.${N}"

    echo ""

    bash --norc --noprofile -i
}

# ==========================================
# CENTRAL DE FERRAMENTAS
# ==========================================

tools_menu() {

    while true; do

        clear

        banner

        echo -e "${P}       DEVELOPMENT TOOLS${N}"

        line

        echo -e "${C}[1]${N} Python"
        echo -e "${C}[2]${N} Node.js"
        echo -e "${C}[3]${N} Git"
        echo -e "${C}[4]${N} Nano"
        echo -e "${C}[5]${N} Instalar pacote"
        echo -e "${C}[6]${N} Atualizar pacotes"
        echo -e "${R}[0]${N} Voltar"

        echo ""

        read -rp "TOOLS > " op

        case "$op" in

            1)
                python
                ;;

            2)
                node
                ;;

            3)
                git --version
                pause
                ;;

            4)
                nano
                ;;

            5)
                read -rp "Nome do pacote: " pacote

                if [[ "$pacote" =~ ^[a-zA-Z0-9._+-]+$ ]]; then
                    pkg install "$pacote"
                else
                    echo -e "${R}Nome inválido.${N}"
                fi

                pause
                ;;

            6)
                pkg update && pkg upgrade -y
                pause
                ;;

            0)
                break
                ;;

            *)
                echo -e "${R}Opcao invalida.${N}"
                sleep 1
                ;;

        esac

    done
}

# ==========================================
# GERENCIADOR DE PROJETOS
# ==========================================

projects_menu() {

    while true; do

        clear

        banner

        echo -e "${P}       PROJECT MANAGER${N}"

        line

        echo "[1] Listar projetos"
        echo "[2] Criar projeto"
        echo "[3] Abrir pasta Projects"
        echo "[0] Voltar"

        echo ""

        read -rp "PROJECTS > " op

        case "$op" in

            1)
                ls -lah "$PROJECT_DIR"
                pause
                ;;

            2)
                read -rp "Nome do projeto: " nome

                if [[ "$nome" =~ ^[a-zA-Z0-9_-]+$ ]]; then
                    mkdir -p "$PROJECT_DIR/$nome"
                    echo -e "${G}Projeto criado!${N}"
                else
                    echo -e "${R}Nome inválido.${N}"
                fi

                pause
                ;;

            3)
                cd "$PROJECT_DIR"
                ls -lah
                pause
                ;;

            0)
                break
                ;;

            *)
                echo -e "${R}Opcao invalida.${N}"
                sleep 1
                ;;

        esac

    done
}

# ==========================================
# SISTEMA DE ATUALIZACAO
# ==========================================

update_system() {

    clear

    banner

    echo -e "${C}VERIFICANDO ATUALIZACOES...${N}"

    if ! command -v curl >/dev/null 2>&1; then
        echo "Curl não encontrado."
        pause
        return
    fi

    TMP="$HOME_ULT/update.tmp"

    if ! curl -fsSL --connect-timeout 10 "$REMOTE_URL" -o "$TMP"; then
        echo -e "${R}Nao foi possivel acessar o GitHub.${N}"
        rm -f "$TMP"
        pause
        return
    fi

    if ! bash -n "$TMP"; then
        echo -e "${R}Arquivo remoto possui erro de sintaxe.${N}"
        rm -f "$TMP"
        pause
        return
    fi

    NEW_VERSION=$(grep -m1 '^VERSION=' "$TMP" | cut -d '"' -f2)

    if [[ -z "$NEW_VERSION" ]]; then
        echo -e "${R}Versao remota invalida.${N}"
        rm -f "$TMP"
        pause
        return
    fi

    if [[ "$NEW_VERSION" == "$VERSION" ]]; then
        echo -e "${G}ULTIMATE ja esta atualizado!${N}"
        rm -f "$TMP"
        pause
        return
    fi

    echo -e "${Y}Nova versao encontrada: $NEW_VERSION${N}"

    read -rp "Deseja atualizar? (s/n): " resposta

    if [[ "$resposta" =~ ^[Ss]$ ]]; then

        cp "$INSTALL_FILE" "$BACKUP_DIR/ultimate-$VERSION.sh" 2>/dev/null

        cp "$TMP" "$INSTALL_FILE"

        chmod +x "$INSTALL_FILE"

        rm -f "$TMP"

        echo -e "${G}Atualizacao concluida!${N}"

        echo "Reinicie o menu para carregar a nova versao."

        exit 0

    else

        rm -f "$TMP"

        echo "Atualizacao cancelada."

    fi

    pause
}

# ==========================================
# VERIFICACAO AUTOMATICA
# ==========================================

check_update() {

    if ! command -v curl >/dev/null 2>&1; then
        return
    fi

    TMP="$HOME_ULT/check.tmp"

    if curl -fsSL --connect-timeout 5 "$REMOTE_URL" -o "$TMP" 2>/dev/null; then

        REMOTE_VERSION=$(grep -m1 '^VERSION=' "$TMP" | cut -d '"' -f2)

        if [[ -n "$REMOTE_VERSION" && "$REMOTE_VERSION" != "$VERSION" ]]; then

            echo ""
            echo -e "${Y}Nova versão disponível: $REMOTE_VERSION${N}"

            read -rp "Atualizar agora? (s/n): " resposta

            if [[ "$resposta" =~ ^[Ss]$ ]]; then

                cp "$INSTALL_FILE" "$BACKUP_DIR/ultimate-$VERSION.sh" 2>/dev/null

                if bash -n "$TMP"; then
                    cp "$TMP" "$INSTALL_FILE"
                    chmod +x "$INSTALL_FILE"
                    echo -e "${G}Atualizado! Reinicie o ULTIMATE.${N}"
                    rm -f "$TMP"
                    exit 0
                fi

            fi

        fi

    fi

    rm -f "$TMP"
}

# ==========================================
# INSTALACAO
# ==========================================

install_system() {

    clear

    echo -e "${C}"
    echo "======================================"
    echo "          ULTIMATE INSTALLER"
    echo "======================================"
    echo -e "${N}"

    echo "[1/5] Instalando dependencias..."

    pkg install curl git python nodejs nano figlet fastfetch ruby -y

    echo "[2/5] Configurando diretorios..."

    mkdir -p "$HOME_ULT" "$BACKUP_DIR" "$PROJECT_DIR"

    echo "[3/5] Baixando ULTIMATE..."

    TMP="$HOME_ULT/install.tmp"

    if ! curl -fsSL "$REMOTE_URL" -o "$TMP"; then
        echo "Falha ao baixar o ULTIMATE."
        rm -f "$TMP"
        return 1
    fi

    if ! bash -n "$TMP"; then
        echo "Arquivo remoto inválido."
        rm -f "$TMP"
        return 1
    fi

    cp "$TMP" "$INSTALL_FILE"
    chmod +x "$INSTALL_FILE"
    rm -f "$TMP"

    echo "[4/5] Configurando inicializacao..."

    touch "$HOME_ULT/installed"

    sed -i '/# ULTIMATE SYSTEM START/,/# ULTIMATE SYSTEM END/d' "$HOME/.bashrc"

    cat >> "$HOME/.bashrc" <<'BASHRC'

# ULTIMATE SYSTEM START

ultimate() {
    bash "$HOME/.ultimate/ultimate.sh" run
}

ultimate-update() {
    bash "$HOME/.ultimate/ultimate.sh" update
}

ultimate-version() {
    bash "$HOME/.ultimate/ultimate.sh" version
}

ultimate-uninstall() {
    bash "$HOME/.ultimate/ultimate.sh" uninstall
}

projetos() {
    cd "$HOME/Projects"
}

if [[ $- == *i* ]] && [[ -t 0 ]] && [[ -z "$ULTIMATE_ACTIVE" ]]; then
    export ULTIMATE_ACTIVE=1
    ultimate
    unset ULTIMATE_ACTIVE
fi

# ULTIMATE SYSTEM END

BASHRC

    echo "[5/5] Instalacao concluida!"

    echo ""
    echo -e "${G}ULTIMATE INSTALADO COM SUCESSO!${N}"
    echo ""
    echo "Feche e abra o Termux novamente."

}

# ==========================================
# INFORMACOES DA VERSAO
# ==========================================

version_info() {

    echo ""
    echo -e "${C}ULTIMATE SYSTEM${N}"
    echo -e "${G}Versao: $VERSION${N}"
    echo "Instalacao: $INSTALL_FILE"
    echo "Projetos: $PROJECT_DIR"
    echo ""

}

# ==========================================
# DESINSTALACAO
# ==========================================

uninstall_system() {

    echo ""
    echo -e "${R}DESINSTALAR ULTIMATE?${N}"

    read -rp "Digite SIM para confirmar: " resposta

    if [[ "$resposta" == "SIM" ]]; then

        sed -i '/# ULTIMATE SYSTEM START/,/# ULTIMATE SYSTEM END/d' "$HOME/.bashrc"

        rm -rf "$HOME_ULT"

        echo "ULTIMATE removido."
        echo "Seus projetos em ~/Projects foram preservados."

    else

        echo "Operacao cancelada."

    fi

}

# ==========================================
# MENU PRINCIPAL
# ==========================================

main_menu() {

    check_update

    while true; do

        banner

        echo -e "${G} SYSTEM STATUS: ONLINE${N}"
        echo -e "${P} VERSION: ${VERSION}${N}"

        line

        echo -e "${C} [1]${N} Area de comandos"
        echo -e "${C} [2]${N} Informacoes do sistema"
        echo -e "${C} [3]${N} Monitor do celular"
        echo -e "${C} [4]${N} Central de ferramentas"
        echo -e "${C} [5]${N} Gerenciador de projetos"
        echo -e "${C} [6]${N} Atualizar ULTIMATE"
        echo -e "${C} [7]${N} Informacoes da versao"
        echo -e "${R} [0]${N} Sair"

        line

        echo ""

        read -rp "ULTIMATE > " escolha

        case "$escolha" in

            1) command_area ;;
            2) system_info ;;
            3) monitor ;;
            4) tools_menu ;;
            5) projects_menu ;;
            6) update_system ;;
            7) version_info; pause ;;
            0) clear; break ;;

            *)
                echo -e "${R}Opcao invalida!${N}"
                sleep 1
                ;;

        esac

    done

}

# ==========================================
# SISTEMA DE EXECUCAO
# ==========================================

case "$1" in

    install)
        install_system
        ;;

    update)
        if [[ -f "$INSTALL_FILE" ]]; then
            update_system
        else
            echo "ULTIMATE nao instalado."
        fi
        ;;

    version)
        version_info
        ;;

    uninstall)
        uninstall_system
        ;;

    run|"")
        if [[ -f "$INSTALL_FILE" && "$0" != "$INSTALL_FILE" ]]; then
            exec bash "$INSTALL_FILE" run
        fi

        main_menu
        ;;

    *)
        echo "Comando desconhecido."
        ;;

esac