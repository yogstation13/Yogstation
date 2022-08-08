
///All AI machinery heat production is multiplied by this value
#define AI_TEMPERATURE_MULTIPLIER 5 //Thermodynamics? No... No I don't think that's a thing. Balance so we don't use an insane amount of power to produce noticeable heat
///Temperature limit of all AI machinery
#define AI_TEMP_LIMIT 288.15 //15C, much hotter than a normal server room for leniency :)


///How many ticks can an AI data core store? When this amount of ticks have passed while it's in an INVALID state it can no longer be used by an AI
#define MAX_AI_DATA_CORE_TICKS 45
///How much power does the AI date core use while being in a valid state. This is also the base heat output. (Divide by heat capacity to get actual temperature increase)
#define AI_DATA_CORE_POWER_USAGE 7500
///How many ticks can an expanion bus store. If it reaches 0  the resources will no longer be available.
#define MAX_AI_EXPANSION_TICKS 15


//AI Project Categories.
#define AI_PROJECT_HUDS "Sensor HUDs"
#define AI_PROJECT_CAMERAS "Visiblity Upgrades"
#define AI_PROJECT_INDUCTION "Induction"
#define AI_PROJECT_SURVEILLANCE "Surveillance"
#define AI_PROJECT_EFFICIENCY "Efficiency"
#define AI_PROJECT_MISC "Misc."
//Update this list if you add any new ones, else the category won't show up in the UIs
GLOBAL_LIST_INIT(ai_project_categories, list(
	AI_PROJECT_HUDS,
	AI_PROJECT_CAMERAS,
	AI_PROJECT_SURVEILLANCE,
	AI_PROJECT_INDUCTION,
	AI_PROJECT_EFFICIENCY,
	AI_PROJECT_MISC
))

///How much is the AI download progress increased by per tick? Multiplied by a modifer on the AI if they have upgraded. Need to reach 100 to be downloaded
#define AI_DOWNLOAD_PER_PROCESS 0.9
///Check for tracked individual coming into view every X ticks
#define AI_CAMERA_MEMORY_TICKS 15


//AI hardware
#define AI_CPU_BASE_POWER_USAGE 1250

#define AI_RAM_POWER_USAGE 500

//Needs UI change to properly work!
#define AI_MAX_CPUS_PER_RACK 4
//Needs UI change to properly work!
#define AI_MAX_RAM_PER_RACK 4

///How many AI research points does 1 THz generate?
#define AI_RESEARCH_PER_CPU 7.5

//How long between each data core being able to send a warning. Wouldn't want any spam if we had jittery temps would we?
#define AI_DATA_CORE_WARNING_COOLDOWN (5 MINUTES)


//Self explanatory. 1 bitcoin is equals to 1 CPU * AI_RESEARCH_PER_CPU
//EXAMPLE (with initial values as of feature introduction)
//20 free CPU. 10 are used for research, 10 are used for bitcoin
//10 * AI_RESEARCH_PER_CPU = 85 bitcoin per tick. Modified for scaling 85*0.54=46
//46 * AI_BITCOIN_PRICE = 2,3 credits per 2 seconds (2070 credits per 30 min)
#define MAX_AI_BITCOIN_MINED_PER_TICK 350
//Self explanatory, see MAX_AI_BITCOIN_MINED_PER_TICK * this = max money 1 AI can contribute per tick. (17,5 credits every 2 seconds, max 63k over 2 hours)
#define AI_BITCOIN_PRICE 0.05
