opCodes = { "AND":"000000",
            "OR":"000001",
            "XOR":"000010",
            "NOR":"000011",
            "NOT":"000100",
            "XNOR":"000101",
            "NAND":"000110",
            "NEG":"000111",
            "ADD":"010000",
            "SUB":"010001",
            "MUL":"010010",
            "FADD":"010011",
            "FSUB":"010100",
            "FMUL":"010101",
            "LD":"010110",
            "ST":"010111" }

addops=["ADD","SUB"]
faddops=["FADD","FSUB"]
luops=["AND","OR","NAND","NOR","XOR","XNOR","NEG","NOT"]
memops=["LD","ST"]

delay_unit = {"ADD":5,
            "MUL":14,
            "FADD":5,
            "FMUL":26,
            "LU":1,
            "MEM":1 }

def readInstr(fname):
    with open(fname,"r",encoding="utf-8") as file:
        instr=file.readlines()

    # get instructions from file
    for i in range(len(instr)):
        instr[i]=instr[i].rstrip("\n")

    # print("Instructions: ",instr)
    return instr

def getOperation(instr):
    return(instr.split(" ")[0])

def getDestReg(instr):
    return((instr.split(" ")[1]).split(",")[0])

def getSrcReg(instr):
    return((instr.split(" ")[1]).split(",")[1:])

def getBin(num):
    return str((bin(int(num))[2:]).zfill(5))

def getBinAddr(num):
    # print(num)
    return str((bin(int(num))[2:]).zfill(21))

def getAddr(instr):
    return((instr.split(" ")[1]).split(",")[1][1:])

def getBinInstr(instr):
    binInstr=""
    operation=getOperation(instr)
    if(operation=="NOP"):
        binInstr = 32*"1"
        return binInstr

    elif(operation=="LD" or operation=="ST"):
        binInstr += opCodes[operation]
        binInstr += getBin(getDestReg(instr)[1:])
        binInstr += getBinAddr(getAddr(instr))
        return binInstr

    destreg = getDestReg(instr)
    srcreg = getSrcReg(instr)
  
    binInstr += opCodes[operation]
    binInstr += getBin(destreg[1:])
    for each in srcreg:
        binInstr += getBin(each[1:])

    binInstr += ("0"*11)
    return binInstr

def checkWAW(destReg,test):
    for i in range(len(destReg)):
        for j in range(i+1,len(destReg)):
            if destReg[i]==destReg[j]:
                test[i]["outdep"].append(j)
                test[j]["indep"].append(i)
    return test

def checkWAR(destReg,srcReg,test):
    for i in range(len(test)):
        for j in range(i+1,len(test)):
            if destReg[j] in srcReg[i]:
                if j not in test[i]["outdep"]:
                    test[i]["outdep"].append(j)
                if i not in test[j]["indep"]:
                    test[j]["indep"].append(i)
    return test

def checkRAW(destReg,srcReg,test):
    for i in range(len(test)):
        for j in range(i+1,len(test)):
            if destReg[i] in srcReg[j]:
                if j not in test[i]["outdep"]:
                    test[i]["outdep"].append(j)
                if i not in test[j]["indep"]:
                    test[j]["indep"].append(i)
    return test

def getReadyInstr(test,avail_index):
    readyInstr=[]
    for each in avail_index:
        if(len(test[each]["indep"])==0):
            readyInstr.append(each)
    return readyInstr


