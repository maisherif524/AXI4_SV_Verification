module axi4_sva(axi_if.MON axiif);

logic out_range;

always_comb begin
    out_range =
        ((((axiif.AWLEN + 1) * (2**axiif.AWSIZE)) - 1) + axiif.AWADDR > 4095)
     || ((((axiif.ARLEN + 1) * (2**axiif.ARSIZE)) - 1) + axiif.ARADDR > 4095);
end
// ---------------- RESET ASSERTIONS ----------------
always_comb begin
    if(!axiif.ARESETn) begin
        //output signals of the write address subchannel
        assert final (axiif.AWREADY == 1)       else $error("AWREADY should be high when ARESETn is low")   ;
        cover  final (axiif.AWREADY == 1)                                                                   ;
        
        //output signals of the write data subchannel
        assert final (axiif.WREADY  == 0)       else $error("WREADY should be low when ARESETn is low")     ;
        cover  final (axiif.WREADY  == 0)                                                                   ;
        
        //output signals of the write response subchannel
        assert final (axiif.BRESP   == 2'b00)   else $error("BRESP should be OKAY when ARESETn is low")     ;
        cover  final (axiif.BRESP   == 2'b00)                                                               ;
        
        assert final (axiif.BVALID  == 0)       else $error("BVALID should be low when ARESETn is low")     ;
        cover  final (axiif.BVALID  == 0)                                                                   ;
       
        //output signals of the read address subchannel
        assert final (axiif.ARREADY == 1)       else $error("ARREADY should be high when ARESETn is low")   ;
        cover  final (axiif.ARREADY == 1)                                                                   ;

        //output signals read data subchannel
        assert final (axiif.RDATA   == 0)       else $error("RDATA should be zero when ARESETn is low")     ;
        cover  final (axiif.RDATA   == 0)                                                                   ; 

        assert final (axiif.RRESP   == 2'b00)   else $error("RRESP should be OKAY when ARESETn is low")     ; 
        cover  final (axiif.RRESP   == 2'b00)                                                               ;

        assert final (axiif.RLAST   == 0)       else $error("RLAST should be low when ARESETn is low")      ;
        cover  final (axiif.RLAST   == 0)                                                                   ;
        
        assert final (axiif.RVALID  == 0)       else $error("RVALID should be low when ARESETn is low")     ;
        cover  final (axiif.RVALID  == 0)                                                                   ;
    end

end

// ---------------- WRITE ADDRESS SUBCHANNEL PROPERTIES ----------------

//when AWVALID is high, AWREADY should be high within same cycle or eventually will be high within time window
property start_of_write_address_handshake;
    @(posedge axiif.ACLK) disable iff(!axiif.ARESETn) $rose(axiif.AWVALID) |-> ##[0:1] axiif.AWREADY; //note AWREADY is by default high in this design  "READY BEFORE VALID" but i want to make sure that if AWVALID goes high, AWREADY should handshake 
endproperty

//when AWVALID and AWREADY are high, next cycles AWVALID and AWREADY should be low
property AWVALID_AWREADY_handshake_assertion;
    @(posedge axiif.ACLK) disable iff(!axiif.ARESETn) (axiif.AWVALID && axiif.AWREADY) |-> ##1 (!axiif.AWVALID && !axiif.AWREADY);
endproperty

property Rose_of_WREADY_after_AWVALID;
    @(posedge axiif.ACLK) disable iff(!axiif.ARESETn)  $fell(axiif.AWVALID) && $fell(axiif.AWREADY) |-> ##1 $rose(axiif.WREADY);
endproperty 

//when AWVALID and AWREADY are high, next cycles AWLEN, AWSIZE, AWADDR should hold their values 
property BUS_STABLE_during_write;
    @(posedge axiif.ACLK) disable iff(!axiif.ARESETn) (axiif.AWVALID && axiif.AWREADY) |=> ##1 $stable({axiif.AWADDR, axiif.AWLEN, axiif.AWSIZE});
endproperty


// ---------------- WRITE DATA SUBCHANNEL PROPERTIES  ----------------
//when WVALID is high, WREADY should be high within same cycle or eventually will be high within time window
property write_data_handshake;
    @(posedge axiif.ACLK) disable iff(!axiif.ARESETn) $rose(axiif.WREADY) |-> ##[0:2] $rose(axiif.WVALID); //note WREADY is by default high in this design  "READY BEFORE VALID" but i want to make sure that if WVALID goes high, WREADY should handshake
endproperty

property wlast_assertion;
    @(posedge axiif.ACLK) disable iff(!axiif.ARESETn) (axiif.WVALID && axiif.WREADY && $rose(axiif.WLAST)) |-> ##1 ($fell(axiif.WVALID) && $fell(axiif.WREADY) && $fell(axiif.WLAST));
endproperty 

// ---------------- WRITE RESP SUBCHANNEL PROPERTIES  ----------------

sequence end_of_write_response; 
 $rose(axiif.BVALID) ##[1:$] ($fell(axiif.BVALID)) ##[0:$] ($fell(axiif.BREADY));
endsequence

property BVALID_assertion;
    @(posedge axiif.ACLK) disable iff(!axiif.ARESETn) ((axiif.WREADY) && $rose(axiif.WLAST)) |=> end_of_write_response;
endproperty

property new_transaction_after_write_response;
    @(posedge axiif.ACLK) disable iff(!axiif.ARESETn) $fell(axiif.BVALID) |-> ##1 (axiif.AWREADY);
endproperty

property BRESP_assertion;
    @(posedge axiif.ACLK) disable iff(!axiif.ARESETn) $fell(axiif.WLAST) && (!out_range) |-> (axiif.BRESP == 2'b00) and (axiif.BVALID); //assuming the design should return OKAY response for all transactions
endproperty

// ---------------- READ ADDRESS SUBCHANNEL PROPERTIES ----------------

//when ARVALID is high, ARREADY should be high within same cycle or eventually will be high within time window
property start_of_read_handshake;
    @(posedge axiif.ACLK) disable iff(!axiif.ARESETn) $rose(axiif.ARVALID) |-> ##[0:1] axiif.ARREADY; //note ARREADY is by default high in this design  "READY BEFORE VALID" but i want to make sure that if ARVALID goes high, ARREADY should handshake 
endproperty

//when ARVALID and ARREADY are high, next cycles ARVALID and ARREADY should be low
property ARVALID_ARREADY_handshake_assertion;
    @(posedge axiif.ACLK) disable iff(!axiif.ARESETn) (axiif.ARVALID && axiif.ARREADY) |-> ##1 (!axiif.ARVALID && !axiif.ARREADY);
endproperty

//when ARVALID and ARREADY are high, next cycles ARADDR, ARLEN, ARSIZE should hold their values 
property BUS_STABLE_during_read;
    @(posedge axiif.ACLK) disable iff(!axiif.ARESETn) (axiif.ARVALID && axiif.ARREADY) |=> ##1 $stable({axiif.ARADDR, axiif.ARLEN, axiif.ARSIZE});
endproperty


// ---------------- READ DATA SUBCHANNEL PROPERTIES  ----------------
//when RVALID is high, RREADY should be high within same cycle or eventually will be high within time window
property read_data_handshake;
    @(posedge axiif.ACLK) disable iff(!axiif.ARESETn) (axiif.RVALID) && (axiif.RREADY) |-> ##1 $fell(axiif.RVALID); 
endproperty

property rlast_assertion;
    @(posedge axiif.ACLK) disable iff(!axiif.ARESETn) (axiif.RVALID && axiif.RREADY && (axiif.RLAST)) |-> ##1 ($fell(axiif.RVALID) && $fell(axiif.RREADY) && $fell(axiif.RLAST));
endproperty 

property RRESP_assertion;
    @(posedge axiif.ACLK) disable iff(!axiif.ARESETn) (axiif.RLAST) && (!out_range) |-> (axiif.RRESP == 2'b00) and (axiif.RVALID); 
endproperty



// ---------------- WRITE DATA SUBCHANNEL ASSERTION PROPERTIES  ----------------
assert property (start_of_write_address_handshake)            else $error("AWREADY should be high within 2 cycles after AWVALID goes high")                                     ;
assert property (AWVALID_AWREADY_handshake_assertion)         else $error("AWVALID and AWREADY should handshake for one cycle")                                                 ;
assert property (BUS_STABLE_during_write)                     else $error("AWADDR, AWLEN, AWSIZE should hold their values during the write handshake")                          ;   
assert property (Rose_of_WREADY_after_AWVALID)                else $error("WREADY should be high within 2 cycles after AWVALID goes high")                                      ;

// ---------------- WRITE DATA SUBCHANNEL ASSERTION PROPERTIES  ----------------
assert property (write_data_handshake)                        else $error("WREADY should be high within 2 cycles after WVALID goes high")                                       ;
assert property (wlast_assertion)                             else $error("WLAST should be deassert after the last beat of the burst transaction")                              ;

// ---------------- WRITE RESP SUBCHANNEL ASSERTION PROPERTIES  ----------------
assert property (BVALID_assertion)                            else $error("BVALID should be asserted after the last beat of the burst transaction")                             ;    
assert property (new_transaction_after_write_response)        else $error("A new transaction should start after the write response of the previous transaction")                ;
assert property (BRESP_assertion)                             else $error("BRESP should be OKAY for all transactions")                                                          ;

// ---------------- READ ADDRESS SUBCHANNEL ASSERTION PROPERTIES ----------------
assert property (start_of_read_handshake)                     else $error("ARREADY should be high within 2 cycles after ARVALID goes high")                                     ;
assert property (ARVALID_ARREADY_handshake_assertion)         else $error("ARVALID and ARREADY should handshake for one cycle")                                                 ;
assert property (BUS_STABLE_during_read)                      else $error("ARADDR, ARLEN, ARSIZE should hold their values during the read handshake")                           ;

// ---------------- READ DATA SUBCHANNEL ASSERTION PROPERTIES  ----------------
assert property (read_data_handshake)                         else $error("RREADY should be high within 2 cycles after RVALID goes high")                                       ;
assert property (rlast_assertion)                             else $error("RLAST should be deassert after the last beat of the burst transaction")                              ;
assert property (RRESP_assertion)                             else $error("RRESP should be OKAY for all transactions")                                                          ;

// ---------------- WRITE DATA SUBCHANNEL COVER PROPERTIES  ----------------
cover property (start_of_write_address_handshake)                                ;
cover property (AWVALID_AWREADY_handshake_assertion)                             ;
cover property (BUS_STABLE_during_write)                                         ;
cover property (Rose_of_WREADY_after_AWVALID)                                    ;

// ---------------- WRITE DATA SUBCHANNEL COVER PROPERTIES  ----------------
cover property (write_data_handshake)                                            ;
cover property (wlast_assertion)                                                 ;

// ---------------- WRITE RESP SUBCHANNEL COVER PROPERTIES  ----------------
cover property (BVALID_assertion)                                                ;    
cover property (new_transaction_after_write_response)                            ;
cover property (BRESP_assertion)                                                 ;

// ---------------- READ ADDRESS SUBCHANNEL COVER PROPERTIES ----------------
cover property (start_of_read_handshake)                                         ;
cover property (ARVALID_ARREADY_handshake_assertion)                             ;
cover property (BUS_STABLE_during_read)                                          ;


// ---------------- READ DATA SUBCHANNEL COVER PROPERTIES  ----------------
cover property (read_data_handshake)                                             ;
cover property (rlast_assertion)                                                 ;
cover property (RRESP_assertion)                                                 ;

endmodule