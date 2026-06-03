import axi4_enum_pkg::*;
import axi4_pkg::*;
module axi4_TE (axi_if.TB axiif);
    
//Signal Declaration
    bit                        ACLK       ;
    bit                        ARESETn    ;

    // Write address channel
    logic [ADDR_WIDTH-1:0]     AWADDR     ;
    logic [7:0]                AWLEN      ;
    logic [2:0]                AWSIZE     ;
    logic                      AWVALID    ;
    logic                      AWREADY    ;

    // Write data channel
    logic  [DATA_WIDTH-1:0]    WDATA      ;
    logic                      WVALID     ;
    logic                      WLAST      ;
    logic                      WREADY     ;

    // Write response channel
    logic  [1:0]               BRESP      ;
    logic                      BVALID     ;
    logic                      BREADY     ;

    // Read address channel
    logic  [ADDR_WIDTH-1:0]    ARADDR     ;
    logic  [7:0]               ARLEN      ;
    logic  [2:0]               ARSIZE     ;
    logic                      ARVALID    ;
    logic                      ARREADY    ;

    // Read data channel
   logic  [DATA_WIDTH-1:0]     RDATA      ;
   logic  [1:0]                RRESP      ;
   logic                       RVALID     ;
   logic                       RLAST      ;
   logic                       RREADY     ;
   axi_test_e                  test       ;

   //Packet Handle
   axi4_pkt pkt                           ;

   //monitor packet to be sent to the scoreboard
   axi4_pkt mon_pkt                       ;

   //packet to collect coverage
   axi4_pkt cov_pkt = new()               ;

   //data_out_queue to store data out from RAM when read for scoreboard
    logic [DATA_WIDTH-1:0] data_out_queue_sb [$]        ;

   // data_out_queue_mon to store the data monitored during read transaction
    logic [DATA_WIDTH-1:0] data_out_queue_mon [$]       ;

   //to store data written to RAM from monitor for scoreboard
    logic [DATA_WIDTH-1:0] data_in_queue [$]            ; 

   //to store the addresses that has been written to be read again
    prev_written_addr write_adderesses_queue [$]        ;

   // struct array to store the count of correct and wrong transactions for each test case
    test_stats_t stats[axi_test_e]                      ;


    logic RRESP_gm                                      ; 
    logic BRESP_gm                                      ;

    int correct_cnt, error_cnt                          ;

 // TB -> Interface
    assign axiif.ARESETn = ARESETn                      ;
    assign ACLK          = axiif.ACLK                   ;

    assign axiif.AWADDR  = AWADDR                       ;
    assign axiif.AWLEN   = AWLEN                        ;
    assign axiif.AWSIZE  = AWSIZE                       ;
    assign axiif.AWVALID = AWVALID                      ;

    assign axiif.WDATA   = WDATA                        ;
    assign axiif.WVALID  = WVALID                       ;
    assign axiif.WLAST   = WLAST                        ;

    assign axiif.BREADY  = BREADY                       ;

    assign axiif.ARADDR  = ARADDR                       ;
    assign axiif.ARLEN   = ARLEN                        ;
    assign axiif.ARSIZE  = ARSIZE                       ;
    assign axiif.ARVALID = ARVALID                      ;

    assign axiif.RREADY  = RREADY                       ;

    // Interface -> TB
    assign AWREADY = axiif.AWREADY                      ;

    assign WREADY  = axiif.WREADY                       ;

    assign BRESP   = axiif.BRESP                        ;
    assign BVALID  = axiif.BVALID                       ;

    assign ARREADY = axiif.ARREADY                      ;                   

    assign RDATA   = axiif.RDATA                        ;
    assign RRESP   = axiif.RRESP                        ;
    assign RVALID  = axiif.RVALID                       ;
    assign RLAST   = axiif.RLAST                        ;

always @(axiif.ACLK) begin
   if(pkt != null) begin  pkt.ACLK     = axiif.ACLK; end
  if(mon_pkt != null) begin   mon_pkt.ACLK = axiif.ACLK; end
end

    /****************************************************************************/
    //////////////////////////// Applying Tests /////////////////////////////////
    /***************************************************************************/