# get inststructions that are gong to be in the batch
def getCorrectInstr(readyInstr,test):
    delay=0
    units={
        "ADD":None,
        "FADD":None,
        "MUL":None,
        "FMUL":None,
        "LU":None,
        "MEM":None
    }
    for i in range(len(readyInstr)):
        # if functional unit is asked in instruction and its free then assign that to use
        if test[readyInstr[i]]["opName"] in addops and units["ADD"] is None:
            units["ADD"] = readyInstr[i]
            delay = max(delay,delay_unit["ADD"])

        elif test[readyInstr[i]]["opName"] in faddops and units["FADD"] is None:
            units["FADD"]=readyInstr[i]
            delay=max(delay,delay_unit["FADD"])

        elif test[readyInstr[i]]["opName"]=="MUL" and units["MUL"] is None:
            units["MUL"]=readyInstr[i]
            delay=max(delay,delay_unit["MUL"])

        elif test[readyInstr[i]]["opName"]=="FMUL" and units["FMUL"] is None:
            units["FMUL"]=readyInstr[i]
            delay=max(delay,delay_unit["FMUL"])

        elif test[readyInstr[i]]["opName"] in luops and units["LU"] is None:
            units["LU"]=readyInstr[i]
            delay=max(delay,delay_unit["LU"])

        elif test[readyInstr[i]]["opName"] in memops and units["MEM"] is None:
            units["MEM"]=readyInstr[i]
            delay=max(delay,delay_unit["MEM"])

    execInstr = []
    print(f"Delay={delay}")
    for each in units:
        if units[each]!=None:
            execInstr.append(units[each])
            
    return execInstr,delay


# adding extra NOP for remaining indexes in binary arr..
def getCorrectBinInstr(execInstr,test):
    execBinInstr=[]
    for each in execInstr:
        execBinInstr.append(test[each]["binInstr"])

    for i in range(0,6-len(execInstr)):
        execBinInstr.append(32*"1")

    return execBinInstr


# remove instruciotn which has been already executed...
def removeExecInstrFromDep(execInstr,test,avail_index):
    for each in execInstr:
        avail_index.remove(each)

    for i in range(len(test)):
        for each in execInstr:
            if each in test[i]["indep"]:
                test[i]["indep"].remove(each)
    return test





instr_list=readInstr("instructions.txt")

test=[]
ctr=0
for each in instr_list:
    try1={}
    try1["indep"] = []
    try1["outdep"] = []
    try1["instr"] = each
    try1["binInstr"] = getBinInstr(each)
    try1["opName"] = getOperation(each)
    try1["instrNum"]=ctr
    if try1["opName"]=="LD" or try1["opName"]=="ST":
        try1["srcReg"]=[]
    try1["srcReg"]=getSrcReg(each)
    try1["destReg"]=getDestReg(each)
    test.append(try1)
    ctr+=1

all_destReg = []
all_srcReg=[]
for each in test:
    # print(each["destReg"])
    all_destReg.append(each["destReg"])
    all_srcReg.append(each["srcReg"])

print(f"\n Total Destination Registers = {all_destReg}")
print(f" Total Source Registers = {all_srcReg}")

test=checkWAW(all_destReg,test)
test=checkWAR(all_destReg,all_srcReg,test)
test=checkRAW(all_destReg,all_srcReg,test)
avail_index=[i for i in range(len(test))]

delay_total=0
allBatches=[]
count=1

while len(avail_index):
    print("\n\n")
    print(f"Batch {count}")
    count+=1
    print(f" Available Instructions = {avail_index}")
    
    readyInstr=getReadyInstr(test,avail_index)
    print(f"Ready Instructions = {readyInstr}")

    execInstr,batch_delay=getCorrectInstr(readyInstr,test)
    delay_total+=batch_delay
    print(f"Executable Instruction = {execInstr}")

    execBinInstr=getCorrectBinInstr(execInstr,test)

    print(f"Executable Binary Instructions = {execBinInstr}")
    allBatches.append(execBinInstr)

    test=removeExecInstrFromDep(execInstr,test,avail_index)

print(f"\n\nTotal batchs in binary = {allBatches}")
with open("bininstr.txt","w",encoding="utf-8") as file:
    for i in range(0,len(allBatches)):
        for each in allBatches[i]:
            file.write(f"{each},")
        file.write("\n")
    

print(f"\n\nTotal Delay in Executing all Instructions = {delay_total} cc")

