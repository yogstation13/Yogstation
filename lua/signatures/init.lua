local ffi = require "ffi"
ffi.cdef [[
typedef Value(*CallGlobalProc)(char unk1, int unk2, int proc_type, unsigned int proc_id, int const_0, char unk3, int unk4, Value* argList, unsigned int argListLen, int const_0_2, int const_0_3);
typedef Value(*Text2PathPtr)(unsigned int text);
typedef unsigned int(*GetStringTableIndex)(const char* string, int handleEscapes, int duplicateString);
typedef void(*SetVariablePtr)(Value datum, unsigned int varNameId, Value newvalue);
typedef Value(*ReadVariablePtr)(Value datum, unsigned int varNameId);
typedef Value(*CallProcPtr)(int unk1, int unk2, unsigned int proc_type, unsigned int proc_name, unsigned char datumType, unsigned int datumId, Value* argList, unsigned int argListLen, int unk4, int unk5);
typedef IDArrayEntry*(*GetIDArrayEntryPtr)(unsigned int index);
typedef int(*ThrowDMErrorPtr)(const char* msg);
typedef ProcArrayEntry*(*GetProcArrayEntryPtr)(unsigned int index);
typedef List*(*GetListArrayEntryPtr)(unsigned int index);
typedef void(*AppendToContainerPtr)(unsigned char containerType, int containerValue, unsigned char valueType, int newValue);
typedef void(*RemoveFromContainerPtr)(unsigned char containerType, int containerValue, unsigned char valueType, int newValue);
typedef String*(*GetStringTableIndexPtr)(int stringId);
typedef unsigned int(*Path2TextPtr)(unsigned int pathType, unsigned int pathValue);
typedef Type*(*GetTypeTableIndexPtr)(unsigned int typeIndex);
typedef unsigned int*(*MobTableIndexToGlobalTableIndex)(unsigned int mobTypeIndex);
typedef Value(*GetAssocElement)(unsigned int listType, unsigned int listId, unsigned int keyType, unsigned int keyValue);
typedef void(*SetAssocElement)(unsigned int listType, unsigned int listId, unsigned int keyType, unsigned int keyValue, unsigned int valueType, unsigned int valueValue);
typedef unsigned int(*CreateList)(unsigned int reserveSize);
typedef Value(*New)(Value* type, Value* args, unsigned int num_args, int unknown);
typedef void(*TempBreakpoint)();
typedef void(*CrashProc)(char* error, int argument);
typedef AnotherProcState*(*ResumeIn)(ExecutionContext* ctx, float deciseconds);
typedef void(*SendMapsPtr)(void);

bool QueryPerformanceFrequency(long long *lpFrequency);
bool QueryPerformanceCounter(long long *lpPerformanceCount);
]]

return require("signatures." .. (jit.os):lower())
