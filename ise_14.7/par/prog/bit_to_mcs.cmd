rem promgen -w -p mcs -c FF -o "C:\CAD_HTSYS\SDR\fpga\ddr3_c1_test\my_ddr3\example_design\par\mcs\1.mcs" -s 65536 -u 4001 "C:\CAD_HTSYS\SDR\fpga\ddr3_c1_test\my_ddr3\example_design\par\example_top.bit" 
rem promgen -w -p mcs -c FF -o "C:\CAD_HTSYS\SDR\fpga\ddr3_c1_test\my_ddr3\example_design\par\mcs\example_top.mcs" -s 65536 -u 0 "C:\CAD_HTSYS\SDR\fpga\ddr3_c1_test\my_ddr3\example_design\par\example_top.bit" 
promgen -w -p mcs -c FF -o example_top.mcs -s 65536 -u 0 example_top.bit
