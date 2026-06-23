opcode = {
    "R_TYPE":      "01100",
    "LOADI":       "00001",
    "LOAD":        "00010",
    "STORE":       "00011",
    "JUMP":        "00100",
    "LSH":         "00110",
    "RSH":         "00111",
    "BOV":         "01000",
    "SLT":         "01001",
    "BEQ":         "01101",
    "BNE":         "01110"
}


func = {
    "ADD": "0000",
    "SUB": "0001",
    "MUL": "0010",
    "DIV": "0011",
    "AND": "0100",
    "OR":  "0101",
    "NOT": "0110",
    "XOR": "0111",
}


registers = {}
for x in range (0,32):
    registers.update({"R" + f"{x}" : x})

def parse_instruction(instruction):
    # of format for eg ADD R0 R1 R2                  
    parsed_instruction = instruction.split()
    return parsed_instruction


def convert_to_five_bit_binary (reg):           #NO OF VALS FOR REGS = 32
    if reg in registers.keys():
        reg_no = int(registers.get(reg))
        first_digit = int(reg_no/16)
        second_digit = int((reg_no - first_digit*16)/8)
        third_digit = int((reg_no - first_digit*16 - second_digit*8)/4)
        fourth_digit = int((reg_no - first_digit*16 - second_digit*8 - third_digit*4)/2)
        fifth_digit = int((reg_no - first_digit*16 - second_digit*8 - third_digit*4 - fourth_digit*2)/1)
        return str(first_digit) + str(second_digit) + str(third_digit) + str (fourth_digit) + str(fifth_digit)
    else: 
        raise ValueError(f"Invalid register: {reg}")
    

def convert_to_nine_bit_binary(num):      
    num = int(num)
    if not (-64 <= num <= 63):
        raise ValueError("Immediate out of range: must be between -64 and 63 inclusive")
    
    # two's complement in 8 bits, then prepend 0 for the 9th padding bit
    return f"0{num & 0xFF:08b}"


def binary_instruction (inst):

    parsed = parse_instruction(inst)

    if ( #RTYPE:- COMMAND R1 R2 R3 FUNC
        parsed[0] == "ADD" or 
        parsed[0] == "SUB" or 
        parsed[0] == "MUL" or 
        parsed[0] == "DIV" or 
        parsed[0] == "AND" or 
        parsed[0] == "OR" or 
        parsed[0] == "NOT" or 
        parsed[0] == "XOR"
    ):
        opcode_inst = opcode.get("R_TYPE") #R-TYPE:- OPCODE RS RT RD FUNC
        func_inst = func.get(parsed[0])
        return opcode_inst + convert_to_five_bit_binary(parsed[1]) + convert_to_five_bit_binary(parsed[2])+ convert_to_five_bit_binary(parsed[3]) + func_inst

    elif parsed[0] == "LOADI": #I-TYPE:- COMMAND RS IMMEDIATE
        opcode_inst = opcode.get(parsed[0])
        return opcode_inst + convert_to_five_bit_binary(parsed[1]) + "00000" + convert_to_nine_bit_binary(parsed[2])

    elif parsed[0] == "LOAD":  #I-TYPE:- COMMAND RS RT IMMEDIATE:-  RS IS ADDRESS, (ADDRESS + OFFSET) RT IS DESTINATION
        opcode_inst = opcode.get(parsed[0])
        return opcode_inst + convert_to_five_bit_binary(parsed[1]) + convert_to_five_bit_binary(parsed[2]) + convert_to_nine_bit_binary(parsed[3])
    
    elif parsed[0] == "STORE": #I-TYPE:- COMMAND RS RT IMMEDIATE:-  
        opcode_inst = opcode.get(parsed[0])
        return opcode_inst + convert_to_five_bit_binary(parsed[1]) + convert_to_five_bit_binary(parsed[2]) + convert_to_nine_bit_binary(parsed[3])

    elif parsed[0] == "JUMP":  #J-TYPE:- OPCODE IMMEDIATE
        opcode_inst = opcode.get(parsed[0])
        return opcode_inst + 10*"0" + convert_to_nine_bit_binary(parsed[1])
    
    elif parsed[0] == "LSH":
        opcode_inst = opcode.get(parsed[0])
        return opcode_inst + convert_to_five_bit_binary(parsed[1]) + convert_to_five_bit_binary(parsed[2]) + convert_to_five_bit_binary(parsed[3]) + "0000"
    
    elif parsed[0] == "RSH":
        opcode_inst = opcode.get(parsed[0])
        return opcode_inst + convert_to_five_bit_binary(parsed[1]) + convert_to_five_bit_binary(parsed[2]) + convert_to_five_bit_binary(parsed[3]) + "0000"
    
    elif parsed[0] == "BOV":
        opcode_inst = opcode.get(parsed[0])
        return opcode_inst + convert_to_five_bit_binary(parsed[1]) + convert_to_five_bit_binary(parsed[2]) + convert_to_nine_bit_binary(parsed[3])

    elif parsed[0] == "SLT":
        opcode_inst = opcode.get(parsed[0])
        return opcode_inst + convert_to_five_bit_binary(parsed[1]) + convert_to_five_bit_binary(parsed[2]) + convert_to_five_bit_binary(parsed[3]) + "0000"
    
    elif parsed[0] == "BEQ":
        opcode_inst = opcode.get(parsed[0])
        return opcode_inst + convert_to_five_bit_binary(parsed[1]) + convert_to_five_bit_binary(parsed[2]) + convert_to_nine_bit_binary(parsed[3])

    elif parsed[0] == "BNE":
        opcode_inst = opcode.get(parsed[0])
        return opcode_inst + convert_to_five_bit_binary(parsed[1]) + convert_to_five_bit_binary(parsed[2]) + convert_to_nine_bit_binary(parsed[3])
    
    else:
        print("Invalid syntax")
        return

if __name__ == "__main__":
    while True:
        try:
            line = input("Enter instruction (or 'exit'): ")
            if line.strip().lower() == "exit":
                break
            print(binary_instruction(line))
        except Exception as e:
            print("Error:", e)
