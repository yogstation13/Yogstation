///How much shitter score we remove per shitter subsystem fire
#define SHITTER_BLEEDOFF 1

#define MAX_SHITTER_SCORE 75

#define SHITTER_PLAYTIME_CUTOFF 25


#define SHITTER_ATTACK "shitter_attack"
#define SHITTER_STUN "shitter_stun"
#define SHITTER_ATMOS_ALARM "shitter_atmos_alarm"
#define SHITTER_ATMOS "shitter_atmos_deconstruct"
#define SHITTER_PRETTY_FILTER "shitter_pretty_filter"

GLOBAL_LIST_INIT(shitter_scores, list(
	"[SHITTER_ATTACK]" = 5,
	"[SHITTER_STUN]" = 3,
	"[SHITTER_ATMOS_ALARM]" = 25,
	"[SHITTER_ATMOS]" = 20,
	"[SHITTER_PRETTY_FILTER]" = 20
))