initial begin
    pkt         = new()                                                             ;
    initialize_inputs()                                                             ;

    $display("at %0t [TEST]: AXI_RESET test has started", $time)                    ;                 
    repeat(2) begin                            
        test = AXI_RESET                                                            ;
        stimulus_generation(pkt, test)                                              ; 
        fork                            
            Write_Driver(pkt)                                                       ;
            Read_Driver(pkt)                                                        ;
            monitor(mon_pkt, data_out_queue_mon, data_in_queue)                     ;
        join 
        Golden_model(mon_pkt, data_out_queue_sb)                                    ;
          coverage_collector( cov_pkt, mon_pkt);
        AXI_checker(data_out_queue_sb, data_out_queue_mon)                          ;
        mon_pkt.data_queue.delete()                                                 ;
    end

    $display("at %0t [TEST]: AXI_B2B_WRITE_SINGLE_BEAT test has started", $time)    ;        
    repeat(10) begin
        test = AXI_B2B_WRITE_SINGLE_BEAT                                            ;
        stimulus_generation(pkt, test)                                              ; 
        fork                            
            Write_Driver(pkt)                                                       ;
            Read_Driver(pkt)                                                        ;
            monitor(mon_pkt, data_out_queue_mon, data_in_queue)                     ;
        join 
        Golden_model(mon_pkt, data_out_queue_sb)                                    ;
          coverage_collector( cov_pkt, mon_pkt)                                     ;
        AXI_checker(data_out_queue_sb, data_out_queue_mon)                          ;
        stats[test].transactions++;
    end

    $display("at %0t [TEST]: AXI_B2B_READ_SINGLE_BEAT test has started", $time)     ;        
    repeat(write_adderesses_queue.size()) begin
        test = AXI_B2B_READ_SINGLE_BEAT                                             ;
        stimulus_generation(pkt, test)                                              ; 
        fork                            
            Write_Driver(pkt)                                                       ;
            Read_Driver(pkt)                                                        ;
            monitor(mon_pkt, data_out_queue_mon, data_in_queue)                     ;
        join 
        Golden_model(mon_pkt, data_out_queue_sb)                                    ;
          coverage_collector( cov_pkt, mon_pkt)                                     ;
        AXI_checker(data_out_queue_sb, data_out_queue_mon)                          ;
        stats[test].transactions++;
    end

    $display("at %0t [TEST]: AXI_BURST_WRITE test has started", $time)              ;
    repeat(10) begin
        test = AXI_BURST_WRITE                                                      ;
        stimulus_generation(pkt, test)                                              ; 
        fork                            
            Write_Driver(pkt)                                                       ;
            Read_Driver(pkt)                                                        ;
            monitor(mon_pkt, data_out_queue_mon, data_in_queue)                     ;
        join 
        Golden_model(mon_pkt, data_out_queue_sb)                                    ;
          coverage_collector( cov_pkt, mon_pkt)                                     ;
        AXI_checker(data_out_queue_sb, data_out_queue_mon)                          ;
        stats[test].transactions++;
    end

    $display("at %0t [TEST]: AXI_BURST_READ test has started", $time)               ;
    repeat(write_adderesses_queue.size()) begin
        test = AXI_BURST_READ                                                       ;
        stimulus_generation(pkt, test)                                              ; 
        fork                            
            Write_Driver(pkt)                                                       ;
            Read_Driver(pkt)                                                        ;
            monitor(mon_pkt, data_out_queue_mon, data_in_queue)                     ;
        join 
        Golden_model(mon_pkt, data_out_queue_sb)                                    ;
          coverage_collector( cov_pkt, mon_pkt)                                     ;
        AXI_checker(data_out_queue_sb, data_out_queue_mon)                          ;
        stats[test].transactions++;
    end

    $display("at %0t [TEST]: AXI_ERR_INJECTRION_WRITE test has started", $time)     ;
    repeat(30) begin
        test = AXI_ERR_INJECTRION_WRITE                                             ;
        stimulus_generation(pkt, test)                                              ; 
        fork                            
            Write_Driver(pkt)                                                       ;
            Read_Driver(pkt)                                                        ;
            monitor(mon_pkt, data_out_queue_mon, data_in_queue)                     ;
        join 
        Golden_model(mon_pkt, data_out_queue_sb)                                    ;
        coverage_collector( cov_pkt, mon_pkt)                                       ;
        AXI_checker(data_out_queue_sb, data_out_queue_mon)                          ;
        stats[test].transactions++;
    end

    $display("at %0t [TEST]: AXI_ERR_INJECTION_READ test has started", $time)       ;
    repeat(write_adderesses_queue.size()) begin
        test = AXI_ERR_INJECTION_READ                                               ;
         stimulus_generation(pkt, test)                                             ; 
        fork                            
            Write_Driver(pkt)                                                       ;
            Read_Driver(pkt)                                                        ;
            monitor(mon_pkt, data_out_queue_mon, data_in_queue)                     ;
        join 
        Golden_model(mon_pkt, data_out_queue_sb)                                    ;
        coverage_collector( cov_pkt, mon_pkt)                                       ;
        AXI_checker(data_out_queue_sb, data_out_queue_mon)                          ;
        stats[test].transactions++;
    end

    $display("at %0t [TEST]: AXI_MAX_MIN_ADDR_WRITE test has started", $time)       ;
    repeat(10) begin
        test = AXI_MAX_MIN_ADDR_WRITE                                               ;
        stimulus_generation(pkt, test)                                              ; 
        fork                            
            Write_Driver(pkt)                                                       ;
            Read_Driver(pkt)                                                        ;
            monitor(mon_pkt, data_out_queue_mon, data_in_queue)                     ;
        join 
        Golden_model(mon_pkt, data_out_queue_sb)                                    ;
        coverage_collector( cov_pkt, mon_pkt)                                       ;
        AXI_checker(data_out_queue_sb, data_out_queue_mon)                          ;
        stats[test].transactions++;
    end

        $display("at %0t [TEST]: AXI_MAX_MIN_ADDR_READ test has started", $time)    ;
    repeat(write_adderesses_queue.size()) begin
        test = AXI_MAX_MIN_ADDR_READ                                                ;
        stimulus_generation(pkt, test)                                              ; 
        fork                            
            Write_Driver(pkt)                                                       ;
            Read_Driver(pkt)                                                        ;
            monitor(mon_pkt, data_out_queue_mon, data_in_queue)                     ;
        join 
        Golden_model(mon_pkt, data_out_queue_sb)                                    ;
        coverage_collector( cov_pkt, mon_pkt)                                       ;
        AXI_checker(data_out_queue_sb, data_out_queue_mon)                          ;
        stats[test].transactions++;
    end

        $display("at %0t [TEST]: RANDOM test has started", $time)                   ;
        repeat(50) begin
            pkt.test_cases_read.rand_mode(1)                                        ;
            pkt.test_cases_write.rand_mode(1)                                       ;
            pkt.test_cases_ct.constraint_mode(1)                                    ;

         assert(pkt.randomize(test_cases_write, test_cases_read)) 
        else 
         $fatal("Randomization failed for test_cases_write or test_cases_read")      ;
         test = pkt.test_cases_write                                                 ;
            repeat(2) begin
                stimulus_generation(pkt, test)                                       ; 
                fork                            
                    Write_Driver(pkt)                                                ;
                    Read_Driver(pkt)                                                 ;
                    monitor(mon_pkt, data_out_queue_mon, data_in_queue)              ;
                join 
                Golden_model(mon_pkt, data_out_queue_sb)                             ;
                coverage_collector( cov_pkt, mon_pkt)                                ;
                AXI_checker(data_out_queue_sb, data_out_queue_mon)                   ;
                stats[test].transactions++;
    end
   
        test = pkt.test_cases_read                                                   ;
            repeat(write_adderesses_queue.size()) begin
                stimulus_generation(pkt, test)                                       ; 
                fork                            
                    Write_Driver(pkt)                                                ;
                    Read_Driver(pkt)                                                 ;
                    monitor(mon_pkt, data_out_queue_mon, data_in_queue)              ;
                join 
                Golden_model(mon_pkt, data_out_queue_sb)                             ;
                coverage_collector( cov_pkt, mon_pkt)                                ;
                AXI_checker(data_out_queue_sb, data_out_queue_mon)                   ;
                stats[test].transactions++;
            end
        end

    #100                                                                            ;
    Report_Task()                                                                     ;
    $stop                                                                             ;
