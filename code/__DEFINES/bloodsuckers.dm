/**
 * Bloodsucker defines
 */
/// Determines Bloodsucker regeneration rate
#define BS_BLOOD_VOLUME_MAX_REGEN 700
/// Cost to torture someone, in blood
#define TORTURE_BLOOD_COST "15"
/// Cost to convert someone after successful torture, in blood
#define TORTURE_CONVERSION_COST "50"
/// Deals with constant processes off of LifeTick()
#define COMSIG_LIVING_BIOLOGICAL_LIFE "biological_life"
/// Once blood is this low, will enter Frenzy
#define FRENZY_THRESHOLD_ENTER 112
/// Once blood is this high, will exit Frenzy
#define FRENZY_THRESHOLD_EXIT 560
/// You have special interactions with Bloodsuckers
#define TRAIT_BLOODSUCKER_HUNTER "bloodsucker_hunter"

/**
 * Cooldown defines
 * Used in Cooldowns Bloodsuckers use to prevent spamming
 */
///Spam prevention for healing messages.
#define BLOODSUCKER_SPAM_HEALING (15 SECONDS)
///Span prevention for Sol messages.
#define BLOODSUCKER_SPAM_SOL (30 SECONDS)

/**
 * Clan defines
 */
#define CLAN_BRUJAH "Brujah Clan"
#define CLAN_NOSFERATU "Nosferatu Clan"
#define CLAN_TREMERE "Tremere Clan"
#define CLAN_VENTRUE "Ventrue Clan"
#define CLAN_MALKAVIAN "Malkavian Clan"
#define CLAN_TOREADOR "Toreador Clan"
#define CLAN_GANGREL "Gangrel Clan"
#define CLAN_LASOMBRA "Lasombra Clan"
#define CLAN_TZIMISCE "Tzimisce Clan"

#define TRIPLECHEST_MONSTER "Triple Chest (300 Blood)"
#define ARMMY_MONSTER "Armmy (100 Blood)"
#define CALCIUM_MONSTER "Calcium (150 Blood)"
#define HUSK_MONSTER "Husk"

#define TOREADOR_MAX_HUMANITY_LOSS 10

/**
 * Power defines
 */
/// This Power can't be used in Torpor
#define BP_CANT_USE_IN_TORPOR (1<<0)
/// This Power can't be used in Frenzy unless you're part of Brujah
#define BP_CANT_USE_IN_FRENZY (1<<1)
/// This Power can't be used with a stake in you
#define BP_CANT_USE_WHILE_STAKED (1<<2)
/// This Power can't be used while incapacitated
#define BP_CANT_USE_WHILE_INCAPACITATED (1<<3)
/// This Power can't be used while unconscious
#define BP_CANT_USE_WHILE_UNCONSCIOUS (1<<4)

/// This Power can be purchased by Bloodsuckers
#define BLOODSUCKER_CAN_BUY (1<<0)
/// This Power can be purchased by Lasombra Bloodsuckers
#define LASOMBRA_CAN_BUY (1<<1)
/// This Power can be purchased by Gangrel Bloodsuckers
#define GANGREL_CAN_BUY (1<<2)
/// This Power can be purchased by Vassals
#define VASSAL_CAN_BUY (1<<3)
/// This Power can be purchased by Monster Hunters
#define HUNTER_CAN_BUY (1<<4)
/// This Power can be purchased by Tzimisce Bloodsuckers
#define TZIMISCE_CAN_BUY (1<<5)

/// This Power is a Toggled Power
#define BP_AM_TOGGLE (1<<0)
/// This Power is a Single-Use Power
#define BP_AM_SINGLEUSE (1<<1)
/// This Power has a Static cooldown
#define BP_AM_STATIC_COOLDOWN (1<<2)
/// This Power doesn't cost bloot to run while unconscious
#define BP_AM_COSTLESS_UNCONSCIOUS (1<<3)

/**
 * Signals
 */

#define COMSIG_BLOODSUCKER_RANKS_SPENT