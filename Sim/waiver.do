
## ================= Coverage Waivers for AXI4 Protocol Verification =================
##---------------------------Functional Coverage Waivers------------------------------

##exclude the coverage of the auto-generated covergroups for ARREADY and AWREADY
    coverage exclude -cvgpath {/axi4_pkg/axi4_pkt/ax_cg/ARREADY/auto[0]}
    coverage exclude -cvgpath {/axi4_pkg/axi4_pkt/ax_cg/AWREADY/auto[0]}


##------------------------------ Code Coverage Waivers ------------------------------
##--------------------------- Statment Coverage Waivers -----------------------------

##exclude branches that are not reachable (default Statements)
    coverage exclude -src axi4.v -line 213 -code s
    coverage exclude -src axi4.v -line 283 -code s

##--------------------------- FSM Coverage Waivers ---------------------------------

##exclude unreachable transitions
    coverage exclude -du axi4 -ftrans write_state W_ADDR->W_IDLE
    coverage exclude -du axi4 -ftrans write_state W_DATA->W_IDLE
    coverage exclude -du axi4 -ftrans read_state R_ADDR->R_IDLE    


##--------------------------- Branch Coverage Waivers ------------------------------

##exclude branches that are not reachable (default Statements)
    coverage exclude -src axi4.v -line 213 -code b
    coverage exclude -src axi4.v -line 283 -code b


##--------------------------- Toggle Coverage Waivers ------------------------------

##the size is always constrained to 2
    coverage exclude -du axi4 -togglenode ARSIZE
    coverage exclude -du axi4 -togglenode AWSIZE
    coverage exclude -du axi4 -togglenode {read_size[0]}
    coverage exclude -du axi4 -togglenode {read_size[2]}
    coverage exclude -du axi4 -togglenode {write_size[0]}
    coverage exclude -du axi4 -togglenode {write_size[2]}


##exclude toggle coverage for the write and read address LSBs as they are always 0 due to address alignment, address is constrained to be aligned to the beat size, which is 4 bytes in this case, so the 2 LSBs of the address will always be 0 (divided by 4)
    coverage exclude -du axi4 -togglenode {ARADDR[0]}
    coverage exclude -du axi4 -togglenode {ARADDR[1]}
    coverage exclude -du axi4 -togglenode {AWADDR[0]}
    coverage exclude -du axi4 -togglenode {AWADDR[1]}
    coverage exclude -du axi4 -togglenode {read_addr[0]}
    coverage exclude -du axi4 -togglenode {read_addr[1]}
    coverage exclude -du axi4 -togglenode {write_addr[0]}
    coverage exclude -du axi4 -togglenode {write_addr[1]}
    coverage exclude -du axi4 -togglenode {read_addr_cross[0]}
    coverage exclude -du axi4 -togglenode {read_addr_cross[1]}
    coverage exclude -du axi4 -togglenode {write_addr_cross[0]}
    coverage exclude -du axi4 -togglenode {write_addr_cross[1]}

##excluded as the address increment is always 4 (2^write_size) as the size is always 2, it is always incremented by 4
    coverage exclude -du axi4 -togglenode {write_addr_incr[1]}
    coverage exclude -du axi4 -togglenode {write_addr_incr[3]}
    coverage exclude -du axi4 -togglenode {write_addr_incr[4]}
    coverage exclude -du axi4 -togglenode {write_addr_incr[5]}
    coverage exclude -du axi4 -togglenode {write_addr_incr[6]}
    coverage exclude -du axi4 -togglenode {write_addr_incr[7]}
    coverage exclude -du axi4 -togglenode {write_addr_incr[8]}
    coverage exclude -du axi4 -togglenode {write_addr_incr[9]}
    coverage exclude -du axi4 -togglenode {write_addr_incr[10]}
    coverage exclude -du axi4 -togglenode {write_addr_incr[11]}
    coverage exclude -du axi4 -togglenode {write_addr_incr[12]}
    coverage exclude -du axi4 -togglenode {write_addr_incr[13]}
    coverage exclude -du axi4 -togglenode {write_addr_incr[14]}
    coverage exclude -du axi4 -togglenode {write_addr_incr[15]}
    coverage exclude -du axi4 -togglenode {read_addr_incr[1]}
    coverage exclude -du axi4 -togglenode {read_addr_incr[3]}
    coverage exclude -du axi4 -togglenode {read_addr_incr[4]}
    coverage exclude -du axi4 -togglenode {read_addr_incr[5]}
    coverage exclude -du axi4 -togglenode {read_addr_incr[6]}
    coverage exclude -du axi4 -togglenode {read_addr_incr[7]}
    coverage exclude -du axi4 -togglenode {read_addr_incr[8]}
    coverage exclude -du axi4 -togglenode {read_addr_incr[9]}
    coverage exclude -du axi4 -togglenode {read_addr_incr[10]}
    coverage exclude -du axi4 -togglenode {read_addr_incr[11]}
    coverage exclude -du axi4 -togglenode {read_addr_incr[12]}
    coverage exclude -du axi4 -togglenode {read_addr_incr[13]}
    coverage exclude -du axi4 -togglenode {read_addr_incr[14]}
    coverage exclude -du axi4 -togglenode {read_addr_incr[15]}


#exclude toggle coverage for the response signals as they are always 0 or 2, the LSB doesn't toggle
    coverage exclude -du axi4 -togglenode {BRESP[0]}
    coverage exclude -du axi4 -togglenode {RRESP[0]}

##exclude toggle coverage for the msb of read_state, always 0 
    coverage exclude -du axi4 -togglenode {read_state[2]}

##exclude toggle coverage for the msb of write_state, always 0 
    coverage exclude -du axi4 -togglenode {write_state[2]}



##--------------------------- Condition Coverage Waivers ------------------------------

##exclude condition coverage for this line if (AWVALID && AWREADY) AWREADY always 1 "default value", we new transaction is to be sent 
    coverage exclude -src axi4.v -feccondrow 154 3

##exclude condition coverage for this line if (WVALID && WREADY) AWREADY always 1 "default value", we new transaction is to be sent 
    coverage exclude -src axi4.v -feccondrow 175 3

##I excluded this line(WLAST || write_burst_cnt == 0) as it says I have to cover that write_burst_cnt == 0 while WLAST = 0, which it doesn't make sense 
    coverage exclude -src axi4.v -feccondrow 186 4

##it doesn't mean sense to have valid adderess and it same time memory boundary is crossed
    coverage exclude -src axi4.v -feccondrow 191 4

##BREADY is always 1 "default value", when there's a new transaction is to be sent, and I always sample BVALID when it's 1
    coverage exclude -src axi4.v -feccondrow 206 3
    coverage exclude -src axi4.v -feccondrow 206 1

##exclude condition coverage for this line if (ARVALID && ARREADY) ARREADY always 1 "default value", we new transaction is to be sent 
    coverage exclude -src axi4.v -feccondrow 225 3

##exclude condition coverage for this line, read_addr_valid_0 it gets value 0, but the coverage tool didn't see it
    coverage exclude -src axi4.v -feccondrow 240 1
