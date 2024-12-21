/*
	These defines are specific to the atom/flags_1 bitmask
*/
#define ALL (~0) //For convenience.
#define NONE 0

/* Directions */
///All the cardinal direction bitflags.
#define ALL_CARDINALS (NORTH|SOUTH|EAST|WEST)

//for convenience
#define ENABLE_BITFIELD(variable, flag) (variable |= (flag))
#define DISABLE_BITFIELD(variable, flag) (variable &= ~(flag))
#define CHECK_BITFIELD(variable, flag) (variable & (flag))
#define TOGGLE_BITFIELD(variable, flag) (variable ^= (flag))

//check if all bitflags specified are present
#define CHECK_MULTIPLE_BITFIELDS(flagvar, flags) (((flagvar) & (flags)) == (flags))

GLOBAL_LIST_INIT(bitflags, list(1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192, 16384, 32768))

// for /datum/var/datum_flags
#define DF_USE_TAG (1<<0)
#define DF_VAR_EDITED (1<<1)
#define DF_ISPROCESSING (1<<2)

//FLAGS BITMASK

/// item has priority to check when entering or leaving
#define ON_BORDER_1					(1<<1)
/// Projectiels will check ricochet on things impacted that have this.
#define CHECK_RICOCHET_1			(1<<2)
///specifies that this atom is a hologram that isnt real
#define HOLOGRAM_1					(1<<3)
///Whether /atom/Initialize(mapload) has already run for the object
#define INITIALIZED_1				(1<<4)
/// was this spawned by an admin? used for stat tracking stuff.
#define ADMIN_SPAWNED_1 			(1<<5)
/// For machines and structures that should not break into parts, eg, holodeck stuff
#define NODECONSTRUCT_1				(1<<6)
/// Prevent clicking things below it on the same turf eg. doors/ fulltile windows
#define PREVENT_CLICK_UNDER_1		(1<<7)
/// Can players recolor this in-game via vendors (and maybe more if support is added)?
#define IS_PLAYER_COLORABLE_1		(1<<8)
/// TESLA_IGNORE grants immunity from being targeted by tesla-style electricity
#define TESLA_IGNORE_1				(1<<9)
/// If a turf can be made dirty at roundstart. This is also used in areas.
#define CAN_BE_DIRTY_1				(1<<10)
/// Should we use the initial icon for display? Mostly used by overlay only objects
#define HTML_USE_INITAL_ICON_1 		(1<<11)
/// conducts electricity (metal etc.)
#define CONDUCT_1					(1<<12)
/// should not get harmed if this gets caught by an explosion?
#define PREVENT_CONTENTS_EXPLOSION_1 (1<<13)
/// should the contents of this atom be acted upon
#define RAD_PROTECT_CONTENTS_1 		(1<<14)
/// should this object be allowed to be contaminated
#define RAD_NO_CONTAMINATE_1 		(1<<15)
/// Prevents most radiation on this turf from leaving it
#define RAD_CONTAIN_CONTENTS 		(1<<16)
/// Is the thing currently spinning?
#define IS_SPINNING_1 				(1<<17)
/// If this atom has experienced a decal element "init finished" sourced appearance update
/// We use this to ensure stacked decals don't double up appearance updates for no rasin
/// Flag as an optimization, don't make this a trait without profiling
/// Yes I know this is a stupid flag, no you can't take him from me
#define DECAL_INIT_UPDATE_EXPERIENCED_1 (1<<18)

//TURF FLAGS
/// If a turf cant be jaunted through.
#define NOJAUNT						(1<<0)
/// If a turf is an usused reservation turf awaiting assignment
#define UNUSED_RESERVATION_TURF 	(1<<1)
/// If a turf is a reserved turf
#define RESERVATION_TURF 			(1<<2)
/// Blocks lava rivers being generated on the turf
#define NO_LAVA_GEN					(1<<3)
/// Blocks ruins spawning on the turf
#define NO_RUINS					(1<<4)
/// Blocks this turf from being rusted
#define NO_RUST 					(1<<5)
/// Is this turf is "solid". Space and lava aren't for instance
#define IS_SOLID 					(1<<6)
/// This turf will never be cleared away by other objects on Initialize.
#define NO_CLEARING 				(1<<7)