end

//Stimulus Generation Task 
task automatic stimulus_generation(ref axi4_pkt packet, axi_test_e test);
prev_written_addr temp;
packet.test_cases = test;
packet.test_cases_ct.constraint_mode(0)                                                 ;
packet.rand_mode(1)                                                                     ;
packet.test_cases_read.rand_mode(0)                                                     ;
packet.test_cases_write.rand_mode(0)                                                    ;

assert(packet.randomize() with {
    (test == AXI_RESET)                 -> (ARESETn == 0)                               ;
    (test == AXI_B2B_WRITE_SINGLE_BEAT) -> (ARVALID == 0 &&  AWLEN == 0)                ;
    (test == AXI_BURST_WRITE)           -> (AWVALID == 1)                               ;
    (test == AXI_B2B_READ_SINGLE_BEAT ) -> (AWVALID == 0 && ARLEN == 0)                 ;
    (test == AXI_BURST_READ)            -> (ARVALID == 1)                               ;
    (test == AXI_ERR_INJECTRION_WRITE)  -> (AWVALID == 1)                               ;
    (test == AXI_ERR_INJECTION_READ)    -> (AWVALID == 0 && ARVALID == 1)               ;
    (test == AXI_MAX_MIN_ADDR_WRITE)    -> (AWVALID == 1)                               ;
    (test == AXI_MAX_MIN_ADDR_READ)     -> (ARVALID == 1)                               ;
})
 else 
$fatal("error in randomization");

`ifdef HIGH_DEBUG_MODE
      packet.display_stimulus("SEQUENCE", "Generated Stimulus:");
`endif 
if(packet.AWVALID && packet.ARESETn) 
begin
    temp.addr = packet.AWADDR   ;
    temp.len  = packet.AWLEN    ;
   write_adderesses_queue.push_back(temp); // Store the written address for later read
end
endtask //automatic

// Write Driver Task
task automatic Write_Driver(input axi4_pkt packet); 
    int cntr = 0                   ;
    bit stuck_in_wait = 0          ;
    int beat_cnt;
    int q_idx;

    beat_cnt = 0;   // Counts only accepted beats
    q_idx    = 0;   // Index into your randomized queues

    $display("at %0t [Driver]: Write Driver Starts...", $time);
      // ---------------- Phase 1: Drive Address ----------------
    ARESETn = packet.ARESETn       ;
    AWADDR  = packet.AWADDR        ;
    AWLEN   = packet.AWLEN         ;
    AWSIZE  = packet.AWSIZE        ;
    AWVALID = packet.AWVALID       ;

    `ifdef HIGH_DEBUG_MODE
    $display ("at %0t [DRIVER]: driving ARESET = %0b, AWADDR = %0h, AWLEN = %0d, AWSIZE = %0d, AWVALID = %0b on the bus at negedge", $time, ARESETn, AWADDR, AWLEN, AWSIZE, AWVALID);
    `endif

    @(posedge ACLK)                ;  

    `ifdef HIGH_DEBUG_MODE
    $display ("at %0t [DRIVER]: waiting at posedge clk to check AWVALID and AWREADY", $time);
    `endif

    if(!ARESETn || (!AWVALID)) begin
      @(negedge ACLK)              ;  

        
    `ifdef HIGH_DEBUG_MODE
    $display ("at %0t [DRIVER]: ARESETn = %0b, AWVALID = %0b, no write transaction will be driven, just waiting for the next negedge", $time, ARESETn, AWVALID);
    $display("--------------------------------------------------");
    $display ("\n"); 
    `endif

        return                     ;
    end 

        // ---------------- Phase 2: Handshake + Watchdog ----------------

    else if (AWVALID && AWREADY) begin       //READY BEFORE VALID handshake
        AWVALID = 0                    ;
        ARVALID = 0                    ;

        `ifdef HIGH_DEBUG_MODE
        $display ("at %0t [DRIVER]: READY BEFORE VALID handshake, starting the write transaction", $time);
        `endif

       repeat(2) @(negedge ACLK)                     ;
        
        // ---------------- Phase 3: Write Data ----------------

        while (beat_cnt < (AWLEN + 1)) begin

            BREADY = packet.BREADY_queue[q_idx]  ; // each beat                     ;

            WVALID = packet.WVALID_queue[q_idx]  ; // each beat
            WDATA  = packet.data_queue[q_idx]    ; // each beat

            if(!WVALID) begin
                @(negedge ACLK)                              ;
                WVALID = packet.WVALID_queue[q_idx + 1]      ; // each beat
                WDATA  = packet.data_queue[q_idx + 1]        ; // each beat
            end
           if(beat_cnt == AWLEN) begin
                break;
            end

           @(negedge ACLK)                         ;       //waiting for extra clock egde to give a chance for the AXI slave to sample the WDATA and write the data

            fork_guard_lvl (WREADY, "DRIVER - Write Data -  WREADY")    ; // Wait for WREADY with a timeout
            
            beat_cnt++                                                  ;
            q_idx++                                                     ;
        
        end

            WLAST = 1                                                    ;

        // ---------------- Phase 4: Response ----------------      

            do begin
            BREADY = packet.BREADY_queue[q_idx]                          ;
            @(negedge ACLK)                                              ;
            WLAST   = 0                                                  ;
            WVALID  = 0                                                  ;
            q_idx++;
            end
            while(!(BREADY))                                              ; // Wait for the last beat to be accepted;

            @(negedge ACLK)                                               ;
            BREADY  = 0                                                   ;  
            WLAST   = 0                                                   ;
            WVALID  = 0                                                   ;

        `ifdef HIGH_DEBUG_MODE
        $display ("at %0t [DRIVER]: Data Written for %0d beats, waiting for BVALID handshake", $time, AWLEN+1);
        `endif

            @(negedge ACLK)                                                ;
            @(negedge ACLK)                                                ;

     end
