#!/usr/bin/python3

import sys
import pprint
from scapy.all import *

from curses.ascii import isprint

def printable(input):
    return ''.join(char for char in input if isprint(char))


# Function to handle each packet
def handle_packet(packet, log):
    # Check if the packet contains TCP layer
    if packet.haslayer(TCP):
        # Extract source and destination IP addresses
        src_ip = packet[IP].src
        dst_ip = packet[IP].dst
        # Extract source and destination ports
        src_port = packet[TCP].sport
        dst_port = packet[TCP].dport
        
        tcp_payload = packet[TCP].payload        
        tcp_len = (len(packet[TCP].payload))
        tcp_bytes = bytes(tcp_payload)[:80]
        tcp_utf8 = tcp_bytes.decode('UTF8','replace')
        #pprint.pprint(tcp_utf8)
        tcp_printable = printable("".join(tcp_utf8))
        print(f"TCP: {src_ip}:{src_port} -> {dst_ip}:{dst_port} {tcp_len} {tcp_printable}")
    
    
    if packet.haslayer(DNS):
        src_ip = packet[IP].src
        dst_ip = packet[IP].dst
        #pprint.pprint(packet[DNS])
        dns_name=""
        if packet.qdcount > 0 and isinstance(packet.qd, DNSQR):
            dns_name = packet.qd.qname
            print(f"DNS QR: {src_ip} -> {dst_ip} {dns_name}")
        elif packet.ancount > 0 and isinstance(packet.an, DNSRR):
            dns_name = packet.an.rdata
            print(f"DNS RR: {src_ip} -> {dst_ip} {dns_name}")
        else:
            print(f"DNS: {src_ip} -> {dst_ip}")


# Main function to start packet sniffing
def main(interface, verbose=False):
    print("Sniffing: "+interface)
    # Create log file name based on interface
    logfile_name = f"sniffer_{interface}_log.txt"
    # Open log file for writing
    with open(logfile_name, 'w') as logfile:
        try:
            # Start packet sniffing on specified interface with verbose output
            if verbose:
                sniff(iface=interface, prn=lambda pkt: handle_packet(pkt, logfile), store=0, verbose=verbose)
            else:
                sniff(iface=interface, prn=lambda pkt: handle_packet(pkt, logfile), store=0)
        except KeyboardInterrupt:
            sys.exit(0)

# Check if the script is being run directly
if __name__ == "__main__":
    # Check if the correct number of arguments is provided
    print(sys.argv)
    if len(sys.argv) < 2 or len(sys.argv) > 3:
        print("Usage: ./sniffer.py <interface>")
        sys.exit(1)
    
    main(sys.argv[1])