//AREA FLAGS
/// If blobs can spawn there and if it counts towards their score.
#define BLOBS_ALLOWED (1<<1)
/// If mining tunnel generation is allowed in this area
#define CAVES_ALLOWED (1<<2)
/// If flora are allowed to spawn in this area randomly through tunnel generation
#define FLORA_ALLOWED (1<<3)
/// If mobs can be spawned by natural random generation
#define MOB_SPAWN_ALLOWED (1<<4)
/// If megafauna can be spawned by natural random generation
#define MEGAFAUNA_SPAWN_ALLOWED (1<<5)
/// Are you forbidden from teleporting to the area? (centcom, mobs, wizard, hand teleporter)
#define NOTELEPORT (1<<6)
/// Protected from certain events
#define EVENT_PROTECTED (1<<7)

// Update flags for [/atom/proc/update_appearance]
/// Update the atom's name
#define UPDATE_NAME (1<<0)
/// Update the atom's desc
#define UPDATE_DESC (1<<1)
/// Update the atom's icon state
#define UPDATE_ICON_STATE (1<<2)
/// Update the atom's overlays
#define UPDATE_OVERLAYS (1<<3)
/// Update the atom's greyscaling
#define UPDATE_GREYSCALE (1<<4)
/// Update the atom's smoothing. (More accurately, queue it for an update)
#define UPDATE_SMOOTHING (1<<5)
/// Update the atom's icon
#define UPDATE_ICON (UPDATE_ICON_STATE|UPDATE_OVERLAYS)

/*
	These defines are used specifically with the atom/pass_flags bitmask
	the atom/checkpass() proc uses them (tables will call movable atom checkpass(PASSTABLE) for example)
*/
//flags for pass_flags
#define PASSTABLE (1<<0)
#define PASSGLASS (1<<1)
#define PASSGRILLE (1<<2)
#define PASSBLOB (1<<3)
#define PASSMOB (1<<4)
#define PASSCLOSEDTURF (1<<5)
#define LETPASSTHROW (1<<6)
#define PASSMACHINES (1<<7)
#define PASSCOMPUTER (1<<8)
#define PASSSTRUCTURE (1<<9)
#define PASSDOOR (1<<10)
#define PASSMECH (1<<11)
#define PASSFLOOR (1<<12) //used for z movement

//Movement Types
#define GROUND			(1<<0)
#define FLYING			(1<<1)
#define VENTCRAWLING	(1<<2)
#define FLOATING		(1<<3)
/// When moving, will Bump()/Cross()/Uncross() everything, but won't be stopped.
#define PHASING			(1<<4)
/// The mob is walking on the ceiling. Or is generally just, upside down.
#define UPSIDE_DOWN 	(1<<5)

/// Combination flag for movetypes which, for all intents and purposes, mean the mob is not touching the ground
#define MOVETYPES_NOT_TOUCHING_GROUND (FLYING|FLOATING|UPSIDE_DOWN)

//Fire and Acid stuff, for resistance_flags
#define LAVA_PROOF		(1<<0)
/// 100% immune to fire damage (but not necessarily to lava or heat)
#define FIRE_PROOF		(1<<1)
#define FLAMMABLE		(1<<2)
#define ON_FIRE			(1<<3)
/// acid can't even appear on it, let alone melt it.
#define UNACIDABLE		(1<<4)
/// acid stuck on it doesn't melt it.
#define ACID_PROOF		(1<<5)
/// doesn't take damage
#define INDESTRUCTIBLE	(1<<6)
/// can't be frozen
#define FREEZE_PROOF	(1<<7)

//tesla_zap
#define TESLA_MACHINE_EXPLOSIVE		(1<<0)
#define TESLA_ALLOW_DUPLICATES		(1<<1)
#define TESLA_OBJ_DAMAGE			(1<<2)
#define TESLA_MOB_DAMAGE			(1<<3)
#define TESLA_MOB_STUN				(1<<4)

#define TESLA_DEFAULT_FLAGS TESLA_OBJ_DAMAGE | TESLA_MOB_DAMAGE | TESLA_MOB_STUN | TESLA_MACHINE_EXPLOSIVE
#define TESLA_FUSION_FLAGS TESLA_OBJ_DAMAGE | TESLA_MOB_DAMAGE | TESLA_MOB_STUN

//EMP protection
#define EMP_PROTECT_SELF 		(1<<0)
#define EMP_PROTECT_CONTENTS 	(1<<1)