else begin
    $display("at %0t [Driver]: Write Driver Ends", $time)                   ;
    return                                                                  ;
end
  $display("at %0t [Driver]: Write Driver Ends", $time)                     ;
endtask //automatic


//Read Driver Task
task automatic Read_Driver(input axi4_pkt packet); 

    int cntr = 0                                                            ;
    bit stuck_in_wait = 0                                                   ;
    prev_written_addr temp                                                  ;

    int beat_cnt                                                            ;
    int q_idx                                                               ;

    beat_cnt = 0                                                            ;   // Counts only accepted beats
    q_idx    = 0                                                            ;   // Index into your randomized queues

    $display("at %0t [Driver]: Read Driver Starts...", $time);
      // ---------------- Phase 1: Drive Address ----------------
    if((test == AXI_B2B_READ_SINGLE_BEAT || test == AXI_BURST_READ || test == AXI_ERR_INJECTION_READ || test == AXI_MAX_MIN_ADDR_READ) && write_adderesses_queue.size() != 0 ) begin
    
    temp  = write_adderesses_queue.pop_front()                              ; // Get the address of the previous write transaction for read
    ARADDR  = temp.addr                                                     ;
    ARLEN   = temp.len                                                      ;
    packet.ARLEN_constr = temp.len                                          ; // Set the ARLEN constraint for RREADY queue based on the burst length of the read transaction
    end

    else begin
    ARADDR  = packet.ARADDR                                                 ;
    packet.ARLEN_constr = packet.ARLEN                                      ;

    ARLEN   = packet.ARLEN                                                  ;
    end                                 
    ARSIZE  = packet.ARSIZE                                                 ;
    ARVALID = packet.ARVALID                                                ;

    `ifdef HIGH_DEBUG_MODE
    $display("at %0t [DRIVER]: driving ARADDR = %0h, ARLEN = %0d, ARSIZE = %0d, ARVALID = %0b on the bus at negedge", $time, ARADDR, ARLEN, ARSIZE, ARVALID)        ;
    `endif

    @(posedge ACLK)                                                         ;  

    `ifdef HIGH_DEBUG_MODE
    $display ("at %0t [DRIVER]: waiting at posedge clk to check ARVALID and ARREADY", $time)                                                                        ;
    `endif

    if(!ARESETn || (!ARVALID)) begin
      @(negedge ACLK)                                                       ;  

        
    `ifdef HIGH_DEBUG_MODE
    $display ("at %0t [DRIVER]: ARESETn = %0b, ARVALID = %0b, no read transaction will be driven, just waiting for the next negedge", $time, ARESETn, ARVALID)      ;
    $display("--------------------------------------------------")                                                                                                  ;
    $display ("\n")                                                                                                                                                 ; 
    `endif

        return                                                              ;
    end 

        // ---------------- Phase 2: Handshake ----------------

    else if (ARVALID && ARREADY) begin       //READY BEFORE VALID handshake
        `ifdef HIGH_DEBUG_MODE
        $display ("at %0t [DRIVER]: READY BEFORE VALID handshake, starting the read transaction, ARVALID = %0b, ARREADY = %0b", $time, ARVALID, ARREADY);
        `endif
        ARVALID = 0                         ;
        @(negedge ACLK)                     ;
        

  
        // ---------------- Phase 3: Read  Data ----------------

        while (beat_cnt < (ARLEN + 1)) begin


            RREADY = packet.RREADY_queue[q_idx]                 ; // each beat


            if(!RREADY) begin
                @(negedge ACLK)                                 ;
                RREADY = packet.RREADY_queue[q_idx + 1]         ; // each beat
            end
           if(beat_cnt == ARLEN) begin
                break;
            end
           @(negedge ACLK)                                      ;       //waiting for extra clock edge to give a chance for the AXI slave to sample the WDATA and write the data

            
            beat_cnt++                                          ;
            q_idx++                                             ;
        end

           @(negedge RLAST)                                     ;
            RREADY = 0                                          ;
           @(negedge ACLK)                                      ;
           @(negedge ACLK)                                      ;

        `ifdef HIGH_DEBUG_MODE
        $display ("at %0t [DRIVER]: Data Read for %0d beats", $time, ARLEN+1)               ;
        $display(" driving READ TRANSACTION was SUCCESSFULL")                               ;
        `endif
     
     end
