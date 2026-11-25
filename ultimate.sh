#!/data/data/com.termux/files/usr/bin/bash

# ==========================================
#          ULTIMATE SYSTEM 5.2
#          ANDROID DEVELOPMENT
# ==========================================

VERSION="5.2.0"
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
# MONITOR DO DISPOSITIVO (SYSTEM MONITOR 2.0)
# ==========================================

MON_NA="Indisponivel"
MON_PS_DIRS="/sys/class/power_supply/battery /sys/class/power_supply/Battery /sys/class/power_supply/BAT0"
MON_CPU_DIR="/sys/devices/system/cpu"

# Remove espacos nas pontas -> MON_V
mon_trim() {
    local s="$1"
    s="${s#"${s%%[![:space:]]*}"}"
    s="${s%"${s##*[![:space:]]}"}"
    MON_V="$s"
}

# Valor ou "Indisponivel" -> MON_V
mon_val() {
    MON_V="${1:-$MON_NA}"
}

# Corta o texto para caber na largura da tela -> MON_V
mon_cut() {
    local max=$(( MON_COLS - 14 ))
    (( max < 10 )) && max=10
    MON_V="${1:0:max}"
}

# Propriedade do Android (vazio se nao existir) -> MON_P
mon_prop() {
    MON_P=""
    command -v getprop >/dev/null 2>&1 || return 0
    MON_P="$(getprop "$1" 2>/dev/null)"
}

# Primeira linha de um arquivo, sem erro na tela (vazio se falhar) -> MON_V
mon_read() {
    MON_V=""
    [[ -r "$1" ]] || return 0
    { IFS= read -r MON_V < "$1"; } 2>/dev/null
}

# Valor de uma chave simples de um JSON -> MON_V
mon_json() {
    local re="\"$2\"[[:space:]]*:[[:space:]]*\"?([^\",}]*)"
    MON_V=""
    if [[ "$1" =~ $re ]]; then
        mon_trim "${BASH_REMATCH[1]}"
    fi
}

# KB -> texto legivel (ex.: 5.2 GB) -> MON_V
mon_fmt_kb() {
    local kb="$1" t
    MON_V="$MON_NA"
    [[ "$kb" =~ ^[0-9]+$ ]] || return 0
    if (( kb >= 1048576 )); then
        t=$(( (kb * 10 + 524288) / 1048576 ))
        MON_V="$(( t / 10 )).$(( t % 10 )) GB"
    else
        MON_V="$(( kb / 1024 )) MB"
    fi
}

# kHz -> texto legivel (ex.: 1.80 GHz) -> MON_V
mon_fmt_khz() {
    local k="$1"
    MON_V="$MON_NA"
    [[ "$k" =~ ^[0-9]+$ ]] || return 0
    if (( k >= 1000000 )); then
        printf -v MON_V '%d.%02d GHz' $(( k / 1000000 )) $(( k % 1000000 / 10000 ))
    else
        printf -v MON_V '%d MHz' $(( k / 1000 ))
    fi
}

# Barra de uso colorida (0-100). Com "inv", valor baixo = vermelho -> MON_BAR
mon_bar() {
    local p="$1" mode="$2" w=10 filled i color s=""
    MON_BAR=""
    [[ "$p" =~ ^[0-9]+$ ]] || return 0
    (( p > 100 )) && p=100
    filled=$(( p * w / 100 ))
    if [[ "$mode" == "inv" ]]; then
        if (( p < 20 )); then color="$R"; elif (( p < 50 )); then color="$Y"; else color="$G"; fi
    else
        if (( p < 60 )); then color="$G"; elif (( p < 85 )); then color="$Y"; else color="$R"; fi
    fi
    for (( i = 0; i < w; i++ )); do
        if (( i < filled )); then s+="█"; else s+="░"; fi
    done
    printf -v MON_BAR '%b%s%b' "$color" "$s" "$N"
}

# Tempo ligado (lido de /proc/uptime) -> MON_V (vazio se indisponivel)
mon_uptime() {
    local up d h m
    mon_read /proc/uptime
    up="${MON_V%% *}"
    up="${up%%.*}"
    if [[ ! "$up" =~ ^[0-9]+$ ]]; then
        MON_V=""
        return 0
    fi
    d=$(( up / 86400 ))
    h=$(( up % 86400 / 3600 ))
    m=$(( up % 3600 / 60 ))
    if (( d > 0 )); then
        printf -v MON_V '%dd %02dh %02dm' "$d" "$h" "$m"
    elif (( h > 0 )); then
        printf -v MON_V '%dh %02dm' "$h" "$m"
    else
        printf -v MON_V '%dm %02ds' "$m" $(( up % 60 ))
    fi
}

# Estado da bateria em portugues -> MON_V
mon_state_pt() {
    local s="${1^^}"
    s="${s// /_}"
    case "$s" in
        CHARGING)     MON_V="Carregando" ;;
        DISCHARGING)  MON_V="Descarregando" ;;
        FULL)         MON_V="Completa" ;;
        NOT_CHARGING) MON_V="Nao esta carregando" ;;
        "")           MON_V="$MON_NA" ;;
        *)            MON_V="$1" ;;
    esac
}

