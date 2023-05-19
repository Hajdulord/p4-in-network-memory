#include <core.p4>
#include <v1model.p4>

#define MAX_ADDR 1024

// Header struct for incoming packets
header ethernetHeader {
    bit<48> dstAddr;
    bit<48> srcAddr;
    bit<16> etherType;
}

// the custom layer type for memory header
const bit<16> MEMORY_ETYPE = 0x1234;

header memoryHeader {
    bit<1>  isWrite; // 1 for write, 0 for read
    bit<32> address; // address of the registry
    bit<32> data; // data to save
    bit<7> padding; // padding to make the header a multiple of 8
}

struct headers {
    ethernetHeader ethernet;
    memoryHeader  memory;
}

struct metadata {
    /* In our case it is empty */
}

// Register array
register<bit<32>>(MAX_ADDR) memory;

parser MyParser(packet_in packet, 
                out headers hdr,
                inout metadata meta,
                inout standard_metadata_t standard_metadata) {
    state start {
        packet.extract(hdr.ethernet);
        transition select(hdr.ethernet.etherType) {
            MEMORY_ETYPE: parse_memory;
            default: accept;
        }
    }

    state parse_memory {
        packet.extract(hdr.memory);
        transition accept;
    }
}

control MyVerifyChecksum(inout headers hdr,
                         inout metadata meta) {
    apply { }
}

control MyIngress(inout headers hdr, 
                  inout metadata meta,
                  inout standard_metadata_t standard_metadata) {
    apply {
        if (hdr.memory.isWrite == 1) {
            memory.write(hdr.memory.address, hdr.memory.data);
        } else {
            bit<32> read_data;
            memory.read(read_data, hdr.memory.address);
            hdr.memory.data = read_data;

            standard_metadata.egress_spec = standard_metadata.ingress_port;
        }
    }
}

control MyEgress(inout headers hdr,
                 inout metadata meta,
                 inout standard_metadata_t standard_metadata) {
    apply { }
}

control MyComputeChecksum(inout headers hdr, inout metadata meta) {
    apply { }
}


control MyDeparser(packet_out packet, in headers hdr) {
    apply {
        packet.emit(hdr.ethernet);
        packet.emit(hdr.memory);
    }
}



V1Switch(
MyParser(), 
MyVerifyChecksum(),
MyIngress(), 
MyEgress(),
MyComputeChecksum(),
MyDeparser()
) main;