else begin
    $display("at %0t [Driver]: Read Driver Ends", $time)                                    ;
return;
end
  $display("at %0t [Driver]: Read Driver Ends", $time)                                      ;
endtask //automatic


task automatic monitor(ref axi4_pkt mon_pkt, ref logic [DATA_WIDTH-1:0] data_out_queue_mon[$], ref logic [DATA_WIDTH-1:0] data_in_queue[$])     ;
bit stuck_in_wait = 0                                                                       ;
    int beat_cnt                                                                            ;
    int q_idx                                                                               ;

    beat_cnt = 0                                                                            ;   // Counts only accepted beats
    q_idx    = 0                                                                            ;   // Index into your randomized queues
$display("at %0t [MONITOR]: Monitor Starts...", $time)                                      ;
 mon_pkt     = new()                                                                        ;
 if(ARESETn == 0) begin
    $display("at %0t [MONITOR]: Reset is asserted ", $time)                                 ;
    mon_pkt.ARESETn     = ARESETn            ;
    @(negedge ACLK)                          ;
    mon_pkt.AWVALID     = AWVALID            ;
    mon_pkt.ARVALID     = ARVALID            ;
    mon_pkt.AWADDR      = AWADDR             ;
    mon_pkt.AWREADY     = AWREADY            ;
    mon_pkt.AWLEN       = AWLEN              ;
    mon_pkt.AWSIZE      = AWSIZE             ;
    
    mon_pkt.ARADDR      = ARADDR             ;
    mon_pkt.ARLEN       = ARLEN              ;
    mon_pkt.ARSIZE      = ARSIZE             ;
    mon_pkt.ARREADY     = ARREADY            ; 

    mon_pkt.WVALID      = WVALID             ;
    mon_pkt.WLAST       = WLAST              ;
    mon_pkt.WREADY      = WREADY             ;

    mon_pkt.WDATA = WDATA                    ; // Capture the last beat data for debug purpose   

    mon_pkt.BVALID = BVALID                  ; // Deassert WVALID after the last beat    
    mon_pkt.BRESP  = BRESP                   ;
    mon_pkt.BREADY = BREADY                  ;

    mon_pkt.RLAST = RLAST                    ;
    mon_pkt.RDATA = RDATA                    ; // Capture the last beat data for debug purpose
    mon_pkt.RVALID = RVALID                  ; // Deassert RREADY after the last beat    
    mon_pkt.RRESP  = RRESP                   ;
    mon_pkt.RREADY = RREADY                  ;

    $display("at %0t [MONITOR]: task is returned", $time);
    return                                   ;
 end
 else if(AWVALID) begin
        $display("at %0t [MONITOR]: AWVALID observed - starts monitoring write channel", $time);
    mon_pkt.ARESETn     = ARESETn            ;
    fork_guard_lvl ((AWVALID && AWREADY), "MONITOR - Write Data - AWVALID && AWREADY");
    // wait(AWVALID && AWREADY)                 ;      //huty fork guard hena 
    mon_pkt.AWVALID     = AWVALID            ;
    mon_pkt.AWREADY     = AWREADY            ;
    mon_pkt.ARVALID     = ARVALID            ;
    mon_pkt.ARREADY     = ARREADY            ;
    
    @(negedge ACLK)                          ;

    mon_pkt.AWADDR      = AWADDR             ;
    mon_pkt.AWLEN       = AWLEN              ;
    mon_pkt.AWSIZE      = AWSIZE             ;
    
    mon_pkt.ARADDR      = ARADDR             ;
    mon_pkt.ARLEN       = ARLEN              ;
    mon_pkt.ARSIZE      = ARSIZE             ;
    mon_pkt.ARREADY     = ARREADY            ;       
    
    @(negedge ACLK)                          ;
  
  `ifdef HIGH_DEBUG_MODE
    $display("at %0t [MONITOR]: observed AWVALID = %0b, AWADDR = %0h, AWLEN = %0d, AWSIZE = %0d, ARVALID = %0b, ARADDR = %0h, ARLEN = %0d, ARSIZE = %0d", $time,  mon_pkt.AWVALID, mon_pkt.AWADDR, mon_pkt.AWLEN, mon_pkt.AWSIZE, mon_pkt.ARVALID, mon_pkt.ARADDR, mon_pkt.ARLEN, mon_pkt.ARSIZE);
  `endif 


// Monitor exactly AWLEN+1 successful write data transfers
while (beat_cnt < (mon_pkt.AWLEN + 1)) begin
    @(posedge ACLK);

    // Ignore cycles where no handshake occurs
    if (!(WVALID && WREADY))
        continue;

    // A valid AXI write data beat has been accepted
    mon_pkt.WVALID_queue_mon.push_back(WVALID)      ;
    mon_pkt.WVALID = WVALID                         ;
    mon_pkt.WREADY = WREADY                         ;
    mon_pkt.RREADY = RREADY                         ;
    mon_pkt.RVALID = RVALID                         ;
    data_in_queue.push_back(WDATA)                  ;

