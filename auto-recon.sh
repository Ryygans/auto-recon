#!/bin/bash
set -euo pipefail

red="\e[31m"
green="\e[32m"
cyan="\e[36m"
yellow="\e[33m"
nc="\e[0m"

clear
echo -e "${red}"
cat << "EOF"
 _______   ________   ______           ______   __    __  ________   ______
|       \ |        \ /      \         /      \ |  \  |  \|        \ /      \
| $$$$$$$\| $$$$$$$$|  $$$$$$\       |  $$$$$$\| $$  | $$ \$$$$$$$$|  $$$$$$\
| $$__| $$| $$__    | $$   \$$______ | $$__| $$| $$  | $$   | $$   | $$  | $$
| $$    $$| $$  \   | $$     |      \| $$    $$| $$  | $$   | $$   | $$  | $$
| $$$$$$$\| $$$$$   | $$   __ \$$$$$$| $$$$$$$$| $$  | $$   | $$   | $$  | $$
| $$  | $$| $$_____ | $$__/  \       | $$  | $$| $$__/ $$   | $$   | $$__/ $$
| $$  | $$| $$     \ \$$    $$       | $$  | $$ \$$    $$   | $$    \$$    $$
 \$$   \$$ \$$$$$$$$  \$$$$$$         \$$   \$$  \$$$$$$     \$$     \$$$$$$
EOF
echo -e "${nc}"
echo -e "${green}       Coded By : zoxxtzy${nc}"
echo -e "${yellow}      github   : https://github.com/RyyGans/${nc}"
echo -e "${green}       Auto Recon Tools${nc}"
echo -e "${cyan}       subfinder | httpx | gau | katana | nuclei${nc}"
echo "--------------------------------------------------------------------------"

# ===== TOOL CHECK =====
for tool in subfinder httpx gau katana nuclei; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        echo -e "${red}[!] $tool not found in PATH${nc}"
        exit 1
    fi
done

# ===== USER INPUT =====
printf "%b" "${red}Enter target domain (without http/https): ${nc}"
read -r url
printf "%b" "${yellow}Enter your folder name (for save your recon file): ${nc}"
read -r folder

# ===== VALIDATION =====
if [[ -z "$url" || -z "$folder" ]]; then
    echo -e "${red}[!] Input cannot be empty${nc}"
    exit 1
fi

if ! [[ "$url" =~ ^[a-zA-Z0-9.-]+$ ]]; then
    echo -e "${red}[!] Invalid domain format${nc}"
    exit 1
fi
folder=$(echo "$folder" | tr -cd 'a-zA-Z0-9_-')

OUTDIR="$folder-$url"
mkdir -p "$OUTDIR"
echo -e "${cyan}[+] Output directory: $OUTDIR${nc}"

# ===== SUBFINDER =====
echo -e "${green}[+] Running subfinder...${nc}"
subfinder -d "$url" -silent -o "$OUTDIR/subdomain.lst"

# ===== HTTPX =====
echo -e "${green}[+] Checking live domains (httpx)...${nc}"
httpx -l "$OUTDIR/subdomain.lst" -silent -o "$OUTDIR/live.lst"

# ===== GAU =====
echo -e "${green}[+] Collecting URLs from gau...${nc}"
gau < "$OUTDIR/live.lst" | sort -u > "$OUTDIR/gau.lst"

# ===== KATANA =====
echo -e "${green}[+] Crawling with katana...${nc}"
katana -list "$OUTDIR/live.lst" -silent -o "$OUTDIR/katana.lst"

# ===== MERGE URL =====
echo -e "${cyan}[+] Merging URLs...${nc}"
cat "$OUTDIR/gau.lst" "$OUTDIR/katana.lst" | sort -u > "$OUTDIR/urls.lst"

# ===== NUCLEI =====
echo -e "${green}[+] Running nuclei scan...${nc}"
nuclei -l "$OUTDIR/live.lst" -silent -o "$OUTDIR/nuclei.lst"

# ===== DONE =====
echo "--------------------------------------------------------------------------"
echo -e "${green}[✓] Auto Recon Finished${nc}"
echo -e "${cyan}[+] Results saved in: $OUTDIR${nc}"