//Mob mobility var flags
/// can move
#define MOBILITY_MOVE			(1<<0)
/// can, and is, standing up
#define MOBILITY_STAND			(1<<1)
/// can pickup items
#define MOBILITY_PICKUP			(1<<2)
/// can hold and use items
#define MOBILITY_USE			(1<<3)
/// can use interfaces like machinery
#define MOBILITY_UI				(1<<4)
/// can use storage item
#define MOBILITY_STORAGE		(1<<5)
/// can pull things
#define MOBILITY_PULL			(1<<6)

#define MOBILITY_FLAGS_DEFAULT (MOBILITY_MOVE | MOBILITY_STAND | MOBILITY_PICKUP | MOBILITY_USE | MOBILITY_UI | MOBILITY_STORAGE | MOBILITY_PULL)
#define MOBILITY_FLAGS_INTERACTION (MOBILITY_USE | MOBILITY_PICKUP | MOBILITY_UI | MOBILITY_STORAGE)

//alternate appearance flags
#define AA_TARGET_SEE_APPEARANCE 	(1<<0)
#define AA_MATCH_TARGET_OVERLAYS 	(1<<1)

#define KEEP_TOGETHER_ORIGINAL "keep_together_original"

//setter for KEEP_TOGETHER to allow for multiple sources to set and unset it
#define ADD_KEEP_TOGETHER(x, source)\
	if ((x.appearance_flags & KEEP_TOGETHER) && !HAS_TRAIT(x, TRAIT_KEEP_TOGETHER)) ADD_TRAIT(x, TRAIT_KEEP_TOGETHER, KEEP_TOGETHER_ORIGINAL); \
	ADD_TRAIT(x, TRAIT_KEEP_TOGETHER, source);\
	x.appearance_flags |= KEEP_TOGETHER

#define REMOVE_KEEP_TOGETHER(x, source)\
	REMOVE_TRAIT(x, TRAIT_KEEP_TOGETHER, source);\
	if(HAS_TRAIT_FROM_ONLY(x, TRAIT_KEEP_TOGETHER, KEEP_TOGETHER_ORIGINAL))\
		REMOVE_TRAIT(x, TRAIT_KEEP_TOGETHER, KEEP_TOGETHER_ORIGINAL);\
	else if(!HAS_TRAIT(x, TRAIT_KEEP_TOGETHER))\
		x.appearance_flags &= ~KEEP_TOGETHER

//religious_tool flags
#define RELIGION_TOOL_INVOKE 		(1<<0)
#define RELIGION_TOOL_SACRIFICE 	(1<<1)
#define RELIGION_TOOL_SECTSELECT 	(1<<2)

//dir macros
///Returns true if the dir is diagonal, false otherwise
#define ISDIAGONALDIR(d) (d&(d-1))
///True if the dir is north or south, false therwise
#define NSCOMPONENT(d)   (d&(NORTH|SOUTH))
///True if the dir is east/west, false otherwise
#define EWCOMPONENT(d)   (d&(EAST|WEST))
///Flips the dir for north/south directions
#define NSDIRFLIP(d)     (d^(NORTH|SOUTH))
///Flips the dir for east/west directions
#define EWDIRFLIP(d)     (d^(EAST|WEST))
///Turns the dir by 180 degrees
#define DIRFLIP(d)       turn(d, 180)

/// 33554431 (2^24 - 1) is the maximum value our bitflags can reach.
#define MAX_BITFLAG_DIGITS 8

// timed_action_flags parameter for `/proc/do_after`
/// Can do the action even if mob moves location
#define IGNORE_USER_LOC_CHANGE (1<<0)
/// Can do the action even if the target moves location
#define IGNORE_TARGET_LOC_CHANGE (1<<1)
/// Can do the action even if the item is no longer being held
#define IGNORE_HELD_ITEM (1<<2)
/// Can do the action even if the mob is incapacitated (ex. handcuffed)
#define IGNORE_INCAPACITATED (1<<3)
/// Used to prevent important slowdowns from being abused by drugs like kronkaine
#define IGNORE_SLOWDOWNS (1<<4)

#define IGNORE_ALL (IGNORE_USER_LOC_CHANGE|IGNORE_TARGET_LOC_CHANGE|IGNORE_HELD_ITEM|IGNORE_INCAPACITATED|IGNORE_SLOWDOWNS)
