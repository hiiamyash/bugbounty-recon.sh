# bugbounty-recon.sh

Simple overview of use/purpose.

## Description

This script streamlines various recon tasks, including subdomain enumeration,
directory brute-forcing, URL probing, sensitive data scanning, and more. It 
leverages multiple tools to gather and analyze information about a target 
domain efficiently. Outputs are organized into a structured directory for 
easy analysis.

---

### Features

- Subdomain enumeration using Sublist3r and subfinder.
- HTTP probing with httpx for live domain verification.
- Directory brute-forcing with dirsearch, gobuster, and ffuf.
- Historical URL collection and live URL checking with waybackurls and httpx.
- Sensitive data and Git repository scans using truffleHog and gitrob.
- Bucket enumeration with bucket-stream.
- Pastebin monitoring with PasteHunter.
- Visual documentation using EyeWitness.
- Nmap scans for service and version detection.

## Getting Started

---

### Dependencies

- nmap
- whois
- nslookup
- waybackurls
- Sublist3r
- subfinder
- httpx
- altdns
- dirsearch
- gobuster
- ffuf
- feroxbuster
- bucket-stream
- gitrob
- truffleHog
- PasteHunter
- EyeWitness

---
### Installing
```
https://github.com/hiiamyash/bugbounty-recon.sh.git
```
### Executing program

```
chmod +x bugbounty-recon.sh
./bugbounty-recon.sh <domain>
```