`ifdef HIGH_DEBUG_MODE
    $display("at %0t [MONITOR]: WVALID = %0b, WDATA = %0h, WLAST = %0b", $realtime, WVALID, WDATA, WLAST)   ;
`endif

    // On the final accepted beat, capture WLAST
    if (beat_cnt == mon_pkt.AWLEN)
        mon_pkt.WLAST = WLAST                       ;

    // Count only successful handshakes
    beat_cnt++                                      ;
end
    

    `ifdef HIGH_DEBUG_MODE
        $display("at %0t [MONITOR]: data_in_queue = %0p", $time, data_in_queue)                                 ;
        $display("at %0t [MONITOR]: data written = %0p, last flag = %0b", $time, data_in_queue, mon_pkt.WLAST)  ;
    `endif 

    @(negedge ACLK)                                                   ;
    mon_pkt.WDATA = WDATA                                             ;  
    mon_pkt.RREADY = RREADY                                           ;
     mon_pkt.RDATA = RDATA                                            ; 
    mon_pkt.RLAST  = RLAST                                            ;
    wait(BVALID && BREADY)                                            ; ///////
    mon_pkt.BVALID = BVALID                                           ; // Deassert WVALID after the last beat    
    mon_pkt.BRESP  = BRESP                                            ;
    mon_pkt.BREADY = BREADY                                           ;

    `ifdef HIGH_DEBUG_MODE
        $display("at %0t [MONITOR]: observed BVALID = %0b, BRESP = %0b, BREADY = %0b, last written data = %0d", $time, mon_pkt.BVALID, mon_pkt.BRESP, mon_pkt.BREADY, mon_pkt.WDATA)    ;
    `endif 
 end
else if (ARVALID) begin
            $display("at %0t [MONITOR]: ARVALID observed - starts monitoring read channel", $time)                                                                                      ;
    mon_pkt.ARESETn     = ARESETn                                                                                                                                                       ;
    fork_guard_lvl (ARREADY, "MONITOR - Read Address - ARVALID && ARREADY");  

    mon_pkt.ARVALID     = ARVALID        ;
    mon_pkt.ARREADY     = ARREADY        ;
    mon_pkt.AWVALID     = AWVALID        ;
    mon_pkt.AWREADY     = AWREADY        ;
    
    @(negedge ACLK)                      ;

    mon_pkt.ARADDR      = ARADDR         ;
    mon_pkt.ARLEN       = ARLEN          ;
    mon_pkt.ARSIZE      = ARSIZE         ;
    
    mon_pkt.AWADDR      = AWADDR         ;
    mon_pkt.AWLEN       = AWLEN          ;
    mon_pkt.AWSIZE      = AWSIZE         ;

  `ifdef HIGH_DEBUG_MODE
    $display("at %0t [MONITOR]: observed ARVALID = %0b, ARADDR = %0h, ARLEN = %0d, ARSIZE = %0d, ARREADY = %0b", $time,  mon_pkt.ARVALID, mon_pkt.ARADDR, mon_pkt.ARLEN, mon_pkt.ARSIZE, mon_pkt.ARREADY);
  `endif 


while (beat_cnt < (mon_pkt.ARLEN + 1)) begin
    `ifdef HIGH_DEBUG_MODE
        $display("at %0t [MONITOR]:start of loop beat count = %0d", $realtime, beat_cnt)   ;
    `endif 
   
    wait(RVALID)                                                                  ; // Wait for RVALID handshake;
        if(RLAST && beat_cnt == mon_pkt.ARLEN)
        begin
                mon_pkt.RREADY = RREADY                                           ;
                mon_pkt.RREADY_queue_mon.push_back(RREADY)                        ;
                mon_pkt.RLAST  = RLAST                                            ;
                mon_pkt.RVALID = RVALID                                           ;
                mon_pkt.RRESP  = RRESP                                            ;
                
                mon_pkt.WDATA  = WDATA                                            ;
                mon_pkt.WLAST  = WLAST                                            ;
                mon_pkt.WVALID = WVALID                                           ;
                @(negedge RVALID)                                                 ;          
                 @(negedge ACLK)                                                  ;
                data_out_queue_mon.push_back(RDATA)  ; // Store the read data for later verification
                mon_pkt.RDATA = RDATA                ; 
                `ifdef HIGH_DEBUG_MODE
                $display("at %0t [MONITOR]: RVALID = %0b, RLAST = %0b, RDATA = %0h ,beat count = %0d", $realtime,  mon_pkt.RVALID,  mon_pkt.RLAST,  mon_pkt.RDATA , beat_cnt);        
                `endif
                break;  
        end


    @(negedge RVALID)                                                 ;
    mon_pkt.RREADY = RREADY                                           ;
    mon_pkt.RREADY_queue_mon.push_back(RREADY)                        ;
    mon_pkt.RLAST  = RLAST                                            ;
    mon_pkt.RVALID = RVALID                                           ;
    mon_pkt.WVALID = WVALID                                           ;
    `ifdef HIGH_DEBUG_MODE
    $display("at %0t [MONITOR]:RVALID = %0b, RLAST = %0b, RREADY = %0b ,beat count = %0d", $realtime, mon_pkt.RVALID, mon_pkt.RLAST, mon_pkt.RREADY, beat_cnt);
    `endif
    @(negedge ACLK)                                                   ;
    data_out_queue_mon.push_back(RDATA)  ; // Store the read data for later verification
    mon_pkt.RDATA = RDATA                ; 
    
    `ifdef HIGH_DEBUG_MODE
       $display("at %0t [MONITOR]: RVALID = %0b, RLAST = %0b, RDATA = %0h ,beat count = %0d", $realtime,  mon_pkt.RVALID,  mon_pkt.RLAST,  mon_pkt.RDATA , beat_cnt);
    `endif
    // Count only successful handshakes
    beat_cnt++;

