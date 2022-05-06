
///All AI machinery heat production is multiplied by this value
#define AI_TEMPERATURE_MULTIPLIER 8 //Thermodynamics? No... No I don't think that's a thing. Balance so we don't use an insane amount of power to produce noticeable heat
///Temperature limit of all AI machinery
#define AI_TEMP_LIMIT 283.15 //10C, much hotter than a normal server room for leniency :)


///How many ticks can an AI data core store? When this amount of ticks have passed while it's in an INVALID state it can no longer be used by an AI
#define MAX_AI_DATA_CORE_TICKS 45
///How much power does the AI date core use while being in a valid state. This is also the base heat output. (Divide by heat capacity to get actual temperature increase)
#define AI_DATA_CORE_POWER_USAGE 7500

///How many ticks can an expanion bus store. If it reaches 0  the resources will no longer be available.
#define MAX_AI_EXPANSION_TICKS 15
///How much power does a CPU card consume per tick?
#define AI_BASE_POWER_PER_CPU 1500
///Multiplied by number of cards to see power consumption per tick. Added to by powerconsumption of CPUs
#define AI_POWER_PER_CARD 750


//AI Project Categories.
#define AI_PROJECT_HUDS "Sensor HUDs"
#define AI_PROJECT_CAMERAS "Visiblity Upgrades"
#define AI_PROJECT_INDUCTION "Induction"
#define AI_PROJECT_SURVEILLANCE "Surveillance"
#define AI_PROJECT_MISC "Misc."
//Update this list if you add any new ones, else the category won't show up in the UIs
GLOBAL_LIST_INIT(ai_project_categories, list(
	AI_PROJECT_HUDS,
	AI_PROJECT_CAMERAS,
	AI_PROJECT_SURVEILLANCE,
	AI_PROJECT_INDUCTION,
	AI_PROJECT_MISC
))

///How much is the AI download progress increased by per tick? Multiplied by a modifer on the AI if they have upgraded. Need to reach 100 to be downloaded
#define AI_DOWNLOAD_PER_PROCESS 0.75
///Check for tracked individual coming into view every X ticks
#define AI_CAMERA_MEMORY_TICKS 15
