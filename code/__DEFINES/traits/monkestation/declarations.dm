// BEGIN TRAIT DEFINES

// /mob/living
/// Monkeys are friendly/neutral to this mob by defaulot.
#define TRAIT_MONKEYFRIEND 	"monkeyfriend"
/// User's stamina is over the STAMINA_EXHAUSTION_THRESHOLD.
#define TRAIT_EXHAUSTED "exhausted"
/// User is sprinting, full speed ahead.
#define TRAIT_SPRINTING "sprinting"
///Slows the user, with additional effects based on the source.
#define TRAIT_DISORIENTED "disoriented"
/// User cannot sprint.
#define TRAIT_NO_SPRINT "no_sprint"
/// One can breath under water, you get me?
#define TRAIT_WATER_BREATHING "water_breathing"
/// Does not take damage from bloodloss (or any blood shenanigans)
#define TRAIT_NO_BLOODLOSS_DAMAGE "no_bloodloss_damage"
/// Do IPC's dream of doomsday? The answer is yes
#define TRAIT_ROBOT_CAN_BLEED "robots_can_bleed"
/// Tough feets for the satyrs.
#define TRAIT_HARD_SOLES "hard_soles" //Taken from Skyrat
/// The mob's nanites are sending a monitoring signal visible on diag HUD.
#define TRAIT_NANITE_MONITORING "nanite_monitoring"
/// This mob can vault over climable structures.
#define TRAIT_VAULTING "vaulting" //simian trait
/// Ethereals with this trait will not suffer negative effects from overcharge.
#define TRAIT_ETHEREAL_NO_OVERCHARGE "ethereal_no_overcharge"
/// Indicates that they've inhaled helium.
#define TRAIT_HELIUM "helium"
/// Allows the user to start any surgery, anywhere. Mostly used by abductor scientists.
#define TRAIT_ALL_SURGERIES "all_surgeries"
/// Prevents the user from ever (unintentionally) failing a surgery step, and ensures they always have the maximum surgery speed.
#define TRAIT_PERFECT_SURGEON "perfect_surgeon"
/// Reduces the complexity of any cyberlink hacking minigames for the user.
#define TRAIT_BETTER_CYBERCONNECTOR "better_cyberconnector_hacking"
/// Allows the user to climb tables and such faster.
#define TRAIT_FAST_CLIMBER 	"fast_climber"
/// The user is more resistant to being shoved.
#define TRAIT_SHOVE_RESIST	"shove_resist"
/// Allows the user to instantly reload.
#define TRAIT_INSTANT_RELOAD "instant_reload"
/// If an oozeling is currently protecting themselves from water.
#define TRAIT_SLIME_HYDROPHOBIA "slime_hydrophobia"
/// Falsifies Health analyzer blood levels
#define TRAIT_MASQUERADE "masquerade"
/// Your body is literal room temperature. Does not make you immune to the temp
#define TRAIT_COLDBLOODED "coldblooded"
/// Prevents the user from entering stamina crit.
#define TRAIT_CANT_STAMCRIT "cant_stamcrit"
/// This mob will automatically revive when healed enough.
#define TRAIT_REVIVES_BY_HEALING "trait_revives_by_healing"
/// This mob is a ghost critter.
#define TRAIT_GHOST_CRITTER "ghost_critter"

// /datum/mind + /mob/living
/// Prevents the user from casting spells using sign language. Works on both /datum/mind and /mob/living.
#define TRAIT_CANT_SIGN_SPELLS	"cant_sign_spells"
/// You have special interactions with bloodsuckers and the occult.
#define TRAIT_OCCULTIST			"occultist"

// /datum/mind
/// Indicates that the user has been removed from the crew manifest. Used to track if multiple antags have removed the same person.
#define TRAIT_REMOVED_FROM_MANIFEST	"removed_from_manifest"

// Traits related to food
/// Trait for Fire Burps
#define TRAIT_FOOD_FIRE_BURPS	"food_buff_fire_burps"
/// Trait for fast sliding
#define TRAIT_FOOD_SLIDE		"food_slide_buff"
/// Trait for hand picked crops to be of a higher stats (ignores cap)
#define TRAIT_FOOD_JOB_BOTANIST	"food_job_botanist"
/// Trait for rocks to randomly drop ore.
#define TRAIT_FOOD_JOB_MINER	"food_job_miner"

// Traits given by quirks
#define TRAIT_ANIME				"anime"
#define TRAIT_CAT				"cat"
#define TRAIT_GOURMAND			"gourmand"
#define TRAIT_HIDDEN_CLOWN		"clown_disbelief"
#define TRAIT_HIDDEN_IMAGE		"generic-hidden-image"
#define TRAIT_JAILBIRD			"jailbird"
#define TRAIT_KLEPTOMANIAC		"kleptomaniac"
#define TRAIT_LOUD_ASS			"loud_ass"
#define TRAIT_MINING_CALLOUTS	"miner_callouts"
#define TRAIT_PARANOIA			"paranoia"
#define TRAIT_STABLE_ASS		"stable_ass"
#define TRAIT_STOWAWAY			"stowaway"
#define TRAIT_UNSTABLE_ASS		"unstable_ass"


// Traits given by station traits
/// Station trait for when the clown has bridge access *shudders*
#define STATION_TRAIT_CLOWN_BRIDGE "clown_bridge"

// /turf/open
/// Liquids cannot spread over this turf.
#define TRAIT_BLOCK_LIQUID_SPREAD			"block_liquid_spread"
/// If a trait is considered as having "coverage" by a meteor shield.
#define TRAIT_COVERED_BY_METEOR_SHIELD		"covered_by_meteor_shield"
/// Replacement for GLOB.typecache_elevated_structures
#define TRAIT_TURF_HAS_ELEVATED_STRUCTURE	"turf_has_elevated_structure"


// /obj
/// added to structures we want the mobs to be able to target.
#define TRAIT_MOB_DESTROYABLE		"mob_destroyable"
/// This object cannot have its export value be shown by export scanner (shows as unknown)
#define TRAIT_HIDDEN_EXPORT_VALUE	"hiddenexportvalue"

// /obj/item
/// Applied to a satchel that is being worn on the belt.
#define TRAIT_BELT_SATCHEL 			"belt_satchel"
/// Whether a storage item can be compressed by the bluespace compression kit, without the usual storage limitation.
#define TRAIT_BYPASS_COMPRESS_CHECK	"can_compress_anyways"
/// This item is considered "trash" (and will be eaten by cleaner slimes)
#define TRAIT_TRASH_ITEM			"trash_item"

// /atom/movable
/// Things with this trait can pass through wooden barricades.
#define TRAIT_GOES_THROUGH_WOODEN_BARRICADES	"goes_through_wooden_barricades"

// Traits related directly to Clockwork Cult
/// Given to Clockwork Golems, gives them a reduction on invoke time for certain scriptures.
#define TRAIT_FASTER_SLAB_INVOKE	"faster_slab_invoke"
/// Prevents the invocation of clockwork scriptures.
#define TRAIT_NO_SLAB_INVOKE		"no_slab_invoke"
/// Has an item been enchanted by a clock cult Stargazer?
#define TRAIT_STARGAZED				"stargazed"

// END TRAIT DEFINES