`ifdef HIGH_DEBUG_MODE
     $display("at %0t [MONITOR]: end of loop beat count = %0d", $realtime, beat_cnt);
`endif

end


    `ifdef HIGH_DEBUG_MODE
        $display("at %0t [MONITOR]: data read = %0p, last flag = %0b", $time, data_out_queue_mon, mon_pkt.RLAST )                                                                       ;
    `endif 

    `ifdef HIGH_DEBUG_MODE
        $display("at %0t [MONITOR]: observed RVALID = %0b, RRESP = %0b, RREADY = %0b, last read data = %0d", $time, mon_pkt.RVALID, mon_pkt.RRESP, mon_pkt.RREADY, mon_pkt.RDATA)       ;
    `endif
    @(negedge ACLK)                      ;   

    mon_pkt.BVALID = BVALID              ; // Deassert WVALID after the last beat    
    mon_pkt.BRESP  = BRESP               ;
    mon_pkt.BREADY = BREADY              ;

        if(mon_pkt.RRESP == 2)
            data_out_queue_mon.delete()  ;

    `ifdef HIGH_DEBUG_MODE
        $display("at %0t [MONITOR]: observed RVALID = %0b, RRESP = %0b, RREADY = %0b, last read data = %0d", $time, mon_pkt.RVALID, mon_pkt.RRESP, mon_pkt.RREADY, mon_pkt.RDATA)       ;
    `endif
 end
else begin
    $display("at %0t [Monitor]: Monitor Ends", $time)           ;
return;
end
 
    `ifdef HIGH_DEBUG_MODE
     mon_pkt.display_stimulus("MONITOR", "Observed Signals:")   ;
     pkt.display_stimulus("ORIGINAL STIMULUS")                  ;
    `endif
 $display("at %0t [Monitor]: Monitor Ends", $time)              ;
endtask //automatic


//Golden model task
task automatic Golden_model (ref axi4_pkt packet, ref logic [DATA_WIDTH-1:0] data_out_queue_sb[$])  ;
    static logic [DATA_WIDTH-1:0] golden_data [logic [ADDR_WIDTH-1:0]]      ; // Golden model memory
    bit out_of_range            ;
    bit stored_Wvalid           ;
    bit stored_Rready           ;

    $display("at %0t [Golden Model]: Golden Model Starts...", $time)        ;
 

    if(packet.AWVALID) begin
        if((((AWLEN + 1) * 4) - 1 ) + AWADDR  > MAX_ADDR) 
            out_of_range = 1    ; 

        else
            out_of_range = 0    ;
    end
    else if(packet.ARVALID) begin
        if((((ARLEN + 1) * 4) - 1 ) + ARADDR  > MAX_ADDR) 
            out_of_range = 1    ;
        else
            out_of_range = 0    ;
    end

    if(!packet.ARESETn || out_of_range) begin
    return                      ;
    end

    else if(packet.AWVALID) begin
    for(int i = 0; i <= (packet.AWLEN * 4); i = i + 4) begin
        stored_Wvalid = packet.WVALID_queue_mon.pop_front()                 ; // Get WVALID for the current beat
        if(!stored_Wvalid)
        continue;
        else begin
            if(data_in_queue.size != 0)
                golden_data[(packet.AWADDR + i) / 4] = data_in_queue.pop_front()    ; // Get data from the queue for each beat;
            else
                golden_data[(packet.AWADDR + i) / 4] = 0                            ;
    end
    end
    `ifdef HIGH_DEBUG_MODE
        $display("at %0t [SCOREBOARD - Golden model task]: golden model ram = %0p", $time, golden_data) ;
    `endif 
end
    else if(packet.ARVALID) begin
    for(int i = 0; i <= (packet.ARLEN*4); i = i + 4) begin
        stored_Rready = packet.RREADY_queue_mon.pop_front()                          ; // Get RREADY for the current beat
        data_out_queue_sb.push_back(golden_data[(packet.ARADDR + i) / 4])            ; // Push data to the output queue for each beat;
    end
        `ifdef HIGH_DEBUG_MODE
        $display("at %0t [SCOREBOARD - Golden model task]: golden model ram = %0p", $time, golden_data)         ;
        $display("at %0t [SCOREBOARD - Golden model task]: data_out_queue_sb = %0p", $time, data_out_queue_sb)  ;
        `endif 
end
$display("at %0t [Golden Model]: Golden Model ends", $time)                                                     ;
endtask //automatic




