# ----------------------------------------------------------------------------------------------------
# flash_fpga: creates PROM file and flashes it to the SPI flash attached to the FPGA
# This either flashes the file passed as an argument or uses the currently active bitfile.
# ----------------------------------------------------------------------------------------------------
proc flash_fpga args {
		
	if {[llength $args] > 0} {
		set bitfile $args
	} else {
                return -code error "Error! No bitfile was passed when calling this procedure!"
	}
	
	# create a name for the prom file to be generated by substituting .bit by .mcs
	set promfile [string replace $bitfile [string length $bitfile]-3 [string length $bitfile] mcs]

	puts stdout "Generating PROM file $promfile..."
	# first, generate a PROM file from the bitfile passed as an argument
	# use catch to capture the program's output
	catch {exec promgen -spi -w -p mcs -o $promfile -s 8192 -u 0 $bitfile} result
	puts stdout $result

	puts stdout "Generating batch file for iMPACT..."
	# now, create a batch file for iMPACT
	if {[catch {
		set fh [open impact_batch.cmd w]
			puts $fh "setMode -bs"
			puts $fh "setCable -port usb21 -baud 6000000"
			puts $fh "addDevice -p 1 -file $bitfile"
			puts $fh "attachflash -position 1 -spi \"N25Q64\""
			puts $fh "assignfiletoattachedflash -position 1 -file $promfile"
			puts $fh "program -p 1 -dataWidth 1 -spionly -e -loadfpga"
			puts $fh "quit"
		close $fh
        } res ] } {
           return -code error $res
        }

	puts "Running iMPACT to flash the PROM file..."
	# finally, flash the bitfile to the SPI flash on the board
	# iMPACT is stupid, because it always exits with a return code > 0, even
	# if everything is OK. So catch is needed here to capture the output and prevent the shell from exiting
	catch {exec impact -batch impact_batch.cmd} result
	puts stdout $result
	
	# delete the batch file after use
	file delete -force impact_batch.cmd
}
