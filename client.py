#!/usr/bin/env python3

import re
from scapy.all import Ether, BitField, Packet, srp1, bind_layers

class MemoryHeader(Packet):
    name = "MemoryHeader"
    fields_desc = [BitField("write_enable", 0, 1),
                   BitField("address", 0, 32),
                   BitField("data", 0, 32),
                   BitField("padding", 0, 7)] 


bind_layers(Ether, MemoryHeader, type=0x1234)

class ParseError(Exception):
    pass

class Token:
    def __init__(self,type,value = None):
        self.type = type
        self.value = value

def parse_line(s):
    pattern = r"^\s*(0|1)\s+(-?\d{1,10})\s+(-?\d{1,10})\s*$"
    match = re.match(pattern, s)
    if match:
        return [Token('write_enable', match.group(1)), Token('addr', match.group(2)), Token('data', match.group(3))]
    else:
        raise ParseError('Expected "<write_enable> <addr> <data>"')

def main():
    
    iface = 'eth0'
    s = ''

    while True:
        s = input('> ')
        if s == "quit":
            break
        print(s)
        try:
            ts = parse_line(s)
            pkt = Ether(dst='00:04:00:00:00:00', type=0x1234) / MemoryHeader(
                                              write_enable=int(ts[0].value),
                                              address=int(ts[1].value),
                                              data=int(ts[2].value),
                                              padding=0x00) 
            
            response = srp1(pkt, iface=iface, timeout=1, verbose=False)
            if response:
                memory_header=response[MemoryHeader]
                if memory_header:
                    print(memory_header.write_enable)
                    print(memory_header.address)
                    print(memory_header.data)
                else:
                    print("Cannot find MemoryHeader in the packet")
            elif int(ts[0].value) != 1:
                print("Didn't receive response")
        except Exception as error:
            print(error)

if __name__ == '__main__':
    main()