task automatic AXI_checker(ref logic [DATA_WIDTH-1:0] data_out_queue[$], ref logic [DATA_WIDTH-1:0] data_out_queue_mon[$])  ;
  $display("at %0t [Checker]: Checker Start...", $time)                                                                     ;
    if(data_out_queue.size() != data_out_queue_mon.size()) begin
        $error("at %0t [CHECKER]:Data length mismatch: Expected %0d beats, Got %0d beats", $time, data_out_queue.size(), data_out_queue_mon.size())     ;
        return                      ;
    end

    for(int i = 0; i < data_out_queue.size(); i++) begin
        if(data_out_queue[i] !== data_out_queue_mon[i]) begin
            stats[test].error_cnt++;
            error_cnt++;
        end
        else begin
            stats[test].correct_cnt++;
            correct_cnt++;
        end
    end

    `ifdef HIGH_DEBUG_MODE
    foreach(data_out_queue[j]) begin
    $display("at %0t [Checker]: data_out_queue_sb[%0d] = %0h, data_out_queue_mon[%0d] = %0h", $time, j, data_out_queue[j], j, data_out_queue_mon[j])    ;
    end
    `endif

    data_in_queue.delete()          ; //mesh mutaked mn el 7arka dy dlwa2ty
    data_out_queue.delete()         ;
    data_out_queue_mon.delete()     ;
    $display("at %0t [Checker]: Checker is done", $time);
    $display("-----------------------------------")     ;
endtask //automatic


task automatic initialize_inputs();
    ARESETn = 0;
    AWADDR  = 0;
    AWLEN   = 0;
    AWSIZE  = 0;
    AWVALID = 0;
    ARADDR  = 0;
    ARLEN   = 0;
    ARSIZE  = 0;
    ARVALID = 0;
    WDATA   = 0;
    WVALID  = 0;
    WLAST   = 0;
    BREADY  = 0;
    RREADY  = 0;
    @(negedge ACLK);
endtask //automatic

task automatic fork_guard_lvl (input logic condition, string caller);
    bit stuck_in_wait = 0       ;
    fork
        begin
            wait(condition)     ;
              `ifdef LOW_DEBUG_MODE
            $display("at %0t [%s]: Condition met, proceeding...", $time, caller)    ;
            `endif
            stuck_in_wait = 0   ;
        end
        begin
            repeat(MAX_WAIT_CYCLES) @(posedge ACLK)                                 ;
            $error("at %0t [%s]:Timeout after %0d cycles while waiting for condition", $time, caller, MAX_WAIT_CYCLES)  ;
            stuck_in_wait = 1   ;
        end
    join_any
    if(stuck_in_wait) return    ;
    disable fork                ; // Stop the timeout process if condition is met
endtask


task automatic coverage_collector(ref axi4_pkt cov_pkt, ref axi4_pkt mon_pkt);
cov_pkt.ACLK    = mon_pkt.ACLK          ;
cov_pkt.ARESETn = mon_pkt.ARESETn       ;
cov_pkt.AWADDR  = mon_pkt.AWADDR        ;
cov_pkt.AWLEN   = mon_pkt.AWLEN         ;
cov_pkt.AWSIZE  = mon_pkt.AWSIZE        ;

foreach (mon_pkt.WVALID_queue_mon[i]) begin
    cov_pkt.WVALID = mon_pkt.WVALID_queue_mon[i];
cov_pkt.ax_cg.sample();
end
cov_pkt.AWVALID = mon_pkt.AWVALID       ;


cov_pkt.AWREADY = mon_pkt.AWREADY       ;

cov_pkt.WDATA   = mon_pkt.WDATA         ;
cov_pkt.data_queue = mon_pkt.data_queue ; 

foreach (mon_pkt.data_queue[i]) begin
    cov_pkt.WDATA = mon_pkt.data_queue[i];
cov_pkt.ax_cg.sample();
end

cov_pkt.WVALID  = mon_pkt.WVALID        ;
cov_pkt.WLAST   = mon_pkt.WLAST         ;
cov_pkt.WREADY  = mon_pkt.WREADY        ;

cov_pkt.BVALID  = mon_pkt.BVALID        ;
cov_pkt.BRESP   = mon_pkt.BRESP         ;
cov_pkt.BREADY  = mon_pkt.BREADY        ;

cov_pkt.ARADDR  = mon_pkt.ARADDR        ;
cov_pkt.ARLEN   = mon_pkt.ARLEN         ;
cov_pkt.ARSIZE  = mon_pkt.ARSIZE        ;
cov_pkt.ARVALID = mon_pkt.ARVALID       ;
cov_pkt.ARREADY = mon_pkt.ARREADY       ;

cov_pkt.RDATA   = mon_pkt.RDATA         ;
cov_pkt.RVALID  = mon_pkt.RVALID        ;
cov_pkt.RRESP   = mon_pkt.RRESP         ;
cov_pkt.RREADY  = mon_pkt.RREADY        ;
cov_pkt.RLAST   = mon_pkt.RLAST         ;

cov_pkt.display_stimulus("Coverage_Collector", " ");
cov_pkt.ax_cg.sample();

endtask


// task automatic Report_Task();
task automatic Report_Task();

    int total_correct = 0;
    int total_error   = 0;
    int total_trans   = 0;

    $display("\n==================================================");
    $display("                 AXI TEST REPORT"                    );
    $display("====================================================");

    foreach(stats[t]) begin
        $display("%-30s  Transactions=%0d       Correct=%0d         Errors=%0d",
                 t.name(),
                 stats[t].transactions,
                 stats[t].correct_cnt,
                 stats[t].error_cnt);

        total_correct += stats[t].correct_cnt;
        total_error   += stats[t].error_cnt;
        total_trans   += stats[t].transactions;
    end

    $display("--------------------------------------------------");
    $display("TOTAL Transactions = %0d", total_trans);
    $display("TOTAL Correct      = %0d", total_correct);
    $display("TOTAL Errors       = %0d", total_error);
    $display("==================================================");

endtask
//     $display("at %0t [REPORT]: Correct Counts: %0d, Error Counts: %0d", $time, correct_cnt, error_cnt);
// endtask //automatic

endmodule