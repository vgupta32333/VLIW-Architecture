# this file parses binary instructions from a text file(bininstr.txt),creates a testbench and executes the operations by calling the appropriate verilog modules
import os
opCodes = { "000000":"AND",
            "000001":"OR",
            "000010":"XOR",
            "000011":"NOR",
            "000100":"NOT",
            "000101":"XNOR",
            "000110":"NAND",
            "000111":"NEG",
            "010000":"ADD",
            "010001":"SUB",
            "010010":"MUL",
            "010011":"FADD",
            "010100":"FSUB",
            "010101":"FMUL",
            "010110":"LD",
            "010111":"ST",
            "111111":"NOP" }

regCodes = {"00000":"R0",
            "00001":"R1",
            "00010":"R2",
            "00011":"R3",
            "00100":"R4",
            "00101":"R5",
            "00110":"R6",
            "00111":"R7",
            "01000":"R8",
            "01001":"R9",
            "01010":"R10",
            "01011":"R11",
            "01100":"R12",
            "01101":"R13",
            "01110":"R14",
            "01111":"R15",
            "10000":"R16",
            "10001":"R17",
            "10010":"R18",
            "10011":"R19",
            "10100":"R20",
            "10101":"R21",
            "10110":"R22",
            "10111":"R23",
            "11000":"R24",
            "11001":"R25",
            "11010":"R26",
            "11011":"R27",
            "11100":"R28",
            "11101":"R29",
            "11110":"R30",
            "11111":"R31"}

regFile = {
    "R0":"0000000000000000000000000000000000000000000000000000000000000000",
    "R1":"0000000000000000000000000000000000000000000000000000000000000000",
    "R2":"0000000000000000000000000000000000000000000000000000000000000011",
    "R3":"0000000000000000000000000000000000000000000000000000000000000001",
    "R4":"0000000000000000000000000000000000000000000000000000000000000000",
    "R5":"0000000000000000000000000000000000000000000000000000000000000000",
    "R6":"0000000000000000000000000000000000000000000000000000000000001000",
    "R7":"0000000000000000000000000000000000000000000000000000000000000000",
    "R8":"0000000000000000000000000000000000000000000000000000000000000000",
    "R9":"0000000000000000000000000000000000000000000000000000000000000000",
    "R10":"0100000000000000000000000000000000000000000000000000000000000000",
    "R11":"0100000000010100000000000000000000000000000000000000000000000000",
    "R12":"0000000000000000000000000000000000000000000000000000000000000000",
    "R13":"0000000000000000000000000000000000000000000000000000000000000000",
    "R14":"0000000000000000000000000000000000000000000000000000000000000000",
    "R15":"0000000000000000000000000000000000000000000000000000000000000000",
    "R16":"0000000000000000000000000000000000000000000000000000000000000000",
    "R17":"0000000000000000000000000000000000000000000000000000000000000000",
    "R18":"0000000000000000000000000000000000000000000000000000000000000000",
    "R19":"0000000000000000000000000000000000000000000000000000000000000000",
    "R20":"0000000000000000000000000000000000000000000000000000000000000000",
    "R21":"0000000000000000000000000000000000000000000000000000000000000000",
    "R22":"0000000000000000000000000000000000000000000000000000000000000000",
    "R23":"0000000000000000000000000000000000000000000000000000000000000000",
    "R24":"0000000000000000000000000000000000000000000000000000000000000000",
    "R25":"0000000000000000000000000000000000000000000000000000000000000000",
    "R26":"0000000000000000000000000000000000000000000000000000000000000000",
    "R27":"0000000000000000000000000000000000000000000000000000000000000000",
    "R28":"0000000000000000000000000000000000000000000000000000000000000000",
    "R29":"0000000000000000000000000000000000000000000000000000000000000010", # 2
    "R30":"0000000000000000000000000000000000000000000000000000000000000010", # 2
    "R31":"0000000000000000000000000000000000000000000000000000000000000000" } 

logicOps = {"XNOR":"110",
            "NEG":"111",
            "AND":"000",
            "OR":"001",
            "XOR":"100",
            "NOT":"011",
            "NAND":"101",
            "NOR":"010" }


def readMem(loc):
    with open ("memory.txt","r",encoding="utf-8") as file:
        data=file.readlines()

    for i in range(len(data)):
        data[i]=data[i][:-1]
    
    return data[loc]

