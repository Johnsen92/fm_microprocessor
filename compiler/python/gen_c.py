import re
import util

# Generate a binary file of the isoOP_ObjPool (not needed at the moment)
def gen_c_bin(filename):

	objectname = "isoOP_ObjPool"
	
	# Open files
	fobj_in = open(filename)
	fobj_out = open(filename + ".bin","wb")
	
	# Helper variables
	entry_list = ""
	list_length = 0
	def_start = False

	# Parse file line by line
	for line in fobj_in:
	
		# Only start parsing after start of declaration
		if re.search("ISO\_OP\_MEMORY\_CLASS isoOP\_ObjPool",line.rstrip()):
			def_start = True
		if not def_start:
			continue
			
		# Search for decimal or hex values
		entry = re.findall("(0x[A-F0-9a-f]{2})|([0-9]+)",line.rstrip())
		for e in entry:
			# Add newlines every 32 entries
			if list_length % 32 == 0 and list_length != 0 and entry_list[-1] != '\n':
				entry_list = entry_list + "\n"
			
			# Hex entry
			if e[0] != "": 
				fobj_out.write(e[0][2:4].decode("hex"))
				
			# Decimal entry
			if e[1] != "": 
				fobj_out.write(hex(int(e[1]))[2:4].decode("hex"))

	# Close files
	fobj_in.close()
	fobj_out.close()
	
# Generate an ASCII-HEX file of the isoOP_ObjPool
def gen_c_ascii(filename):

	objectname = "isoOP_ObjPool"
	
	# Open files
	fobj_in = open(filename)
	fobj_out = open(filename + ".ascii","w")
	
	# Helper variables
	entry_list = ""
	list_length = 0
	def_start = False

	# Parse file line by line
	for line in fobj_in:
	
		# Only start parsing after start of declaration
		if re.search("ISO\_OP\_MEMORY\_CLASS isoOP\_ObjPool",line.rstrip()):
			def_start = True
		if not def_start:
			continue
			
		# Search for decimal or hex values
		entry = re.findall("(0x[A-F0-9a-f]{2})|([0-9]+)",line.rstrip())
		for e in entry:
			# Add newlines every 32 entries
			if list_length % 32 == 0 and list_length != 0 and entry_list[-1] != '\n':
				entry_list = entry_list + "\n"
			
			# Hex entry
			if e[0] != "": 
				fobj_out.write(e[0][2:4])
				
			# Decimal entry
			if e[1] != "": 
				fobj_out.write(hex(int(e[1]))[2:4])

	# Close files
	fobj_in.close()
	fobj_out.close()
	
# Generate IHEX file out of the ASCII-HEX file usable by TTC-Downloader
def gen_hex(filename, start_address):

	# Extended segment address high byte
	base_address_h = 0x00	
	# Extended segment address low byte
	base_address_l = 0x00
	# Segment address high byte
	relative_address_h = 0x00	
	# Segment address low byte
	relative_address_l = 0x00
	
	addr_len = len(start_address)
	
	# Parse start_address
	start_address_value = util.s2h(start_address)
	relative_address_l = start_address_value % 0x100;
	start_address_value = (start_address_value - relative_address_l) / 0x100
	relative_address_h = start_address_value % 0x100;
	start_address_value = (start_address_value - relative_address_h) / 0x100
	base_address_l = start_address_value % 0x100;
	start_address_value = (start_address_value - base_address_l) / 0x100
	base_address_h = start_address_value % 0x100;
	start_address_value = (start_address_value - base_address_h) / 0x100
	
	# Open files 
	fobj_in = open(filename + ".ascii", "r")
	fobj_out = open(filename + ".hex","w")

	# Set extended linear address
	fobj_out.write(util.get_extended_linear_address_frame(base_address_h, base_address_l))

	byte_string = fobj_in.read(2)
	while byte_string != "":
		# Local variables
		length = 0
		data = ""
		frame = ""
		
		# Read atmost 20 bytes of file
		while byte_string != "" and length < 0x20:
			data = data + byte_string
			length = length + 1
			byte_string = fobj_in.read(2)
		
		# Assemble and write record
		frame = ":" + util.h2s(length) + util.h2s(relative_address_h) + util.h2s(relative_address_l) + "00" + data
		frame = frame + util.h2s(util.checksum(frame)) + "\n"
		fobj_out.write(frame)
		
		# Adjust address
		if relative_address_l + length > 0xFF:
			relative_address_l = (relative_address_l + length) % 0x100
			if relative_address_h + 1 > 0xFF:
				base_address_l = base_address_l + 1
				fobj_out.write(util.get_extended_linear_address_frame(base_address_h, base_address_l))
				relative_address_h = 0x00
			else:
				relative_address_h = relative_address_h + 1
		else:
			relative_address_l = relative_address_l + length

	# Write EOF
	fobj_out.write(":00000001FF")

	# Close files
	fobj_out.close()
	fobj_in.close()