onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /axi_top/axiif/ACLK
add wave -noupdate /axi_top/axiif/ARESETn
add wave -noupdate -expand -group {Write address channel} -color Plum /axi_top/axiif/AWADDR
add wave -noupdate -expand -group {Write address channel} -color Plum /axi_top/axiif/AWLEN
add wave -noupdate -expand -group {Write address channel} -color Plum /axi_top/axiif/AWSIZE
add wave -noupdate -expand -group {Write address channel} -color Plum /axi_top/axiif/AWVALID
add wave -noupdate -expand -group {Write address channel} -color Plum /axi_top/axiif/AWREADY
add wave -noupdate -expand -group {Write data channel} -color Cyan /axi_top/axiif/WDATA
add wave -noupdate -expand -group {Write data channel} -color Cyan /axi_top/axiif/WVALID
add wave -noupdate -expand -group {Write data channel} -color Cyan /axi_top/axiif/WLAST
add wave -noupdate -expand -group {Write data channel} -color Cyan /axi_top/axiif/WREADY
add wave -noupdate -expand -group {Write response channel} -color Pink /axi_top/axiif/BRESP
add wave -noupdate -expand -group {Write response channel} -color Pink /axi_top/axiif/BVALID
add wave -noupdate -expand -group {Write response channel} -color Pink /axi_top/axiif/BREADY
add wave -noupdate /axi_top/TEST/ACLK
add wave -noupdate /axi_top/TEST/ARESETn
add wave -noupdate -expand -group {Read address channel} -color Gold /axi_top/axiif/ARADDR
add wave -noupdate -expand -group {Read address channel} -color Gold /axi_top/axiif/ARLEN
add wave -noupdate -expand -group {Read address channel} -color Gold /axi_top/axiif/ARSIZE
add wave -noupdate -expand -group {Read address channel} -color Gold /axi_top/axiif/ARVALID
add wave -noupdate -expand -group {Read address channel} -color Gold /axi_top/axiif/ARREADY
add wave -noupdate -expand -group {Read data channel} -color Magenta /axi_top/axiif/RDATA
add wave -noupdate -expand -group {Read data channel} -color Magenta /axi_top/axiif/RRESP
add wave -noupdate -expand -group {Read data channel} -color Magenta /axi_top/axiif/RVALID
add wave -noupdate -expand -group {Read data channel} -color Magenta /axi_top/axiif/RLAST
add wave -noupdate -expand -group {Read data channel} -color Magenta /axi_top/axiif/RREADY
add wave -noupdate /axi_top/TEST/test
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {545 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 100
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {504 ns} {644 ns}
