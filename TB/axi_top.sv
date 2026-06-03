module axi_top;
    bit ACLK;

    axi_if axiif(ACLK);
    axi4   DUT  (
        .ACLK    (axiif.ACLK),
        .ARESETn (axiif.ARESETn),

        // Write address channel
        .AWADDR  (axiif.AWADDR),
        .AWLEN   (axiif.AWLEN),
        .AWSIZE  (axiif.AWSIZE),
        .AWVALID (axiif.AWVALID),
        .AWREADY (axiif.AWREADY),

        // Write data channel
        .WDATA   (axiif.WDATA),
        .WVALID  (axiif.WVALID),
        .WLAST   (axiif.WLAST),
        .WREADY  (axiif.WREADY),

        // Write response channel
        .BRESP   (axiif.BRESP),
        .BVALID  (axiif.BVALID),
        .BREADY  (axiif.BREADY),

        // Read address channel
        .ARADDR  (axiif.ARADDR),
        .ARLEN   (axiif.ARLEN),
        .ARSIZE  (axiif.ARSIZE),
        .ARVALID (axiif.ARVALID),
        .ARREADY (axiif.ARREADY),

        // Read data channel
        .RDATA   (axiif.RDATA),
        .RRESP   (axiif.RRESP),
        .RVALID  (axiif.RVALID),
        .RLAST   (axiif.RLAST),
        .RREADY  (axiif.RREADY)
    );

    axi4_TE TEST (axiif);
    axi4_sva SVA (axiif);

    // bind axi4 axi4_sva SVA_bind(axiif); //binding the SVA to the DUT

// ----------------------------------------
//            Clock Generation 
// ----------------------------------------
    initial begin
        ACLK = 0;
        forever #5 ACLK = ~ACLK; //100MHz clock
    end


endmodule