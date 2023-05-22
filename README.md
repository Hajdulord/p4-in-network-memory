# P4: In-Network Memory

## Introduction

The objective of this project is to implement an in-network memory management system using MININET/BMv2 environment and a Python test code as proof of concept to demonstrate that the P4 code works.

## Running the code

The directory with this README also contains a Makefile, JSON files for configuration, the P4 code, as well as the Python test code.

As a first step, compile the `inmemory.p4` and bring up a switch in Mininet to test its behavior.

1. In your shell, run:
   ```bash
   make
   ```
   This will:
   * compile `inmemory.p4`, and 

   * start a Mininet instance with one switch (`s1`) connected to two hosts (`h1`, `h2`) defined by the topology.json.
   * The hosts are assigned IPs of `10.0.1.1` and `10.0.1.2`.

2. We've written a simple Python test program that will allow to test out the functions of the switch. You can run the test program directly from the Mininet command prompt:

```
mininet> h1 python client.py
>
```

3. The test program will enter into a new prompt, into which you can type the input you want to send. There are two types of possible interactions: writing and reading. After that, the address of the registry must be passed, then the data to write to the registry. (You must pass a data file even in a read operation.) It will then parse your input and prepare a packet accordingly. This packet will then be sent to the switch for processing. When the switch returns the result of the reading, the test program will print the result.

```
> 1 12 123456
1 12 123456
> 0 12 0
0
12
123456
>
```

## Relevant Documentation

The documentation for P4_16 and P4Runtime is available [here](https://p4.org/specs/).

The documentation for Mininet is available [here](https://github.com/mininet/mininet/wiki/Documentation).

The documentation for BMv2 is available [here](http://bmv2.org/).

The documentation for Python is available [here](https://docs.python.org/3/).
