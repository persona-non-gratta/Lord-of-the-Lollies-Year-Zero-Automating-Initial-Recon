#!/bin/bash
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'
SILENT=false
valid_arg=false
run_timestamp=$(date +%Y%m%d_%H%M%S)

if [ "$1" = '-s' ] || [ "$1" = "--silent" ]; then
        SILENT=true
        shift
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ "$SILENT" = false ]; then
cat "$SCRIPT_DIR/logo/logo"
	echo   "LOL:YZ (Lord of the Lollies: Year Zero) - Rapid, Reproducible Reconnaissance."
        echo -e "Bear in mind: this tool doesn't provide any extra/unique ways of scanning!"
        echo   "Used Solutions: Nmap, Ffuf, Nikto. Used lists were taken from the Seclist... "
        echo -e "-------------------------------------------------------------------------------\n"
fi

# Proper IPv4 (with optional CIDR) validator: checks octet ranges, not just characters
is_valid_ip() {
        local ip="$1"
        if [[ "$ip" = "localhost" || "$ip" = "127.0.0.1" ]]; then
                return 0
        fi
        if [[ "$ip" =~ ^([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})(/([0-9]|[1-2][0-9]|3[0-2]))?$ ]]; then
                for octet in "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}" "${BASH_REMATCH[3]}" "${BASH_REMATCH[4]}"; do
                        if (( octet > 255 )); then
                                return 1
                        fi
                done
                return 0
        fi
        return 1
}

