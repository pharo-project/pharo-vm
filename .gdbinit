# .gdbinit file for debugging the Pharo VM (especially with Cogit)

# ___________________________
#
# ptt - Print Trampoline Table
# ___________________________

define ptt
  call printTrampolineTable()
end

document ptt
ptt
Print the table of all trampolines compiles to machine code.
end

# ________________
#
# pf - Print Frame
# ________________

define pf
  call printFrame($arg0)
end

document pf
pf PHARO_FRAME_ADDRESS
Print the frame at the given address.
end

# ____________________________
#
# pcog - Print Cog Method Info
# ____________________________

define pcog
  set $retval = 0
  call $retval =  methodFor($arg0)
  if ($retval == (CogMethod*) 0)
    printf "No cog method at this address!\n"
  else
    call printCogMethod((CogMethod*) $arg0)
  end
end

document pcog
pcog COG_METHOD_ADDRESS
Print information on the given cog method.
end

# ____________________________________
#
# pc* - Print Cog Methods and Variants
# ____________________________________

# pcogs - Print Cog Methods
define pcogs
  call printCogMethods()
end

document pcogs
pcogs
Print all methods/caches in the code zone.
end

# pct - Print Cog Methods of Type
define pct
  call printCogMethodsOfType($arg0)
end

document pct
pct MACHINE_CODE_ELEMENT_TYPE
Print all the elements of a given type in the code zone.
The available types are:
CMFree      - 1
CMMethod    - 2
CMClosedPIC - 4
CMOpenPIC   - 5
(CMBlock is 3 but cannot be searched for!)
end

# pcp - Print Cog Methods using Primitive
define pcp
  call printCogMethodsWithPrimitive($arg0)
end

document pcp
pcp PRIMITIVE_INDEX
Print the cog methods using the given primitive index.
end

# pcm - Print Cog Methods of a Method
define pcm
  call printCogMethodsWithMethod($arg0)
end

document pcm
pcm COMPILED_METHOD_ADDRESS
Print the cog methods of a given method.
end

# pcs - Print Cog Methods for a Selector
define pcs
  call printCogMethodsWithSelector($arg0)
end

document pcs
pcs SELECTOR_ADDRESS
Print the cog methods of a given selector.
end

# _____________________________
#
# whereis - Locate in code zone
# _____________________________

define whereis
  call printWhereIs($arg0)
end

document whereis
whereis CODE_ZONE_ADDRESS
Locates the body of the enclosing method/trampoline in the code zone.
end

# _______________________________
#
# dt - Disassemble trampoline
# _______________________________

define dt
  call $retval = sizeOfTrampoline($arg0)
  call $trampname = codeEntryNameFor($arg0)
  printf "Disassembling trampoline %s:\n", $trampname
  disassemble $arg0,+$retval
end

document dt
dt TRAMPOLINE_ADDRESS OFFSET LENGTH
Disassemble the trampoline at the given address + OFFSET, ending after LENGTH.
By default OFFSET = 0 and LENGTH = trampoline length.
end

# _______________________________
#
# dc* - Disassemble cog method
# _______________________________

define dc
  set $retval = ((CogMethod*) $arg0)->blockSize
  printf "Metadata:\n"
  disassemble $arg0,+cmEntryOffset
  printf "Check:\n"
  disassemble $arg0+cmEntryOffset,+(cmNoCheckEntryOffset-cmEntryOffset)
  printf "Method:\n"
  if $argc == 2
    disassemble $arg0+cmNoCheckEntryOffset,+$arg1
  else
    disassemble $arg0+cmNoCheckEntryOffset,+($retval-cmNoCheckEntryOffset)
  end

end

document dc
dc COG_METHOD_ADDRESS LENGTH
Disassemble the cog method at the given address, starting from the beginning.
The instructions are disassembled up to the end of the method or LENGTH is given.
end

define dnc
  set $retval = ((CogMethod*) $arg0)->blockSize
  printf "Method:\n"
  if $argc == 2
    disassemble $arg0+cmNoCheckEntryOffset,+$arg1
  else
    disassemble $arg0+cmNoCheckEntryOffset,+($retval-cmNoCheckEntryOffset)
  end
end

document dnc
dnc COG_METHOD_ADDRESS LENGTH
Disassemble the cog method at the given address, jumping over the metadata and check.
The instructions are disassembled up to the end of the method or LENGTH is given.
end
