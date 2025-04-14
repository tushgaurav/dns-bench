#!/bin/bash

# =========================================================
# dnsBench - Test and rank DNS servers by speed
# =========================================================

VERSION="0.1"

# Terminal colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# DNS test servers
declare -A DNS_SERVERS=(
  ["Cloudflare"]="1.1.1.1"
  ["Google"]="8.8.8.8"
  ["Quad9"]="9.9.9.9"
  ["OpenDNS"]="208.67.222.222"
  ["AdGuard"]="94.140.14.14"
  ["CleanBrowsing"]="185.228.168.168"
  ["Comodo"]="8.26.56.26"
  ["Level3"]="4.2.2.2"
  ["ControlD"]="76.76.2.0"
)

# Test domains - popular websites
TEST_DOMAINS=(
  "google.com"
  "facebook.com"
  "amazon.com"
  "youtube.com"
  "wikipedia.org"
  "reddit.com"
  "netflix.com"
  "github.com"
)

TESTS_PER_DOMAIN=3

# Results array
declare -A RESULTS

# Print header
print_header() {
  clear
  echo -e "${BOLD}${BLUE}"
  echo "
      ▌    ▄       ▌ 
     ▛▌▛▌▛▘▙▘█▌▛▌▛▘▛▌  github.com/tushgaurav/dns-bench
     ▙▌▌▌▄▌▙▘▙▖▌▌▙▖▌▌ Test and rank DNS servers by speed.         
  "
  echo "╔═══════════════════════════════════════════════════════════╗"
  echo "║                   Starting dnsBench v$VERSION                  ║"
  echo "╚═══════════════════════════════════════════════════════════╝"
  echo ""
  private_ip=$(get_private_ip)
  public_ip=$(get_public_ip)
  echo -e "${YELLOW}Your Private IP: ${BOLD}${private_ip}${NC}"
  echo -e "${YELLOW}Your Public IP:  ${BOLD}${public_ip}${NC}"
  echo ""
  echo -e "${YELLOW}Testing ${#DNS_SERVERS[@]} DNS servers with ${#TEST_DOMAINS[@]} domains...${NC}"
  echo ""
}

get_private_ip() {
    ip addr show | grep "inet " | grep -v "127.0.0.1" | awk '{print $2}' | cut -d"/" -f1 | head -n 1
}

get_public_ip() {
    curl -s https://api.ipify.org
}

get_dns_fact() {
    DNS_FACT_LAMBDA_URL="https://6ohig62uyt6bowmwojszlsyqey0ueaws.lambda-url.ap-south-1.on.aws/"
    curl -s $DNS_FACT_LAMBDA_URL
}

test_dns_server() {
  local dns_name=$1
  local dns_ip=$2
  local total_time=0
  local tests_count=0
  local failures=0

  echo -e "${BLUE}Testing ${BOLD}$dns_name${NC} ${BLUE}($dns_ip)...${NC}"
  
  for domain in "${TEST_DOMAINS[@]}"; do
    for ((i=1; i<=TESTS_PER_DOMAIN; i++)); do
      # Use dig to query the DNS server and measure time
      result=$(dig @$dns_ip $domain +stats 2>/dev/null)
      
      # Check if the query was successful
      if [ $? -eq 0 ] && [[ $result == *"ANSWER: 1"* ]]; then
        # Extract query time (in ms)
        query_time=$(echo "$result" | grep "Query time:" | awk '{print $4}')
        total_time=$((total_time + query_time))
        tests_count=$((tests_count + 1))
        echo -ne "\r${YELLOW}Progress: Testing $domain ($i/$TESTS_PER_DOMAIN) - ${query_time}ms${NC}     "
      else
        failures=$((failures + 1))
        echo -ne "\r${RED}Failed: $domain ($i/$TESTS_PER_DOMAIN)${NC}     "
      fi
      
      # Small delay between tests
      sleep 0.2
    done
  done
  
  echo -ne "\r${GREEN}Completed: Average response time: "
  
  # Calculate average if we have successful tests
  if [ $tests_count -gt 0 ]; then
    avg_time=$(echo "scale=2; $total_time / $tests_count" | bc)
    echo -e "${BOLD}${avg_time}ms${NC} (${tests_count} successful queries, ${failures} failures)${NC}"
    RESULTS["$dns_name"]=$avg_time
  else
    echo -e "${RED}Failed (all queries failed)${NC}"
    RESULTS["$dns_name"]=9999
  fi
}

# Function to display results
display_results() {
  echo ""
  echo -e "${BOLD}${BLUE}╔═══════════════════════════════════════════════════════════╗"
  echo -e "║                      RESULTS SUMMARY                      ║"
  echo -e "╚═══════════════════════════════════════════════════════════╝${NC}"
  echo ""
  echo -e "${BOLD}Rank  DNS Provider          IP Address         Avg Response${NC}"
  echo -e "${BOLD}----  -------------------  ----------------  -------------${NC}"
  
  # Sort results by speed (lowest first)
  rank=1
  while IFS= read -r line; do
    dns_name=$(echo "$line" | cut -d'|' -f1)
    avg_time=$(echo "$line" | cut -d'|' -f2)
    
    # Skip failed servers
    if [ "$avg_time" == "9999" ]; then
      continue
    fi
    
    dns_ip=${DNS_SERVERS["$dns_name"]}
    
    # Color coding for results
    if [ $rank -eq 1 ]; then
      color="${GREEN}"
    elif [ $rank -eq 2 ] || [ $rank -eq 3 ]; then
      color="${YELLOW}"
    else
      color="${NC}"
    fi
    
    printf "${color}%-5s %-20s %-17s %8.2fms${NC}\n" "$rank" "$dns_name" "$dns_ip" "$avg_time"
    rank=$((rank + 1))
  done < <(for k in "${!RESULTS[@]}"; do echo "$k|${RESULTS[$k]}"; done | sort -t'|' -k2,2n)
  
  echo ""
  echo -e "${BLUE}${BOLD}Recommendation:${NC} Use the fastest DNS server for better browsing experience."
  echo -e "${YELLOW}Note: Results may vary based on your location and network conditions.${NC}"
  dns_fact=$(get_dns_fact)
  echo -e "${YELLOW}${dns_fact}${NC}"
  echo ""
}

check_requirements() {
  if ! command -v dig &> /dev/null; then
    echo -e "${RED}Error: 'dig' command not found. Please install dnsutils or bind-utils.${NC}"
    echo "  For Debian/Ubuntu: sudo apt install dnsutils"
    echo "  For CentOS/RHEL: sudo yum install bind-utils"
    exit 1
  fi
  
  if ! command -v bc &> /dev/null; then
    echo -e "${RED}Error: 'bc' command not found. Please install bc.${NC}"
    echo "  For Debian/Ubuntu: sudo apt install bc"
    echo "  For CentOS/RHEL: sudo yum install bc"
    exit 1
  fi

  if ! command -v curl &> /dev/null; then
    echo -e "${RED}Error: 'curl' command not found. Please install curl.${NC}"
    echo "  For Debian/Ubuntu: sudo apt install curl"
    echo "  For CentOS/RHEL: sudo yum install curl"
    exit 1
  fi
}

main() {
  check_requirements
  print_header
  
  for dns_name in "${!DNS_SERVERS[@]}"; do
    test_dns_server "$dns_name" "${DNS_SERVERS[$dns_name]}"
  done
  
  display_results
}

main

exit 0