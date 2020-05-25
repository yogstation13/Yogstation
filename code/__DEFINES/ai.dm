//Bitflags for AI relay stuff
#define POWER_MANIPULATION		(1<<0)
#define ENVIROMENTAL_CONTROL	(1<<1)
#define DOOR_CONTROL			(1<<2)
#define TELECOMMS_CONTROL		(1<<3)
#define MACHINE_INTERACTION		(1<<4)

//String names for the above bitflags
GLOBAL_LIST_INIT(ai_relay_names, list(
	"[POWER_MANIPULATION]" = "Power Manipulation",
	"[ENVIROMENTAL_CONTROL]" = "Enviromental Control",
	"[DOOR_CONTROL]" = "Door Control",
	"[TELECOMMS_CONTROL]" = "Telecommunications Control",
	"[MACHINE_INTERACTION]" = "Machine Interaction",
))
