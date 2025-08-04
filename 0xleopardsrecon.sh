#!/bin/bash

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

function banner() {
    clear
    echo -e "${CYAN}"
    echo "==========================================="
    echo "     🛡️  Ultimate Bug Bounty Recon 🛡️"
    echo "               by 0xleopards"
    echo "==========================================="
    echo -e "${NC}"
}

function pause(){
   read -p "Press [Enter] key to continue..."
}

banner

echo -e "${YELLOW}Select scan mode:${NC}"
echo "1) Scan ONE domain"
echo "2) Scan MULTIPLE domains"
echo -n -e "${GREEN}Choose option [1 or 2]: ${NC}"
read choice

if [[ "$choice" != "1" && "$choice" != "2" ]]; then
    echo -e "${RED}Invalid choice! Exiting.${NC}"
    exit 1
fi

if [[ "$choice" == "1" ]]; then
    echo -n -e "${CYAN}Enter domain (example.com): ${NC}"
    read domain
    echo $domain > domains.txt
else
    echo -n -e "${CYAN}Enter path to domain list file: ${NC}"
    read domain_file
    if [[ ! -f "$domain_file" ]]; then
        echo -e "${RED}File not found! Exiting.${NC}"
        exit 1
    fi
    cp "$domain_file" domains.txt
fi

banner
echo -e "${GREEN}Starting Subdomain Enumeration...${NC}"
> all-subs.txt

while read domain; do
    echo -e "${YELLOW}[*] Finding subdomains for ${domain}${NC}"
    subfinder -d $domain -silent >> all-subs.txt
    assetfinder --subs-only $domain >> all-subs.txt
    amass enum -passive -d $domain >> all-subs.txt
done < domains.txt

sort -u all-subs.txt -o all-subs.txt
echo -e "${GREEN}Subdomain enumeration done. Total: $(wc -l < all-subs.txt)${NC}"

pause
banner
echo -n -e "${CYAN}Do you want to check live subdomains? (y/n): ${NC}"
read livecheck

if [[ "$livecheck" == "y" || "$livecheck" == "Y" ]]; then
    echo -e "${GREEN}Checking live subdomains...${NC}"
    httpx -l all-subs.txt -silent -status-code -mc 200,403 | tee live-subs.txt
    echo -e "${GREEN}Live subdomains saved in live-subs.txt${NC}"
else
    cp all-subs.txt live-subs.txt
fi

pause
banner
echo -n -e "${CYAN}Do you want to extract URLs/JS files? (y/n): ${NC}"
read urlchoice

if [[ "$urlchoice" == "y" || "$urlchoice" == "Y" ]]; then
    echo -e "${GREEN}Extracting URLs using gau...${NC}"
    if [[ -s live-subs.txt ]]; then
        cat live-subs.txt | gau | sort -u > all-urls.txt
    else
        cat all-subs.txt | gau | sort -u > all-urls.txt
    fi
    echo -e "${GREEN}URLs saved in all-urls.txt${NC}"
    
    echo -e "${GREEN}Extracting JS files...${NC}"
    grep '\.js' all-urls.txt > all-js.txt
    echo -e "${GREEN}JS files saved in all-js.txt${NC}"

    pause
    banner
    echo -e "${GREEN}Starting LinkFinder JS endpoint extraction...${NC}"
    mkdir -p js-endpoints
    for url in $(cat all-js.txt); do
        fname=$(echo $url | sed 's/[^a-zA-Z0-9]/_/g')
        python3 linkfinder.py -i "$url" -o cli > js-endpoints/$fname.txt 2>/dev/null
        echo -e "${CYAN}Processed: $url${NC}"
    done

    echo -e "${GREEN}LinkFinder extraction done.${NC}"

    echo -e "${GREEN}Generating paths wordlist...${NC}"
    cat js-endpoints/*.txt | grep "/" | cut -d '"' -f2 | sort -u > paths.txt
    echo -e "${GREEN}Paths wordlist saved to paths.txt${NC}"

    pause
    banner
    echo -n -e "${CYAN}Do you want to fuzz directories with ffuf? (y/n): ${NC}"
    read fuzzchoice

    if [[ "$fuzzchoice" == "y" || "$fuzzchoice" == "Y" ]]; then
        echo -e "${GREEN}Starting directory fuzzing with ffuf...${NC}"
        mkdir -p fuzz-results
        while read sub; do
            domain_name=$(echo $sub | awk -F/ '{print $3}')
            ffuf -u "$sub/FUZZ" -w paths.txt -mc 200,403 -t 50 | tee fuzz-results/fuzz_$domain_name.txt
        done < live-subs.txt
        echo -e "${GREEN}Fuzzing complete. Results saved in fuzz-results/${NC}"
    fi

else
    echo -e "${YELLOW}Skipping URL and JS extraction steps.${NC}"
fi

banner
echo -e "${GREEN}🎉 All done! Check your results in the current folder.${NC}"
