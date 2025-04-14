export const handler = async (event) => {
  const dnsFacts = [
    "DNS was created in 1983 by Paul Mockapetris at USC to solve the problem of manually maintaining HOSTS.txt files.",
    "The first DNS name server, JEEVES, was created in 1984 at the University of Wisconsin.",
    "Before DNS, people had to memorize IP addresses or consult a central HOSTS.txt file that mapped names to addresses.",
    "DNS queries can be either recursive or iterative, affecting how name resolution is performed.",
    "The maximum length of a domain name is 253 characters, including dots.",
    "A single DNS label (part between dots) cannot exceed 63 characters.",
    "DNS uses port 53 by default for both UDP and TCP communications.",
    "DNS primarily uses UDP for queries because it's faster, but switches to TCP when responses exceed 512 bytes.",
    "The DNS hierarchy is structured like an inverted tree, with the root zone at the top.",
    "DNS records have a TTL (Time To Live) value that determines how long they can be cached.",
    "Google's public DNS (8.8.8.8) handles over 1 trillion queries per day.",
    "DNSSEC (DNS Security Extensions) was introduced in 1997 to add security to DNS.",
    "The first domain name ever registered was Symbolics.com on March 15, 1985.",
    "There are 13 root name servers in the world, labeled A through M.",
    "DNS resolution typically takes between 20-120 milliseconds in optimal conditions.",
    "The DNS system processes billions of queries every day globally.",
    "Cloudflare's 1.1.1.1 DNS service was launched on April 1, 2018 (not an April Fools' joke!).",
    "The most common DNS attack is DNS cache poisoning, first identified in 1990.",
    "Over 370 million domain names were registered across all top-level domains by Q3 2020.",
    "A single DNS query can trigger multiple additional queries behind the scenes.",
    "DNS over HTTPS (DoH) was standardized in RFC 8484 in October 2018.",
    "The concept of Round-Robin DNS for load balancing was introduced in the late 1980s.",
    "The DNS root zone was originally managed by one person, Jon Postel, until 1998.",
    "ICANN was formed in 1998 to oversee the DNS root zone and domain name system.",
    "The DNS protocol specifications are defined in RFC 1034 and RFC 1035.",
    "The average DNS query generates about 100 bytes of traffic.",
    "The first country code top-level domain (ccTLD) was .us, created in 1985.",
    "DNS pinning is a security feature in browsers to prevent DNS rebinding attacks.",
    "The longest possible DNS name can contain up to 127 levels.",
    "Unicode domain names must be converted to Punycode for DNS to process them.",
    "The DNS system is often called the 'phone book of the Internet.'",
    "DNS servers can handle both forward (name to IP) and reverse (IP to name) lookups.",
    "The DNS protocol was designed to be extensible, allowing new record types to be added.",
    "Many ISPs perform DNS hijacking to display custom error pages or advertisements.",
    "Private DNS zones allow organizations to use custom domain names internally.",
    "DNS amplification attacks can multiply traffic by up to 54 times its original size.",
    "The .com TLD has over 150 million registered domains as of 2021.",
    "DNS was designed to be a distributed system to avoid single points of failure.",
    "Some DNS providers offer analytics about query patterns and performance.",
    "Modern DNS implementations support EDNS (Extension Mechanisms for DNS).",
  ];

  const randomFact = dnsFacts[Math.floor(Math.random() * dnsFacts.length)];

  const response = {
    statusCode: 200,
    headers: {
      "Access-Control-Allow-Origin": "*", // Enable CORS
      "Content-Type": "text",
    },
    body: randomFact,
  };

  return response;
};
