#!/data/data/com.termux/files/usr/bin/bash

# ==========================================
#          ULTIMATE SYSTEM 5.1
#          ANDROID DEVELOPMENT
# ==========================================

VERSION="5.1.0"
NAME="ULTIMATE"

# CONFIGURACAO DO GITHUB
REPO_USER="ZenitsuScripter"
REPO_NAME="ULTIMATE-TERMUX"
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
# SISTEMA DE ATUALIZACAO INTELIGENTE
# ==========================================

# Hash do conteudo de um arquivo (detecta mudancas mesmo sem trocar a versao)
file_hash() {
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$1" 2>/dev/null | cut -d ' ' -f1
    elif command -v cksum >/dev/null 2>&1; then
        cksum < "$1" 2>/dev/null | tr ' ' '-'
    fi
}

# Le a variavel VERSION="x.y.z" de um arquivo
file_version() {
    grep -m1 '^VERSION=' "$1" 2>/dev/null | cut -d '"' -f2
}

# Versao valida: numeros separados por ponto (ex.: 5.1.0)
version_valid() {
    [[ "$1" =~ ^[0-9]+(\.[0-9]+)*$ ]]
}

# Retorna 0 se $1 for maior que $2
version_gt() {
    [[ "$1" == "$2" ]] && return 1
    [[ "$(printf '%s\n%s\n' "$1" "$2" | sort -V | tail -n1)" == "$1" ]]
}

# Baixa e valida o arquivo remoto.
# Sucesso: arquivo em $1 e REMOTE_VERSION preenchida.
# Falha: retorna 1 e UPDATE_ERROR traz o motivo.
fetch_remote() {
    local dest="$1"
    local timeout="${2:-10}"

    UPDATE_ERROR=""
    REMOTE_VERSION=""

    if ! command -v curl >/dev/null 2>&1; then
        UPDATE_ERROR="Curl nao encontrado. Instale com: pkg install curl"
        return 1
    fi

    if ! curl -fsSL --connect-timeout "$timeout" --max-time 60 \
        -H "Cache-Control: no-cache" \
        "${REMOTE_URL}?nocache=$(date +%s)" -o "$dest" 2>/dev/null; then
        UPDATE_ERROR="Nao foi possivel acessar o GitHub. Verifique a conexao."
        rm -f "$dest"
        return 1
    fi

    if [[ ! -s "$dest" ]]; then
        UPDATE_ERROR="O arquivo remoto veio vazio."
        rm -f "$dest"
        return 1
    fi

    if ! bash -n "$dest" 2>/dev/null; then
        UPDATE_ERROR="O arquivo remoto possui erro de sintaxe (bash -n)."
        rm -f "$dest"
        return 1
    fi

    REMOTE_VERSION="$(file_version "$dest")"

    if ! version_valid "$REMOTE_VERSION" || ! grep -q 'main_menu' "$dest"; then
        UPDATE_ERROR="O arquivo remoto nao parece ser um ULTIMATE valido."
        REMOTE_VERSION=""
        rm -f "$dest"
        return 1
    fi

    return 0
}

# Substitui o arquivo instalado com backup e rollback automatico.
# $1 = arquivo novo ja validado
apply_update() {
    local new="$1"
    local stage="$INSTALL_FILE.new.$$"
    local old_version
    old_version="$(file_version "$INSTALL_FILE")"
    [[ -z "$old_version" ]] && old_version="$VERSION"

    BACKUP_FILE="$BACKUP_DIR/ultimate-${old_version}-$(date +%Y%m%d-%H%M%S).sh"

    mkdir -p "$BACKUP_DIR" 2>/dev/null

    # 1) Backup da versao atual
    if ! cp -p "$INSTALL_FILE" "$BACKUP_FILE" 2>/dev/null || [[ ! -s "$BACKUP_FILE" ]]; then
        UPDATE_ERROR="Nao foi possivel criar o backup. Nada foi alterado."
        rm -f "$BACKUP_FILE"
        BACKUP_FILE=""
        return 1
    fi

    # 2) Prepara o arquivo novo ao lado do instalado (mesmo disco = troca atomica)
    if ! cp "$new" "$stage" 2>/dev/null; then
        UPDATE_ERROR="Nao foi possivel preparar o novo arquivo. Instalacao atual preservada."
        rm -f "$stage"
        return 1
    fi

    # 3) Permissao de execucao e revalidacao antes de trocar
    chmod +x "$stage" 2>/dev/null

    if ! bash -n "$stage" 2>/dev/null; then
        UPDATE_ERROR="Falha na validacao final (bash -n). Instalacao atual preservada."
        rm -f "$stage"
        return 1
    fi

    # 4) Troca atomica
    if ! mv -f "$stage" "$INSTALL_FILE" 2>/dev/null; then
        UPDATE_ERROR="Nao foi possivel substituir o arquivo. Instalacao atual preservada."
        rm -f "$stage"
        if [[ ! -s "$INSTALL_FILE" ]]; then
            cp -p "$BACKUP_FILE" "$INSTALL_FILE" 2>/dev/null
        fi
        chmod +x "$INSTALL_FILE" 2>/dev/null
        return 1
    fi

    chmod +x "$INSTALL_FILE" 2>/dev/null

    # 5) Confere o resultado; se estiver errado, volta o backup
    if [[ "$(file_hash "$INSTALL_FILE")" != "$(file_hash "$new")" ]] || ! bash -n "$INSTALL_FILE" 2>/dev/null; then
        UPDATE_ERROR="A verificacao pos-instalacao falhou. Backup restaurado."
        cp -p "$BACKUP_FILE" "$stage" 2>/dev/null &&
            chmod +x "$stage" 2>/dev/null &&
            mv -f "$stage" "$INSTALL_FILE" 2>/dev/null
        rm -f "$stage"
        chmod +x "$INSTALL_FILE" 2>/dev/null
        return 1
    fi

    return 0
}

