#define ANTAG_DATUM_VAMPIRE			/datum/antagonist/vampire
#define ANTAG_DATUM_THRALL			/datum/antagonist/thrall
#define ANTAG_DATUM_SLING			/datum/antagonist/shadowling
#define ANTAG_DATUM_DARKSPAWN		/datum/antagonist/darkspawn
#define ANTAG_DATUM_VEIL			/datum/antagonist/veil
#define ANTAG_DATUM_INFILTRATOR		/datum/antagonist/infiltrator
#define ANTAG_DATUM_HIJACKEDAI		/datum/antagonist/hijacked_ai
#define ANTAG_DATUM_SINFULDEMON		/datum/antagonist/sinfuldemon

#define NOT_DOMINATING			-1
#define MAX_LEADERS_GANG		3
#define INITIAL_DOM_ATTEMPTS	3

//king staff
#define IS_KING(mob) (mob?.mind?.has_antag_datum(/datum/antagonist/king))
#define IS_SERVANT(mob) (mob?.mind?.has_antag_datum(/datum/antagonist/servant))
#define IS_KNIGHT(mob) (mob?.mind?.has_antag_datum(/datum/antagonist/servant/knight))