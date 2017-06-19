import re
import sys
import ctypes
import os
from os import walk

# Replace operation mnemonics with operation codes stored in opcode.txt
def replace_op(op_string):

	replace_filename = "opcode.txt"
	
	# Open files
	file = open(replace_filename,"r")
	
	# Read file content
	file_content = file.read();
	
	# Find operation code entry in file
	opcode_entry = re.search(op_string+"\s*([01]+)\n",file_content)
	if opcode_entry:
		opcode = opcode_entry.group(1)
	else:
		print("Syntax error: Operation " + op_string + " not found")
		sys.exit(-1)
	
	# Close files
	file.close()
	
	return opcode
	
# Replace register mnemonics with register codes stored in regcode.txt
def replace_reg(reg_string):

	replace_filename = "regcode.txt"
	
	# Open files
	file = open(replace_filename,"r")
	
	# Read file content
	file_content = file.read();
	
	# Find register code entry in file
	regcode_entry = re.search(reg_string+"\s*([01]+)\n",file_content)
	if regcode_entry:
		regcode = regcode_entry.group(1);
	else:
		print("Syntax error: Register " + reg_string + " not found")
		sys.exit(-1)
	
	# Close files
	file.close()
	
	return regcode
	
def replace_imm(imm_string, imm_type):
	
	# Determine numeric system of immediate
	num_sys = imm_string[1];
	
	# Check if numeric system character is valid
	if num_sys != 'd' and num_sys != 'b' and num_sys != 'x':
		print("Syntax error: Unknown numeric system: " + num_sys)
		sys.exit(-1)
	
	# Parse immediate string to integer
	if num_sys == 'b':
		imm_int	= int(imm_string.replace("0b",""), 2)
	elif num_sys == 'd':
		imm_int = int(imm_string.replace("0d",""))
	elif num_sys == 'x':
		imm_int = int(imm_string.replace("0x",""), 16)
	else:
		print("Syntax error: Could not interpret immediate " + imm_string)
		sys.exit(-1)
	
	# Check if immediate is in range
	if imm_type == 'I' and imm_int >= 2048:
		print("Numeric error: immediate " + str(imm_int) + " out of range (max 2047)")
		sys.exit(-1)
	
	if imm_type == 'J' and imm_int >= 65536:
		print("Numeric error: address " + str(imm_int) + " out of range (max 65535)")
		sys.exit(-1)
	
	# Return binary string representation of immediate
	if imm_type == 'J':
		bin_string = "{0:b}".format(imm_int) 
		while len(bin_string) < 16:
			bin_string = "0" + bin_string
		return bin_string
	elif imm_type == 'I':
		bin_string = "{0:b}".format(imm_int) 
		while len(bin_string) < 11:
			bin_string = "0" + bin_string
		return bin_string
	else:
		print("Error: unknown imm_type: " + imm_type)
		sys.exit(-1)
	
# Check if parameters are correct
if len(sys.argv) != 2:
	print("usage: python " + sys.argv[0] + " <file_name>")
	sys.exit(1)	

# Get file name from arguments
file_name = sys.argv[1]
	
# Look for files in the current directory
source_file = open(file_name, 'r+')
binary_file = open(file_name.replace(".fmu",".b"), 'w')

# Debug flag to toggle verbose mode
debug = False

line_count = 0		
		
for line in source_file:
	
	# Regular expressions for operations, registers and immediates
	op_string = re.findall("^\s*[a-zA-Z\_]+\s",line.rstrip())
	reg_string = re.findall("(r[0-9]{1,2})|([yz]\_[LH])",line.rstrip())
	imm_string = re.findall("(?:0x|0b|0d)[0-9A-Fa-f]+",line.rstrip())
	
	binary_string = ""
	
	# Parse operation
	if len(op_string) == 0:
		print("Line " + str(line_count) + ": syntax error")
		sys.exit(-1)
	else:
		op = op_string[0].replace(" ","").replace("\t","")
		if debug:
			print(replace_op(op))
		binary_string = binary_string + replace_op(op)
	
	# Parse register
	if reg_string:
		for reg_inst in reg_string:
			reg = reg_inst[0].replace(" ","").replace("\t","")
			if debug:
				print(replace_reg(reg))
			binary_string = binary_string + replace_reg(reg)
			
	
	# Parse immediate
	if imm_string:
		if len(binary_string) == 6:
			if debug:
				print(replace_imm(imm_string[0],"J"))
			binary_string = binary_string + replace_imm(imm_string[0],"J")
		if len(binary_string) == 11:
			if debug:
				print(replace_imm(imm_string[0],"I"))
			binary_string = binary_string + replace_imm(imm_string[0],"I")
	
	
	while len(binary_string) < 22:
		binary_string = binary_string + "0"
		
	binary_string = binary_string + "\n"
	
	# Write to output file
	binary_file.write(binary_string)
	line_count = line_count + 1;

	
source_file.close()
binary_file.close()

