#!/bin/sh
# Flush existing IPv6 rules
ip6tables -F
ip6tables -X
ip6tables -Z

# Set default policies to DROP
ip6tables -P INPUT DROP
ip6tables -P OUTPUT DROP
ip6tables -P FORWARD DROP

# Allow all traffic on the loopback interface
ip6tables -A INPUT -i lo -j ACCEPT
ip6tables -A OUTPUT -o lo -j ACCEPT

# Drop invalid packets early
ip6tables -A INPUT -m conntrack --ctstate INVALID -j DROP
ip6tables -A OUTPUT -m conntrack --ctstate INVALID -j DROP

# Allow established and related connections
ip6tables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
ip6tables -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# --- Inbound Rules ---
# Allow new SSH connections (TCP port 22) with rate limiting:
ip6tables -A INPUT -p tcp --dport 22 \
         -m conntrack --ctstate NEW \
         -m limit --limit 3/min --limit-burst 5 \
         -j ACCEPT

# Allow inbound HTTPS (TCP port 443) from local IPv6 scopes only
ip6tables -A INPUT -p tcp -s fc00::/7 --dport 443 \
         -m connlimit --connlimit-above 30 \
         -j DROP
ip6tables -A INPUT -p tcp -s fe80::/10 --dport 443 \
         -m connlimit --connlimit-above 30 \
         -j DROP

ip6tables -A INPUT -p tcp -s fc00::/7 --dport 443 \
         -m conntrack --ctstate NEW \
         -m limit --limit 25/min --limit-burst 50 \
         -j ACCEPT
ip6tables -A INPUT -p tcp -s fe80::/10 --dport 443 \
         -m conntrack --ctstate NEW \
         -m limit --limit 25/min --limit-burst 50 \
         -j ACCEPT

# Allow inbound ping (ICMPv6 echo-request) with rate limiting:
ip6tables -A INPUT -p ipv6-icmp --icmpv6-type echo-request \
         -m limit --limit 1/second --limit-burst 5 \
         -j ACCEPT

# --- Outbound Rules ---
# Allow outbound ping (ICMPv6 echo-request)  <-- this was missing
ip6tables -A OUTPUT -p ipv6-icmp --icmpv6-type echo-request -j ACCEPT

# Allow outbound HTTPS (TCP port 443)
ip6tables -A OUTPUT -p tcp --dport 443 -j ACCEPT

# Allow outbound NTP (UDP port 123)
ip6tables -A OUTPUT -p udp --dport 123 -j ACCEPT

# Allow outbound DNS (UDP and TCP port 53)
ip6tables -A OUTPUT -p udp --dport 53 -j ACCEPT
ip6tables -A OUTPUT -p tcp --dport 53 -j ACCEPT

# Allow DHCPv6 client traffic (if applicable):
# Outbound: from client port 546 to server port 547
ip6tables -A OUTPUT -p udp --sport 546 --dport 547 -j ACCEPT
# Inbound: DHCPv6 replies from server port 547 to client port 546
ip6tables -A INPUT -p udp --sport 547 --dport 546 -j ACCEPT

# Allow Tor traffic: permit any outbound packets originating from the Tor process.
# (Adjust the username if your Tor runs under a different user)
ip6tables -A OUTPUT -m owner --uid-owner tor -j ACCEPT
