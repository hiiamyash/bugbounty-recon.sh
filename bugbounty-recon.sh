#!/bin/bash

# Check if required tools are installed
required_tools=("nmap" "whois" "nslookup" "waybackurls" "Sublist3r" "subfinder" "httpx" "altdns" "dirsearch" "gobuster" "ffuf" "feroxbuster" "bucket-stream" "gitrob" "truffleHog" "PasteHunter" "eyewitness")

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

# 1. Gather WHOIS information
echo "[+] Gathering WHOIS information..."
whois "$target" > "$output_dir/whois.txt"

# 2. DNS enumeration
echo "[+] Performing DNS enumeration..."
nslookup "$target" > "$output_dir/nslookup.txt"

# 3. Subdomain enumeration using Sublist3r and Subfinder
echo "[+] Enumerating subdomains..."
Sublist3r -d "$target" -o "$output_dir/subdomains_sublist3r.txt"
subfinder -d "$target" -o "$output_dir/subdomains_subfinder.txt"

# 4. Checking live hosts with httpx
echo "[+] Probing live subdomains..."
cat "$output_dir/subdomains_sublist3r.txt" "$output_dir/subdomains_subfinder.txt" | sort -u | httpx -silent > "$output_dir/alivedomains.txt"

# 5. Wayback Machine data collection
echo "[+] Fetching URLs from Wayback Machine..."
waybackurls "$target" > "$output_dir/wayback_urls.txt"

# 5.1 Check live URLs from Wayback Machine results
echo "[+] Checking live URLs from Wayback Machine data..."
cat "$output_dir/wayback_urls.txt" | httpx -silent > "$output_dir/alive_wayback_urls.txt"

# 6. Directory brute-forcing with dirsearch and gobuster
echo "[+] Running directory brute-forcing..."
dirsearch -u "$target" -e php,html,txt --simple-report="$output_dir/dirsearch_report.txt"
gobuster dir -u "$target" -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -o "$output_dir/gobuster_results.txt"

# 6.1 Fuzzing with ffuf
echo "[+] Running fuzzing with ffuf..."
ffuf -u "https://$target/FUZZ" -w /usr/share/wordlists/dirbuster/common.txt -o "$output_dir/ffuf_results.txt"

# 7. Alternative DNS resolution with altdns
echo "[+] Running alternative DNS enumeration..."
altdns -i "$output_dir/subdomains_sublist3r.txt" -o "$output_dir/altdns_output.txt" -w /usr/share/wordlists/dns.txt

# 8. Bucket hunting with bucket-stream
echo "[+] Searching for exposed buckets..."
bucket-stream -d "$target" > "$output_dir/bucket_stream.txt"

# 9. Code and sensitive data scanning with gitrob and truffleHog
echo "[+] Running Git repository scan..."
gitrob "$target" > "$output_dir/gitrob_results.txt"
truffleHog --regex --entropy=False --json "$target" > "$output_dir/trufflehog_results.txt"

# 10. Scanning pastes for sensitive information with PasteHunter
echo "[+] Scanning Pastebin for sensitive information..."
PasteHunter -d "$target" -o "$output_dir/pastehunter_results"

# 11. Eyewitness screenshots for alive subdomains
echo "[+] Capturing screenshots of live subdomains with EyeWitness..."
eyewitness --web -f "$output_dir/alivedomains.txt" -d "$output_dir/eyewitness"

# 12. Running nmap on live subdomains
echo "[+] Running nmap scans on live subdomains..."
while read -r subdomain; do
    nmap -sC -sV "$subdomain" -oN "$output_dir/nmap_$subdomain.txt"
done < "$output_dir/alivedomains.txt"

echo "Reconnaissance completed. Results saved in $output_dir."