# Tamanho do terminal -> MON_ROWS / MON_COLS
mon_size() {
    local sz
    sz="$(stty size 2>/dev/null)"
    if [[ "$sz" =~ ^([0-9]+)[[:space:]]+([0-9]+)$ ]]; then
        MON_ROWS="${BASH_REMATCH[1]}"
        MON_COLS="${BASH_REMATCH[2]}"
    else
        MON_ROWS=50
        MON_COLS=60
    fi
    (( MON_ROWS < 5 )) && MON_ROWS=24
    (( MON_COLS < 20 )) && MON_COLS=40
}

# ---- Montagem das linhas do painel ----

mon_title() {
    local l
    printf -v l '%b[ %s ]%b' "$P" "$1" "$N"
    MON_L+=("$l")
}

mon_row() {
    local l
    printf -v l '%b%s:%b %b%s%b' "$C" "$1" "$N" "$W" "$2" "$N"
    MON_L+=("$l")
}

# Linha com valor (ou Indisponivel) ja cortado para a tela
mon_info() {
    mon_val "$2"
    mon_cut "$MON_V"
    mon_row "$1" "$MON_V"
}

mon_row_bar() {
    local l
    printf -v l '%b%s:%b %b%s%b %s' "$C" "$1" "$N" "$W" "$2" "$N" "$3"
    MON_L+=("$l")
}

mon_note() {
    local l
    printf -v l '%b%s%b' "$D" "$1" "$N"
    MON_L+=("$l")
}

# ---- Coleta de dados fixos (uma vez, ao abrir o monitor) ----

