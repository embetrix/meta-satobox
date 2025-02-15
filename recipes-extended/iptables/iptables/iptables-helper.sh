#!/bin/sh
# Flush existing rules and reset counters
iptables -F
iptables -X
iptables -Z
iptables -t nat -F
iptables -t mangle -F

# Set default policies to DROP
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

# Allow all traffic on the loopback interface
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Allow established and related connections
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# --- Inbound Rules ---
# Allow new SSH connections (TCP port 22) with rate limiting:
iptables -A INPUT -p tcp --dport 22 \
         -m conntrack --ctstate NEW \
         -m limit --limit 3/min --limit-burst 5 \
         -j ACCEPT

# Allow inbound ping (ICMP echo-request) with rate limiting:
iptables -A INPUT -p icmp --icmp-type echo-request \
         -m limit --limit 1/second --limit-burst 5 \
         -j ACCEPT

# --- Outbound Rules ---
# Allow outbound SSH (TCP port 22)
iptables -A OUTPUT -p tcp --dport 22 -j ACCEPT

# Allow outbound NTP (UDP port 123)
iptables -A OUTPUT -p udp --dport 123 -j ACCEPT

# Allow DHCP (IPv4) client traffic:
# Outbound: from client port 68 to server port 67
iptables -A OUTPUT -p udp --sport 68 --dport 67 -j ACCEPT
# Inbound: DHCP replies from server port 67 to client port 68
iptables -A INPUT -p udp --sport 67 --dport 68 -j ACCEPT

# Allow Tor traffic: permit any outbound packets originating from the Tor process.
# (Adjust the username if your Tor runs under a different user)
iptables -A OUTPUT -m owner --uid-owner tor -j ACCEPT
