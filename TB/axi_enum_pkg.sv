package axi4_enum_pkg;

typedef enum bit [3:0] {AXI_RESET                           ,
                        AXI_B2B_WRITE_SINGLE_BEAT           ,   
                        AXI_B2B_READ_SINGLE_BEAT            , 
                        AXI_BURST_WRITE                     , 
                        AXI_BURST_READ                      , 
                        AXI_ERR_INJECTRION_WRITE            , 
                        AXI_ERR_INJECTION_READ              , 
                        AXI_MAX_MIN_ADDR_WRITE              ,
                        AXI_MAX_MIN_ADDR_READ               
                       } axi_test_e                         ;

endpackage