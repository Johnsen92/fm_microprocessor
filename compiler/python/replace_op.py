import re

# Generate a binary file of the isoOP_ObjPool (not needed at the moment)
def replace_op(op_string):

	replace_filename = "opcode.txt"
	
	# Open files
	opcode_file = open(replace_filename,"r")
	
	# Read file content
	opcode_file_content = opcode_file.read();
	
	opcode_entry = re.findall(op_string+"\s*([01]+)\n")
	if opcode_entry:
		print(opcode_entry[0])
	
	# Close files
	opcode_file.close()
	
	return "ss"