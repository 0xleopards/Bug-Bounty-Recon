# Ultimate Bug Bounty Recon Automation

**Author:** 0xleopards  
**Year:** 2025

---

## Overview

This is a comprehensive Bash script for automated bug bounty reconnaissance workflows.  
It supports:

- Subdomain enumeration (single or multiple domains) using `subfinder`, `assetfinder`, and `amass`.  
- Live subdomain filtering with `httpx`.  
- URL and JavaScript file extraction using `gau`.  
- Endpoint extraction from JS files using `LinkFinder`.  
- Directory fuzzing using `ffuf`.  
- Colorful interactive CLI with banners and menus.

---

## Requirements

Make sure the following tools are installed and accessible in your `$PATH`:

- `subfinder`  
- `assetfinder`  
- `amass`  
- `httpx`  
- `gau`  
- `python3` (for LinkFinder)  
- `ffuf`

You also need the `linkfinder.py` script available in the same directory or in your `$PATH`.

---

## Usage

1. Clone or download the script `ultimate_recon.sh`.  
2. Make it executable:

    ```bash
    chmod +x ultimate_recon.sh
    ```

3. Run the script:

    ```bash
    ./ultimate_recon.sh
    ```

4. Follow the interactive prompts.

---

## Output Files

- `domains.txt` — Input domain(s)  
- `all-subs.txt` — Enumerated subdomains  
- `live-subs.txt` — Live subdomains  
- `all-urls.txt` — Extracted URLs  
- `all-js.txt` — JavaScript file URLs  
- `js-endpoints/` — Extracted JS endpoints  
- `paths.txt` — Wordlist for fuzzing  
- `fuzz-results/` — Directory fuzzing results  

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## Contact

Created by **0xleopards**  
Feel free to open issues or suggest features.