# this will be used in STR instruciton..
def writeMem(loc,res):
    with open ("memory.txt","r",encoding="utf-8") as file:
        data=file.readlines()

    for i in range(len(data)):
        data[i]=data[i][:-1]
    data[loc]=res
    with open ("memory.txt","w",encoding="utf-8") as file:
        for each in data:
            file.write(f"{each}\n")
    return "Written"


def readResult():
    with open("results.txt","r",encoding="utf-8") as file:
        data=file.read()
        data=data[:-1]
    return data


def updateFinalVals(destReg, opName):
    with open("results.txt","r",encoding="utf-8") as file:
        data=file.read()
        data=data[:-1]
        if opName=="MUL":
            data=data[64:]
        
    regFile[destReg] = data
    


def parseInstr():
    with open("bininstr.txt","r",encoding="utf-8") as file:
        data=file.readlines()

    for i in range(len(data)):
        data[i]=data[i][:-2]
    return data



data=parseInstr()
count=1
for i in range(0,len(data)):
    print(f"\n\nBatch {count}")
    count+=1
    batch=data[i].split(",")
    print(f"Instruction batch(binary) = {batch}")
    for each in batch:
        binInstr=each
        operation = binInstr[0:6]
        destreg = binInstr[6:11]
        srcreg1 = binInstr[11:16]
        srcreg2 = binInstr[16:21]
       
        rdest1 = int(destreg,2)
        rsrc1 = int(srcreg1,2)
        rsrc2 = int(srcreg2,2)
        rdest1name = f"R{rdest1}"
        rsrc1name = f"R{rsrc1}"
        rsrc2name = f"R{rsrc2}"
        op = opCodes[operation]
        print(f"opname = {op} rdest1 = {rdest1name} rsrc1 = {rsrc1name} rsrc2 = {rsrc2name}")
        print(f"Binary for the above = {operation} {destreg} {srcreg1} {srcreg2}")

        
        tb=""

        if(op=="ADD"):
            print("This is Addition \n")
            tb=f"`include \"CED19I028_RDCLA.v\"\nmodule top;\nreg [63:0] in1, in2;\nreg cin;\nwire [63:0] sum;\nwire cout;\nRDCLA r1 (in1, in2, cin, sum, cout);\ninitial\nbegin\nin1 = 64'b{regFile[regCodes[srcreg1]]}; in2 = 64'b{regFile[regCodes[srcreg2]]}; cin = 1'b0;\nend\ninitial\n$monitor (\"%b\",sum);\nendmodule"

            with open("test.v","w",encoding='utf-8') as file:
                file.write(tb)
            os.system("iverilog test.v")
            os.system("vvp a.out > results.txt")
            updateFinalVals(regCodes[destreg],op)

        elif(op=="SUB"):
            print("This is Subtraction \n")
            tb=f"`include \"CED19I028_logicunit.v\"\nmodule logicunittb (\n);\nreg [63:0] in1,in2;\nreg [2:0] sel;\nwire [63:0] out;\n\nlogicunit l1(in1,in2,sel,out);\ninitial begin\n$monitor(\"%b\",out);\nend\ninitial begin\nsel=3'b111;\nin2=64'b{regFile[regCodes[srcreg1]]};\nin1=64'b{regFile[regCodes[srcreg2]]};\n#10;\nend\nendmodule"
            
            with open("test.v","w",encoding='utf-8') as file:
                file.write(tb)
            os.system("iverilog test.v")
            os.system("vvp a.out > results.txt")
            actualin2=readResult()
            print(f"actualin2={actualin2}")
            tb=f"`include \"CED19I028_RDCLA.v\"\nmodule top;\nreg [63:0] in1, in2;\nreg cin;\nwire [63:0] sum;\nwire cout;\nRDCLA r1 (in1, in2, cin, sum, cout);\ninitial\nbegin\nin1 = 64'b{regFile[regCodes[srcreg1]]}; in2 = 64'b{actualin2}; cin = 1'b0;\nend\ninitial\n$monitor (\"%b\",sum);\nendmodule"
          
            with open("test.v","w",encoding='utf-8') as file:
                file.write(tb)
            os.system("iverilog test.v")
            os.system("vvp a.out > results.txt")
            updateFinalVals(regCodes[destreg],op)

        elif(op in logicOps):
            print("This is logicops \n")
            tb=f"`include \"CED19I028_logicunit.v\"\nmodule logicunittb (\n);\nreg [63:0] in1,in2;\nreg [2:0] sel;\nwire [63:0] out;\n\nlogicunit l1(in1,in2,sel,out);\ninitial begin\n$monitor(\"%b\",out);\nend\ninitial begin\nsel={logicOps[op]};\nin1=64'b{regFile[regCodes[srcreg1]]};\nin2=64'b{regFile[regCodes[srcreg2]]};\n#10;\nend\nendmodule"
            
            with open("test.v","w",encoding='utf-8') as file:
                file.write(tb)
            os.system("iverilog test.v")
            os.system("vvp a.out > results.txt")
            updateFinalVals(regCodes[destreg],op)

        elif op=="LD" or op=="ST":
            print("This is MEM unit \n")
            targetAddr=binInstr[11:]
            targetAddr=int(targetAddr,2)
            if op=="LD":
                val=readMem(targetAddr)
             
                regFile[rdest1name]=val
            if op=="ST":
                valToWrite=regFile[rdest1name]
                writeMem(targetAddr,valToWrite)

        # FADD
        elif op=="FADD":
            print("This is FADD \n")
            tb=f"`include \"CED19I028_FPAdder.v\"\nmodule fpaddertb (\n);\nreg [63:0] in1,in2;\nwire [63:0] out;\nfp_adder f1(in1,in2,out);\ninitial begin\n$monitor(\"%b\",out);\nend\ninitial begin\nin2=64'b{regFile[regCodes[srcreg1]]};//-2.00\nin1=64'b{regFile[regCodes[srcreg2]]};//1.00\n#10;\nend\nendmodule"
           
            with open("test.v","w",encoding='utf-8') as file:
                file.write(tb)
            os.system("iverilog test.v")
            os.system("vvp a.out > results.txt")
            updateFinalVals(regCodes[destreg],op)

        elif op=="FMUL":
            print("This is FMUL \n")
            tb=f"`include \"CED19I028_FPMultiplier.v\"\nmodule fpmtb (\n);\nreg [63:0] in1,in2;\nwire [63:0] out;\nfpm f1(in1,in2,out);\ninitial begin\n$monitor(\"%b\",out);\nend\ninitial begin\nin2=64'b{regFile[regCodes[srcreg1]]};//-2.00\nin1=64'b{regFile[regCodes[srcreg2]]};//1.00\n#10;\nend\nendmodule"
         
            with open("test.v","w",encoding='utf-8') as file:
                file.write(tb)
            os.system("iverilog test.v")
            os.system("vvp a.out > results.txt")
            updateFinalVals(regCodes[destreg],op)

        elif op=="MUL":
            print("This is MUL \n")
            tb=f"`include \"CED19I028_wtm.v\"\nmodule wtmtb (\n);\nreg [63:0] in1,in2;\nwire [127:0] out;\nmultiplier64bit f1(in1,in2,out);\ninitial begin\n$monitor(\"%b\",out);\nend\ninitial begin\nin2=64'b{regFile[regCodes[srcreg1]]};\nin1=64'b{regFile[regCodes[srcreg2]]};\n#10;\nend\nendmodule"
          
            with open("test.v","w",encoding='utf-8') as file:
                file.write(tb)
            os.system("iverilog test.v")
            os.system("vvp a.out > results.txt")
            updateFinalVals(regCodes[destreg],op)

        elif op=="FSUB":
            print("This is FSUBL \n")
            in2=regFile[regCodes[srcreg2]]
            if in2[0]=="1":
                actualin2=f"0{in2[1:]}"
            else:
                actualin2=f"1{in2[1:]}"
            tb=f"`include \"CED19I028_FPAdder.v\"\nmodule fpaddertb (\n);\nreg [63:0] in1,in2;\nwire [63:0] out;\nfp_adder f1(in1,in2,out);\ninitial begin\n$monitor(\"%b\",out);\nend\ninitial begin\nin2=64'b{actualin2};//-2.00\nin1=64'b{regFile[regCodes[srcreg1]]};//1.00\n#10;\nend\nendmodule"
           
            with open("test.v","w",encoding='utf-8') as file:
                file.write(tb)
            os.system("iverilog test.v")
            os.system("vvp a.out > results.txt")
            updateFinalVals(regCodes[destreg],op)

print(f"\n\nFinal Register Values: \n")
[print(f" {each} = {regFile[each]}") for each in regFile]