mon_static() {
    local k v f

    mon_prop ro.product.model;         S_MODEL="$MON_P"
    mon_prop ro.product.manufacturer;  S_MAKER="${MON_P^}"
    mon_prop ro.build.version.release; S_ANDROID="$MON_P"
    mon_prop ro.product.cpu.abi;       S_ABI="$MON_P"

    S_KERNEL="$(uname -r 2>/dev/null)"
    S_ARCH="$(uname -m 2>/dev/null)"
    S_BITS="$(getconf LONG_BIT 2>/dev/null)"
    [[ "$S_BITS" =~ ^[0-9]+$ ]] || S_BITS=""

    # Processador: cpuinfo -> propriedades do SoC
    S_CHIP=""
    if [[ -r /proc/cpuinfo ]]; then
        while IFS=: read -r k v; do
            mon_trim "$k"
            if [[ "$MON_V" == "Hardware" || "$MON_V" == "model name" ]]; then
                mon_trim "$v"
                S_CHIP="$MON_V"
                break
            fi
        done 2>/dev/null < /proc/cpuinfo
    fi
    if [[ -z "$S_CHIP" ]]; then
        mon_prop ro.soc.manufacturer; k="$MON_P"
        mon_prop ro.soc.model;        v="$MON_P"
        if [[ -n "$k" || -n "$v" ]]; then
            mon_trim "$k $v"
            S_CHIP="$MON_V"
        fi
    fi
    if [[ -z "$S_CHIP" ]]; then mon_prop ro.board.platform; S_CHIP="$MON_P"; fi
    if [[ -z "$S_CHIP" ]]; then mon_prop ro.hardware;       S_CHIP="$MON_P"; fi

    # Nucleos
    S_CORES="$(nproc --all 2>/dev/null)"
    if [[ ! "$S_CORES" =~ ^[0-9]+$ ]]; then
        S_CORES="$(grep -c '^processor' /proc/cpuinfo 2>/dev/null)"
    fi
    if [[ ! "$S_CORES" =~ ^[0-9]+$ ]] || (( S_CORES < 1 )); then
        S_CORES="$(getconf _NPROCESSORS_CONF 2>/dev/null)"
    fi
    if [[ ! "$S_CORES" =~ ^[0-9]+$ ]] || (( S_CORES < 1 )); then
        S_CORES=""
    fi

    # Frequencia maxima (quando o Android permite ler)
    S_FMAX=0
    for f in "$MON_CPU_DIR"/cpu[0-9]*/cpufreq/cpuinfo_max_freq; do
        [[ -r "$f" ]] || continue
        mon_read "$f"
        v="$MON_V"
        if [[ "$v" =~ ^[0-9]+$ ]] && (( v > S_FMAX )); then
            S_FMAX=$v
        fi
    done
}

# ---- Coleta de dados dinamicos (a cada atualizacao) ----

mon_collect_battery() {
    local json="" d t

    B_PCT=""
    B_TEMP=""
    B_STATE=""
    B_TECH=""

    # Termux:API (se falhar 2 vezes seguidas, deixa de tentar nesta sessao)
    if [[ "$MON_API" != "0" ]] && command -v termux-battery-status >/dev/null 2>&1; then
        if command -v timeout >/dev/null 2>&1; then
            json="$(timeout 3 termux-battery-status 2>/dev/null)"
        else
            json="$(termux-battery-status 2>/dev/null)"
        fi

        if [[ "$json" == *'"percentage"'* ]]; then
            MON_FAILS=0
        else
            json=""
            MON_FAILS=$(( MON_FAILS + 1 ))
            (( MON_FAILS >= 2 )) && MON_API=0
        fi
    fi

    if [[ -n "$json" ]]; then
        mon_json "$json" percentage;  B_PCT="$MON_V"
        mon_json "$json" temperature; B_TEMP="$MON_V"
        mon_json "$json" status;      B_STATE="$MON_V"

        # Valores invalidos (ex.: null) contam como ausentes
        [[ "$B_PCT" =~ ^[0-9]+$ ]] || B_PCT=""
        [[ "$B_TEMP" =~ ^[0-9]+(\.[0-9]+)?$ ]] || B_TEMP=""
    fi

    # Sem Termux:API: tenta ler direto do sistema (sem root)
    for d in $MON_PS_DIRS; do
        [[ -r "$d/capacity" || -r "$d/technology" ]] || continue

        if [[ -z "$B_PCT" ]]; then
            mon_read "$d/capacity"
            B_PCT="$MON_V"
        fi

        if [[ -z "$B_TEMP" ]]; then
            mon_read "$d/temp"
            t="$MON_V"
            if [[ "$t" =~ ^[0-9]+$ ]]; then
                printf -v B_TEMP '%d.%d' $(( t / 10 )) $(( t % 10 ))
            fi
        fi

        if [[ -z "$B_STATE" ]]; then
            mon_read "$d/status"
            B_STATE="$MON_V"
        fi

        mon_read "$d/technology"
        B_TECH="$MON_V"
        break
    done
}

