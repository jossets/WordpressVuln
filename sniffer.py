#!/usr/bin/python3

import sys
import pprint as pprint
from scapy.all import *

from curses.ascii import isprint

def printable(input):
    return ''.join(char for char in input if isprint(char))


# Function to handle each packet
def handle_packet(packet, log, nbbytes):
    # Check if the packet contains TCP layer
    if packet.haslayer(TCP):
        # Extract source and destination IP addresses
        src_ip = packet[IP].src
        dst_ip = packet[IP].dst
        # Extract source and destination ports
        src_port = packet[TCP].sport
        dst_port = packet[TCP].dport
         
        # Dont trace ssh
        if 22==src_port or 22==dst_port:
            return
        
        tcp_payload = packet[TCP].payload        
        tcp_len = (len(packet[TCP].payload))
        tcp_bytes = bytes(tcp_payload)[:nbbytes]
        tcp_utf8 = tcp_bytes.decode('UTF8','replace')
        #pprint.pprint(tcp_utf8)
        tcp_printable = printable("".join(tcp_utf8))
        print(f"TCP: {src_ip}:{src_port} -> {dst_ip}:{dst_port} {tcp_len} {tcp_printable}")
        log.write(f"TCP: {src_ip}:{src_port} -> {dst_ip}:{dst_port} {tcp_len} {tcp_printable}\n")
    
    
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
def main(interface, nbbytes):
    print("Sniffing: "+interface)
    # Create log file name based on interface
    logfile_name = f"sniffer_{interface}_log.txt"
    # Open log file for writing
    with open(logfile_name, 'w') as logfile:
        try:
            sniff(iface=interface, prn=lambda pkt: handle_packet(pkt, logfile, nbbytes), store=0)
        except KeyboardInterrupt:
            sys.exit(0)

# Check if the script is being run directly
if __name__ == "__main__":
    # Check if the correct number of arguments is provided
    print(sys.argv)
    if len(sys.argv) <2:
        print("Usage: "+sys.argv[0]+" <interface> <nb bytes dumped=80>")
        sys.exit(1)
    
    nbbytes=0
    if len(sys.argv) ==3:
        try:
            nbbytes=int(sys.argv[2])
        except:
            pass
    if 0==nbbytes:
        nbbytes=80

    main(sys.argv[1], nbbytes)