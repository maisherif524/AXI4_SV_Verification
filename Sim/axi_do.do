##vlog *.sv *.v +define+HIGH_DEBUG_MODE +cover -covercells
vlog -f file.list +define=+LOW_DEBUG_MODE +cover -covercells
vsim -voptargs=+acc work.axi_top -cover
coverage save -onexit coverage.ucdb
do wave.do
run -all
do waiver.do
coverage report -details -output coverage_report.txt
vcover report -html -output cov_report coverage.ucdb

