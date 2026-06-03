# AXI4_SV_Verification
## Overview

The project implements a complete SystemVerilog testbench environment to verify the AXI4 design with 
the integrated memory. This environment should serve as a practical application of Coverage-Driven 
Verification (CDV) principles using key features of SystemVerilog.

The environment verifies:

- Write Single Beat transactions
- Read Single Beat transactions
- Burst transfers (Write/Read)
- Reset functionality
- Address channel operation
- Data channel operation
- Response channel operation

## Verification Components
- SystemVerilog Classes: 

  o To encapsulate transaction-level representations (e.g., axi4_packet). 

  o Stimulus generation, drivers, and checkers in tasks to be called during simulation.
  
- Constrained Randomization: 

  o Randomized AXI signals (AWADDR, ARLEN, WDATA, etc.) under valid protocol rules 

  o Applied constraints to avoid illegal scenarios and explore corner cases. 

- Interfaces: 

  o Defined clean and reusable interfaces for the AXI4 protocol. 

  o Use modports to manage signal direction and access in various components. (Design is written in Verilog, so I just manually connect the signals of the interface to those of the DUT)
  
- Functional Coverage: 

  o Covered all important protocol features: burst lengths, data sizes, address regions, and write/read behaviors. 

  o Used covergroups and coverpoints properly with bins for meaningful measurement.
  
- Assertion-Based Checks (CRT): 

  o Used concurrent assertions (SystemVerilog Assertions) to monitor protocol rules and handshake behavior.

## Test Cases

1. Reset Test [AXI_RESET]
2. Write Only Test [AXI_B2B_WRITE_SINGLE_BEAT]
3. Read Only Test [AXI_B2B_READ_SINGLE_BEAT]
4. Write Bursts Test [AXI_BURST_WRITE]
5. Read Burst Test [AXI_BURST_READ]
6. Write outside the memory boundary Test [AXI_ERR_INJECTRION_WRITE]
7. Read outside the memory boundary Test [AXI_ERR_INJECTION_READ]
8. Write in corner case "boundary edges" [AXI_MAX_MIN_ADDR_WRITE]
9. Read in corner case "boundary edges" [AXI_MAX_MIN_ADDR_WRITE]
10. Random Traffic Test [RANDOM test]

## Coverage Results

Functional Coverage: *100%* with exclusion the coverage of the auto-generated coverpoints due to a cross for ARREADY and AWREADY, I always sample when AWREADY/ARREADY is only high

Code Coverage:
- Statement  :  **100%** "with exclusion of Statements that are not reachable (default Statements)."
- Branch     :  **100%** "with exclusion of Branches that are not reachable (default Branches)."
- FSM        :  **100%** "with exclusion of unreachable transitions."
- Expression :  **100%** "no exclusions."
- for toggle and condition coverage, there are more detailed exclusion explanations in the waiver.do file

## Tools

- SystemVerilog
- QuestaSim

## Future Work
Building a full UVM environment while practicing one of the advanced and important topics, "Reactive agent". 
## Directory Structure

```text
AXI4_Verification_SystemVerilog
│
├── RTL/
│   ├── axi4.v
│   └── axi_memory.v
│
├── TB/
│   ├── axi_if.sv
│   ├── axi_TE.sv
│   ├── axi4_packet.sv
│   ├── axi_sva.sv
│   └── axi_top.sv
│
├── Sim/
│   ├── axi_do.do
│   ├── wave.do
│   ├── waiver.do
│   └── file.list
│
├── Coverage/
│   ├── coverage_report.txt
│   ├── index.html
│   ├── covSummary.html
│   ├── dulist.html
│   ├── index.html
│   ├── menu.html
│   └── coverage.ucdb
│
└── README.md
```
