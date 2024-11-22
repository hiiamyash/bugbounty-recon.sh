#!/bin/bash

# Check if required tools are installed
required_tools=("nmap" "whois" "nslookup" "waybackurls" "Sublist3r" "subfinder" "httpx" "altdns" "dirsearch" "gobuster" "ffuf" "feroxbuster" "bucket-stream" "gitrob" "truffleHog" "PasteHunter" "gowitness")

echo "Checking for required tools..."
for tool in "${required_tools[@]}"; do
    if ! command -v $tool &> /dev/null; then
        echo "$tool is not installed. Please install it before running the script."
        exit 1
    fi
done
echo "All required tools are installed."

# Read the target domain
read -p "Enter the target domain: " target
output_dir="recon_$target"
mkdir -p "$output_dir"

echo "Starting reconnaissance for $target..."

# WHOIS information
echo "[+] Gathering WHOIS information..."
whois "$target" > "$output_dir/whois.txt"

# DNS enumeration
echo "[+] Performing DNS enumeration..."
nslookup "$target" > "$output_dir/nslookup.txt"

# Subdomain enumeration
echo "[+] Enumerating subdomains..."
Sublist3r -d "$target" -o "$output_dir/subdomains_sublist3r.txt"
subfinder -d "$target" -o "$output_dir/subdomains_subfinder.txt"

# Checking live hosts
echo "[+] Probing live subdomains..."
cat "$output_dir/subdomains_sublist3r.txt" "$output_dir/subdomains_subfinder.txt" | sort -u | httpx -silent > "$output_dir/alivedomains.txt"

# Wayback Machine data collection
echo "[+] Fetching URLs from Wayback Machine..."
waybackurls "$target" > "$output_dir/wayback_urls.txt"

# Checking live URLs from Wayback Machine results
echo "[+] Checking live URLs from Wayback Machine data..."
cat "$output_dir/wayback_urls.txt" | httpx -silent > "$output_dir/alive_wayback_urls.txt"

# Directory brute-forcing
echo "[+] Running directory brute-forcing..."
dirsearch -u "$target" -e php,html,txt --simple-report="$output_dir/dirsearch_report.txt"
gobuster dir -u "$target" -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -o "$output_dir/gobuster_results.txt"

# Fuzzing with ffuf
echo "[+] Running fuzzing with ffuf..."
ffuf -u "https://$target/FUZZ" -w /usr/share/wordlists/dirbuster/common.txt -o "$output_dir/ffuf_results.txt"

# Alternative DNS resolution
echo "[+] Running alternative DNS enumeration..."
altdns -i "$output_dir/subdomains_sublist3r.txt" -o "$output_dir/altdns_output.txt" -w /usr/share/wordlists/dns.txt

# Bucket hunting
echo "[+] Searching for exposed buckets..."
bucket-stream -d "$target" > "$output_dir/bucket_stream.txt"

# Git repository scan
echo "[+] Running Git repository scan..."
gitrob "$target" > "$output_dir/gitrob_results.txt"
truffleHog --regex --entropy=False --json "$target" > "$output_dir/trufflehog_results.txt"

# Scanning pastes
echo "[+] Scanning Pastebin for sensitive information..."
PasteHunter -d "$target" -o "$output_dir/pastehunter_results"

# Screenshots of live subdomains
echo "[+] Capturing screenshots of live subdomains with GoWitness..."
gowitness file --source="$output_dir/alivedomains.txt" --destination="$output_dir/gowitness" --threads=10

# Running nmap on live subdomains
echo "[+] Running nmap scans on live subdomains..."
while read -r subdomain; do
    nmap -sC -sV "$subdomain" -oN "$output_dir/nmap_$subdomain.txt"
done < "$output_dir/alivedomains.txt"

echo "Reconnaissance completed. Results saved in $output_dir."

