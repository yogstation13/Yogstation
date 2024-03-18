//Defines specifically for the darkspawn game mode
#define MUNDANE 0
#define DIVULGED 1
#define PROGENITOR 2

#define SCOUT (1<<0)
#define FIGHTER (1<<1)
#define WARLOCK (1<<2)
#define ALL_DARKSPAWN_CLASSES (SCOUT | FIGHTER | WARLOCK)

/// things that you use and it fucks someone up
#define STORE_OFFENSE "offense" 
///things that you use and it does something less straightforward
#define STORE_UTILITY "utility" 
///things that always happen all the time
#define STORE_PASSIVE "passives" 

#define COMSIG_DARKSPAWN_PURCHASE_POWER "purchase_power"

#define STAFF_UPGRADE_CONFUSION 	(1<<0)
#define STAFF_UPGRADE_HEAL 			(1<<1)
#define STAFF_UPGRADE_LIGHTEATER 	(1<<2)
#define STAFF_UPGRADE_EXTINGUISH	(1<<3)