if [ $# -eq 0 ]; then
        while true; do
                deletion=$(tput cuu 8)
                echo -e "$RED[WARNING!]$NC Don't try to spam, tool is still afraid of any bugs :<"
                read -p "Enter target IP Address: " ip
                echo ""
                stty -echo

                if is_valid_ip "$ip"; then
                        valid_arg=true
                        stty echo
                        break
                else
                        valid_arg=false
                fi

                if [ "$valid_arg" = false ]; then
                        echo -e "$RED[ERROR]$NC Wrong Format! You have left the IP in the Secret (Expected: X.X.X.X)"
                        echo -e "Processing new IP-request... \n"
                        echo -e "-------------------------------------------------------------------------------\n"
                        stty -echo
                        sleep 1.0
                        echo -n "$deletion"; tput ed   # clear screen from the cursor position
                        stty echo
                fi
        done
else
        ip="$1"
        if ! is_valid_ip "$ip"; then
                echo -e "$RED[ERROR]$NC Wrong Format! Expected: $0 X.X.X.X"
                exit 1
        fi
fi

echo -e "-------------------------------------------------------------------------------"
echo -e "$GREEN[+]$NC DOMAIN && WORDLISTS INPUT PROCESS STARTED... "
baseline=$(openssl rand -hex 8)
read -rp "Submit the Domain's Name (DOMAIN, NOT ITS IP): " domain


function domain_handling {
    if [[ "$domain" != http://* && "$domain" != https://* ]]; then
        if curl -s -k -o /dev/null --max-time 5 "https://$domain"; then
            domain="https://$domain"
        else
            domain="http://$domain"
        fi
    fi

    clean_domain=$(echo "$domain" | sed -e 's|^[^/]*//||' -e 's|/.*||')

    #hosts_match=$(getent hosts "$clean_input" | awk '{print $2}')
    #clean_domain="${hosts_match:-$clean_input}"

    resp_size=$(curl -s -k "$domain" -H "Host: ${baseline}.${clean_domain}" | wc -c)

    read -erp "Submit the SUBDIRECTORIES wordlist's path: " subwordlist
    read -erp "Submit the DIRECTORIES wordlist's path: " dirwordlist
    subwordlist="${subwordlist/#\~/$HOME}"
    dirwordlist="${dirwordlist/#\~/$HOME}"

    if [[ ! -f "$subwordlist" ]]; then
        echo "$RED[ERROR]$NC Wordlist not found: $subwordlist" >&2
        echo -e "-------------------------------------------------------------------------------"
        exit 1
    elif [[ ! -f "$dirwordlist" ]]; then
        echo "$RED[ERROR]$NC Wordlist not found: $dirwordlist" >&2
        echo -e "-------------------------------------------------------------------------------"
        exit 1
    else
        echo -e "$GREEN[SUCCESS]$NC Wordlists validated, proceeding..."
        echo -e "-------------------------------------------------------------------------------"
    fi
}

function full_ffuf {

	ffuf -w "$subwordlist" -u "$domain" -H "Host: FUZZ.${clean_domain}" -fs "$resp_size" -k -o "subdirfuzzing_${clean_domain}_${run_timestamp}.json"
	ffuf -w "$dirwordlist" -u "$domain/FUZZ" -k -ac -o "dirfuzzing_${clean_domain}_${run_timestamp}.json"
        echo -e "-------------------------------------------------------------------------------"
	echo -e "$GREEN[SUCCESS]$NC FFUF scan complete. Output saved to subdirfuzzing_${clean_domain}.json && dirfuzzing_${clean_domain}.json"
        echo -e "-------------------------------------------------------------------------------"
}


function nmap_scan {
	read -rp "Submit Nmap Flags (leave blank for default (-sV -p- ): " flags_input
	read -rp "Enter Scripts args. (e.g mysql* / smb* / discovery / exploit): " script_args

	nmap_flags=( -sV -p-)

	if [[ -n "$flags_input" ]]; then
		read -ra extra_flags <<< "$flags_input"
		nmap_flags+=("${extra_flags[@]}")
	fi

	if [[ -n "$script_args" ]]; then
    	nmap_flags+=(--script "$script_args")
	fi

        echo -e "-------------------------------------------------------------------------------"
	sudo nmap "${nmap_flags[@]}" "$ip" -oN "nmap_${ip}_${run_timestamp}.txt" 2>error.log
        echo -e "-------------------------------------------------------------------------------"
	echo -e "$GREEN[SUCCESS]$NC Nmap scan complete. Output saved to nmap_${ip}_${run_timestamp}.txt"
        echo -e "-------------------------------------------------------------------------------"
}

function nikto_scan {
    read -rp "Submit Nikto Flags (leave blank for default -C all -ask no): " nikto_flags_input
        echo -e "-------------------------------------------------------------------------------"

    nikto_flags=(-C all -ask no)

    if [[ -n "$nikto_flags_input" ]]; then
        read -ra extra_nikto_flags <<< "$nikto_flags_input"
        nikto_flags+=("${extra_nikto_flags[@]}")
    fi

    sudo nikto -h "$domain" "${nikto_flags[@]}" -o "nikto_${ip}_${run_timestamp}" -Format xml 2>>error.log
        echo -e "-------------------------------------------------------------------------------"
    echo -e "$GREEN[SUCCESS]$NC Nikto scan complete. Output saved to nikto_${ip}_${run_timestamp}.xml"
        echo -e "------------------------------------------------------------------------------- "
}



echo -e "-------------------------------------------------------------------------------"
echo -e "$GREEN[+]$NC AVAILABLE SCAN SETTINGS (CHOOSE ONE):"
echo -e "\t1) Perform Full Enumeration (NMAP + FFUF (subdir && dir) + NIKTO)"
echo -e "\t2) Subdirectories && Directories Enumeration (FULL FFUF)"
echo -e "\t3) Advanced Scan - NMAP + NIKTO"
echo -e "\t*) Exit. \n"

read -p "Select scanning mode: " opt
echo -e "-------------------------------------------------------------------------------"
case $opt in
	"1") domain_handling; nmap_scan; full_ffuf; nikto_scan ;;
	"2") domain_handling; full_ffuf ;;
	"3") nmap_scan; nikto_scan ;;
	"*") exit 0 ;;
esac
echo "CONGRATULATIONS! And thank you for using my stuff.. :>"