mon_collect_memory() {
    local k v t="" a="" f="" b="" c=""

    R_TOTAL=""
    R_USED=""
    R_AVAIL=""
    R_PCT=""

    [[ -r /proc/meminfo ]] || return 0

    while IFS=': ' read -r k v _; do
        case "$k" in
            MemTotal)     t="$v" ;;
            MemAvailable) a="$v" ;;
            MemFree)      f="$v" ;;
            Buffers)      b="$v" ;;
            Cached)       c="$v" ;;
        esac
    done 2>/dev/null < /proc/meminfo

    if [[ -z "$a" && "$f" =~ ^[0-9]+$ ]]; then
        a=$(( f + ${b:-0} + ${c:-0} ))
    fi

    [[ "$t" =~ ^[0-9]+$ && "$a" =~ ^[0-9]+$ ]] || return 0
    (( t > 0 )) || return 0
    (( a > t )) && a=$t

    R_TOTAL=$t
    R_AVAIL=$a
    R_USED=$(( t - a ))
    R_PCT=$(( R_USED * 100 / t ))
}

mon_collect_storage() {
    local fs st="" su="" sa=""

    D_TOTAL=""
    D_USED=""
    D_AVAIL=""
    D_PCT=""

    { read -r; read -r fs st su sa _; } < <(df -kP "$HOME" 2>/dev/null)

    [[ "$st" =~ ^[0-9]+$ && "$su" =~ ^[0-9]+$ && "$sa" =~ ^[0-9]+$ ]] || return 0
    (( st > 0 )) || return 0

    D_TOTAL=$st
    D_USED=$su
    D_AVAIL=$sa
    D_PCT=$(( su * 100 / st ))
}

mon_collect_cpu() {
    local f v

    C_FCUR=0
    for f in "$MON_CPU_DIR"/cpu[0-9]*/cpufreq/scaling_cur_freq; do
        [[ -r "$f" ]] || continue
        mon_read "$f"
        v="$MON_V"
        if [[ "$v" =~ ^[0-9]+$ ]] && (( v > C_FCUR )); then
            C_FCUR=$v
        fi
    done
}

# ---- Desenho do painel (sem limpar a tela: evita piscar e restos antigos) ----