# Fluxo completo.
# $1 = manual (menu/comando) ou auto (checagem ao abrir)
# Retorna 0 normalmente e 2 quando a atualizacao foi instalada.
smart_update() {
    local mode="${1:-manual}"
    local timeout=10
    local tmp="$HOME_ULT/update.$$.tmp"
    local local_hash remote_hash local_version reason resposta

    [[ "$mode" == "auto" ]] && timeout=5

    if [[ ! -f "$INSTALL_FILE" ]]; then
        if [[ "$mode" == "manual" ]]; then
            echo -e "${R}ULTIMATE nao esta instalado.${N}"
            echo "Instale com: bash ultimate.sh install"
        fi
        return 0
    fi

    if ! fetch_remote "$tmp" "$timeout"; then
        if [[ "$mode" == "manual" ]]; then
            echo -e "${R}${UPDATE_ERROR}${N}"
        fi
        rm -f "$tmp"
        return 0
    fi

    local_hash="$(file_hash "$INSTALL_FILE")"
    remote_hash="$(file_hash "$tmp")"

    local_version="$(file_version "$INSTALL_FILE")"
    [[ -z "$local_version" ]] && local_version="$VERSION"

    if [[ "$mode" == "manual" ]]; then
        echo ""
        echo -e "${D}Versao local:  ${local_version}${N}"
        echo -e "${D}Versao remota: ${REMOTE_VERSION}${N}"
        echo ""
    fi

    # Decide se existe atualizacao
    if version_gt "$REMOTE_VERSION" "$local_version"; then
        reason="version"
    elif [[ "$REMOTE_VERSION" == "$local_version" && -n "$local_hash" && "$local_hash" != "$remote_hash" ]]; then
        reason="content"
    else
        if [[ "$mode" == "manual" ]]; then
            if version_gt "$local_version" "$REMOTE_VERSION"; then
                echo -e "${G}Sua versao local e mais recente que a do GitHub. Nenhuma atualizacao necessaria.${N}"
            else
                echo -e "${G}ULTIMATE ja esta atualizado!${N}"
            fi
        fi
        rm -f "$tmp"
        return 0
    fi

    echo ""

    if [[ "$reason" == "version" ]]; then
        echo -e "${Y}Nova versao disponivel: $REMOTE_VERSION (atual: $local_version)${N}"
    else
        echo -e "${Y}Atualizacao disponivel: o codigo no GitHub mudou (versao $local_version).${N}"
    fi

    read -rp "Deseja atualizar? (s/n): " resposta

    if [[ ! "$resposta" =~ ^[Ss]$ ]]; then
        echo "Atualizacao cancelada."
        rm -f "$tmp"
        return 0
    fi

    if apply_update "$tmp"; then
        rm -f "$tmp"
        echo ""
        echo -e "${G}Atualizacao concluida com sucesso!${N}"
        echo -e "${D}Backup salvo em: $BACKUP_FILE${N}"
        echo "Reinicie o ULTIMATE para carregar a nova versao."
        return 2
    fi

    rm -f "$tmp"
    echo ""
    echo -e "${R}ERRO: ${UPDATE_ERROR}${N}"

    # No modo auto a tela e limpa logo depois, entao espera o usuario ler
    [[ "$mode" == "auto" ]] && pause

    return 0
}

update_system() {

    clear

    banner

    echo -e "${C}VERIFICANDO ATUALIZACOES...${N}"

    smart_update manual
    rc=$?

    if [[ $rc -eq 2 ]]; then
        exit 0
    fi

    pause
}

# ==========================================
# VERIFICACAO AUTOMATICA
# ==========================================

check_update() {

    smart_update auto

    if [[ $? -eq 2 ]]; then
        exit 0
    fi
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
