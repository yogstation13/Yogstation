local ffi = require("ffi")
ffi.cdef [[
typedef struct String
{
	char* stringData;
	int unk1;
	int unk2;
	unsigned int refcount;
} String;

typedef struct Value {
	union {
		struct {
			char type;
			union {
				int value;
				float valuef;
			};
		};
		long long longlongman;
	};
} Value;

typedef struct IDArrayEntry {
	short size;
	int unknown;
	int refcountMaybe;
} IDArrayEntry;

typedef struct ProcArrayEntry {
	int procPath;
	int procName;
	int procDesc;
	int procCategory;
	int procFlags;
	int unknown1;
	int bytecode_idx; // ProcSetupEntry index
	int local_var_count_idx; // ProcSetupEntry index 
	int unknown2;
} ProcArrayEntry;

typedef struct List {
	Value* elements;
	int unk1;
	int unk2;
	int length;
	int refcount;
	int unk3;
	int unk4;
	int unk5;
} List;

typedef struct Type {
	unsigned int path;
	unsigned int parentTypeIdx;
	unsigned int last_typepath_part;
} Type;

typedef struct ExecutionContext ExecutionContext;

typedef struct ProcState { //rename this
	ExecutionContext* context;
	int unknown1;
	Value src;
	Value usr;
} ProcState;

typedef struct AnotherProcState {
	char unknown[0x88];
	int time_to_resume;
} AnotherProcState;

typedef struct ExecutionContext {
	ProcState* proc_state;
	ExecutionContext* parent_context;
	int dbg_proc_file;
	int dbg_current_line;
	int* bytecode;
	unsigned short current_opcode;
	Value cached_datum;
	char unknown2[8];
	int test_flag;
	char unknown3[12];
	Value* local_variables;
	Value* stack;
	short local_var_count;
	short stack_size;
	int unknown;
	Value* current_iterator;
	int iterator_allocated;
	int iterator_length;
	int iterator_index;
	char unknown3[7];
	char iterator_filtered_type;
	char unknown4;
	char iterator_unknown;
	char unknown5;
	int infinite_loop_count;
	char unknown6[2];
	bool paused;
	char unknown6[51];
} ExecutionContext;

typedef struct ProcSetupEntry {
	union {
		short local_var_count; 
		short bytecode_length;
	};
	int* bytecode;
	int unknown;
} ProcSetupEntry;

]]
-- ProcSetupEntry.local_var_count doesnt mean this proc has that many local variables
-- query the correct field in ProcArrayEntry to get correct info!
ffi.metatype(
	"Value",
	{
		__eq = function(a, b)
			if (ffi.istype("Value", b)) then
				return a.type == b.type and a.value == b.value
			elseif (type(b) == "table" and getmetatable(b) == datumM) then
				return a == b.handle
			end
			return false
		end
	}
)