mon_render() {
    local hl l i w n max out now u t

    MON_L=()
    mon_size

    w=$(( MON_COLS - 1 ))
    (( w > 38 )) && w=38
    l=""
    for (( i = 0; i < w; i++ )); do l+="━"; done
    printf -v hl '%b%s%b' "$C" "$l" "$N"

    MON_L+=("$hl")
    printf -v l '%b       ULTIMATE SYSTEM MONITOR%b' "$G" "$N"
    MON_L+=("$l")
    MON_L+=("$hl")

    # DEVICE
    mon_title "DEVICE"
    mon_info "Modelo"     "$S_MODEL"
    mon_info "Fabricante" "$S_MAKER"
    mon_info "Android"    "$S_ANDROID"
    mon_info "Kernel"     "$S_KERNEL"
    if [[ -n "$S_ARCH" && -n "$S_BITS" ]]; then
        mon_info "Arquitetura" "$S_ARCH (${S_BITS}-bit)"
    else
        mon_info "Arquitetura" "$S_ARCH"
    fi
    mon_uptime
    mon_info "Uptime" "$MON_V"
    MON_L+=("")

    # BATTERY
    mon_title "BATTERY"
    if [[ "$B_PCT" =~ ^[0-9]+$ ]]; then
        mon_bar "$B_PCT" inv
        mon_row_bar "Carga" "${B_PCT}%" "$MON_BAR"
    else
        mon_row "Carga" "$MON_NA"
    fi
    if [[ "$B_TEMP" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        mon_row "Temperatura" "${B_TEMP}°C"
    else
        mon_row "Temperatura" "$MON_NA"
    fi
    mon_state_pt "$B_STATE"
    mon_row "Estado" "$MON_V"
    mon_info "Tecnologia" "$B_TECH"
    if [[ -z "$B_PCT" && -z "$B_TEMP" && -z "$B_STATE" ]]; then
        mon_note "Instale o aplicativo Termux:API."
    fi
    MON_L+=("")

    # MEMORY
    mon_title "MEMORY"
    if [[ -n "$R_PCT" ]]; then
        mon_fmt_kb "$R_USED";  u="$MON_V"
        mon_fmt_kb "$R_TOTAL"; t="$MON_V"
        mon_row "RAM" "$u / $t"
        mon_fmt_kb "$R_AVAIL"
        mon_row "Disponivel" "$MON_V"
        mon_bar "$R_PCT"
        mon_row_bar "Uso" "${R_PCT}%" "$MON_BAR"
    else
        mon_row "RAM" "$MON_NA"
    fi
    MON_L+=("")

    # STORAGE
    mon_title "STORAGE"
    if [[ -n "$D_PCT" ]]; then
        mon_fmt_kb "$D_USED";  u="$MON_V"
        mon_fmt_kb "$D_TOTAL"; t="$MON_V"
        mon_row "Utilizado" "$u / $t"
        mon_fmt_kb "$D_AVAIL"
        mon_row "Disponivel" "$MON_V"
        mon_bar "$D_PCT"
        mon_row_bar "Uso" "${D_PCT}%" "$MON_BAR"
    else
        mon_row "Utilizado" "$MON_NA"
    fi
    MON_L+=("")

    # PROCESSOR
    mon_title "PROCESSOR"
    mon_info "Chip" "$S_CHIP"
    if [[ -n "$S_ARCH" && -n "$S_ABI" ]]; then
        mon_info "Arquitetura" "$S_ARCH ($S_ABI)"
    else
        mon_info "Arquitetura" "$S_ARCH"
    fi
    mon_info "Nucleos" "$S_CORES"
    if (( C_FCUR > 0 )); then
        mon_fmt_khz "$C_FCUR"
        u="$MON_V"
        if (( S_FMAX > 0 )); then
            mon_fmt_khz "$S_FMAX"
            u="$u (max $MON_V)"
        fi
        mon_info "Frequencia" "$u"
    elif (( S_FMAX > 0 )); then
        mon_fmt_khz "$S_FMAX"
        mon_info "Frequencia" "max $MON_V"
    else
        mon_info "Frequencia" ""
    fi

    # Rodape
    printf -v now '%(%H:%M:%S)T' -1
    printf -v l '%b[0]%b Voltar %b| auto 2s | %s%b' "$R" "$N" "$D" "$now" "$N"

    # Monta o quadro inteiro e escreve de uma vez (cursor no topo, sem clear)
    out=$'\033[H'
    n=${#MON_L[@]}
    max=$(( MON_ROWS - 3 ))
    (( max < 1 )) && max=1
    for (( i = 0; i < n && i < max; i++ )); do
        out+="${MON_L[i]}"$'\033[K\n'
    done
    out+=$'\033[K\n'
    out+="$l"$'\033[K\033[J'
    printf '%s' "$out"
}

# Espera 2s, mas reage na hora a tecla 0 (ou fim da entrada)
mon_wait() {
    local key rc n

    for n in 1 2 3 4; do
        key=""
        read -rsn1 -t 0.5 key
        rc=$?
        if (( rc == 0 )); then
            if [[ "$key" == "0" ]]; then
                MON_STOP=1
                return 0
            fi
        elif (( rc <= 128 )); then
            MON_STOP=1
            return 0
        fi
        (( MON_STOP == 1 )) && return 0
    done
}

monitor() {
    MON_STOP=0
    MON_API=""
    MON_FAILS=0

    trap 'MON_STOP=1' INT
    printf '\033[?25l'

    clear
    echo -e "${C}Coletando informacoes...${N}"

    mon_static

    while (( MON_STOP == 0 )); do
        mon_collect_battery
        mon_collect_memory
        mon_collect_storage
        mon_collect_cpu
        mon_render
        (( MON_STOP == 1 )) && break
        mon_wait
    done

    # Descarta teclas que sobraram (ex.: Enter depois do 0)
    while read -rsn1 -t 0.01 _; do :; done

    printf '\033[?25h'
    trap - INT
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