
///All AI machinery heat production is multiplied by this value
#define AI_TEMPERATURE_MULTIPLIER 5 //Thermodynamics? No... No I don't think that's a thing. Balance so we don't use an insane amount of power to produce noticeable heat
///Temperature limit of all AI machinery
#define AI_TEMP_LIMIT 288.15 //15C, much hotter than a normal server room for leniency :)

///How long the AI can stay in the black-box before it's fully destroyed
#define AI_BLACKBOX_LIFETIME 5 MINUTES
///How much CPU we need to use to revive the AI
#define AI_BLACKBOX_PROCESSING_REQUIREMENT 2500

///How many ticks can an AI data core store? When this amount of ticks have passed while it's in an INVALID state it can no longer be used by an AI
#define MAX_AI_DATA_CORE_TICKS (45 * (20 / SSair.wait))
///How much power does the AI date core use while being in a valid state. This is also the base heat output. (Divide by heat capacity to get actual temperature increase)
#define AI_DATA_CORE_POWER_USAGE 7500
///How many ticks can a server cabinet store. If it reaches 0  the resources will no longer be available.
#define MAX_AI_SERVER_CABINET_TICKS (15 * (20 / SSair.wait))


//AI Project Categories.
#define AI_PROJECT_HUDS "Sensor HUDs"
#define AI_PROJECT_CAMERAS "Visibility Upgrades"
#define AI_PROJECT_INDUCTION "Induction"
#define AI_PROJECT_SURVEILLANCE "Surveillance"
#define AI_PROJECT_EFFICIENCY "Efficiency"
#define AI_PROJECT_CROWD_CONTROL "Crowd Control"
#define AI_PROJECT_MISC "Misc."
//Update this list if you add any new ones, else the category won't show up in the UIs
GLOBAL_LIST_INIT(ai_project_categories, list(
	AI_PROJECT_HUDS,
	AI_PROJECT_CAMERAS,
	AI_PROJECT_SURVEILLANCE,
	AI_PROJECT_INDUCTION,
	AI_PROJECT_EFFICIENCY,
	AI_PROJECT_CROWD_CONTROL,
	AI_PROJECT_MISC
))

///How much is the AI download progress increased by per tick? Multiplied by a modifer on the AI if they have upgraded. Need to reach 100 to be downloaded
#define AI_DOWNLOAD_PER_PROCESS 1.125
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
#define MAX_AI_BITCOIN_MINED_PER_TICK 250
//Self explanatory, see MAX_AI_BITCOIN_MINED_PER_TICK * this = max money 1 network can contribute per tick. (17,5 credits every 2 seconds, max 63k over 2 hours)
#define AI_BITCOIN_PRICE 0.025


//Self explanatory. 1 point is equals to 1 CPU * AI_RESEARCH_PER_CPU. Higher value = can use more CPU and get benefits
#define MAX_AI_REGULAR_RESEARCH_PER_TICK 500
//Self explanatory. Lower value = more CPU equals less points. Station makes approx. 56 points per tick. This results in 25 (50% gain)
#define AI_REGULAR_RESEARCH_POINT_MULTIPLIER 0.05


//How much RAM and CPU a core needs locally to be functional
#define AI_CORE_CPU_REQUIREMENT 1
#define AI_CORE_RAM_REQUIREMENT 1 

//For network based research and tasks. Since each network are going to contribute to a "global" pool of research there's no point in making this more complicated or modular
//Adding an entry here automatically adds it to the UI and allows CPU to be allocated. Just use your define in the network process() to do stuff
#define AI_CRYPTO "Cryptocurrency Mining"
#define AI_RESEARCH "Research Assistance"
#define AI_REVIVAL "AI Restoration"
#define AI_PUZZLE "Floppy Drive Decryption"

GLOBAL_LIST_INIT(possible_ainet_activities, list(
	"[AI_CRYPTO]",
	"[AI_RESEARCH]",
	"[AI_REVIVAL]",
	"[AI_PUZZLE]"
))

GLOBAL_LIST_INIT(ainet_activity_tagline, list(
	"[AI_CRYPTO]" = "Use CPU to generate credits!",
	"[AI_RESEARCH]" = "Use CPU to generate regular research points!",
	"[AI_REVIVAL]" = "Revive a dead AI using CPU!",
	"[AI_PUZZLE]" = "Use CPU to break encryption on floppy drives!"
))

GLOBAL_LIST_INIT(ainet_activity_description, list(
	"[AI_CRYPTO]" = "Using CPU to mine NTCoin should allow for a meager sum of passive credit income.",
	"[AI_RESEARCH]" = "Allocating additional CPU to the research servers should allow for increased point gain. Not to be confused with AI Research points.",
	"[AI_REVIVAL]" = "If you've inserted a volatile neural core into a connected data core this will revive it using CPU.",
	"[AI_PUZZLE]" = "If you've found and inserted an encrypted floppy drive into a connected server cabinet you can decrypt it using CPU."
))


//Exploration defines
#define AI_FLOPPY_DECRYPTION_COST 2500
#define AI_FLOPPY_EXPONENT 1.25
