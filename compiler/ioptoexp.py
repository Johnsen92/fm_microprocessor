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
	
	opcode_entry = re.search(op_string+"\s*([01]+)\n",file_content)
	if opcode_entry:
		opcode = opcode_entry.group(1)
	else:
		print("Syntax error: Operation " + op_string + " not found")
	
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
	
	regcode_entry = re.search(reg_string+"\s*([01]+)\n",file_content)
	if regcode_entry:
		regcode = regcode_entry.group(1);
	else:
		print("Syntax error: Register " + reg_string + " not found")
	
	# Close files
	file.close()
	
	return regcode
	
def replace_imm(imm_string, imm_type):
	
	num_sys = imm_string[1];
	
	if num_sys != 'd' and num_sys != 'b' and num_sys != 'x':
		print("Syntax error: Unknown numeric system: " + num_sys)
	
	if num_sys == 'b':
		imm_int	= int(imm_string.replace("0b",""), 2)
	elif num_sys == 'd':
		imm_int = int(imm_string.replace("0d",""))
	elif num_sys == 'x':
		imm_int = int(imm_string.replace("0x",""), 16)
	else
		print("Syntax error: Could not interpret immediate " + imm_string)
	
	if imm_type == 'I' and imm_int >= 2048:
		print("Numeric error: immediate " + str(imm_int) + " out of range (max 2047)")
	else:
		bin_string = "{0:b}".format(imm_int) 
	
	if imm_type == 'A' and imm_int >= 2097152:
		print("Numeric error: address " + str(imm_int) + " out of range (max 2097151)")
	else:
		return "{0:b}".format(imm_int)
	
# Check if parameters are correct
if len(sys.argv) != 2:
	print("usage: python " + sys.argv[0] + " <file_name>")
	sys.exit(1)	

# Get file name from arguments
file_name = sys.argv[1]
	
# Look for files in the current directory
source_file = open(file_name, 'r+')
binary_file = open(file_name.replace(".fmu",".b"), 'w')

print(file_name)
line_count = 0		
		
for line in source_file:
	op_string = re.findall("^\s*[a-zA-Z\_]+\s",line.rstrip())
	reg_string = re.findall("(r[0-9]{1,2})|([yz]\_[LH])",line.rstrip())
	imm_string = re.findall("(?:0x|0b|0d)[0-9A-Fa-f]+",line.rstrip())
	
	# parse operation
	if len(op_string) == 0:
		print("Line " + str(line_count) + ": syntax error")
	else:
		op = op_string[0].replace(" ","").replace("\t","")
		print(replace_op(op))
		# binary_file.write(replace_op(op))
	
	# parse register
	if reg_string:
		for reg_inst in reg_string:
			reg = reg_inst[0].replace(" ","").replace("\t","")
			print(replace_reg(reg))
			# print("REG: " + reg[0] + " ")
	
	# parse immediate
	if imm_string:
		print(replace_imm(imm_string[0]))
			
	print("\n")
	line_count = line_count + 1;

	
source_file.close()
binary_file.close()

