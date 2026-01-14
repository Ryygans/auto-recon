#!/bin/bash

# ===== COLOR =====
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
CYAN="\e[36m"
NC="\e[0m"

if [[$EUID -ne 0]]; then
    echo "please run this script as a root (sudo)."
    exit
fi
clear
echo -e "${CYAN}[+] Starting Install Auto-Recon Tools...${NC}"
echo "----------------------------------------------"

# ===== UPDATE & DEPENDENCY =====
echo -e "${GREEN}[+] Updating system...${NC}"
apt update -y && apt upgrade -y
echo -e "${GREEN}[+] Installing dependencies (git, golang)...${NC}"
apt install -y git golang
# Activating tools
export PATH="$PATH:$HOME/go/bin"

# ===== INSTALL TOOLS =====
echo -e "${YELLOW}[+] Installing subfinder...${NC}"
go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
echo -e "${YELLOW}[+] Installing httpx...${NC}"
go install github.com/projectdiscovery/httpx/cmd/httpx@latest
echo -e "${YELLOW}[+] Installing gau...${NC}"
go install github.com/lc/gau/v2/cmd/gau@latest
echo -e "${YELLOW}[+] Installing katana...${NC}"
go install github.com/projectdiscovery/katana/cmd/katana@latest
echo -e "${YELLOW}[+] Installing nuclei...${NC}"
go install github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest

# ===== PATH SETUP =====
if ! grep -q 'go/bin' ~/.bashrc; then
    echo 'export PATH="$PATH:$HOME/go/bin"' >> ~/.bashrc
fi

# ===== NUCLEI TEMPLATE =====
echo -e "${GREEN}[+] Updating nuclei templates...${NC}"
nuclei -update-templates

# ===== VERIFY =====
echo "----------------------------------------------"
echo -e "${GREEN}[✓] Installation completed!${NC}"
echo -e "${CYAN}Installed tools:${NC}"

subfinder -version 2>/dev/null && echo -e "${GREEN}✔ subfinder${NC}"
httpx -version 2>/dev/null && echo -e "${GREEN}✔ httpx${NC}"
gau --version 2>/dev/null && echo -e "${GREEN}✔ gau${NC}"
katana -version 2>/dev/null && echo -e "${GREEN}✔ katana${NC}"
nuclei -version 2>/dev/null && echo -e "${GREEN}✔ nuclei${NC}"

echo "----------------------------------------------"
echo -e "${GREEN}All tools are ready to use 🚀${NC}"
