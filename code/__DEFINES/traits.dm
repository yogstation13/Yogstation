#define SIGNAL_ADDTRAIT(trait_ref) "addtrait [trait_ref]"
#define SIGNAL_REMOVETRAIT(trait_ref) "removetrait [trait_ref]"

// trait accessor defines
#define ADD_TRAIT(target, trait, source) \
	do { \
		var/list/_L; \
		if (!target._status_traits) { \
			target._status_traits = list(); \
			_L = target._status_traits; \
			_L[trait] = list(source); \
			SEND_SIGNAL(target, SIGNAL_ADDTRAIT(trait), trait); \
		} else { \
			_L = target._status_traits; \
			if (_L[trait]) { \
				_L[trait] |= list(source); \
			} else { \
				_L[trait] = list(source); \
				SEND_SIGNAL(target, SIGNAL_ADDTRAIT(trait), trait); \
			} \
		} \
	} while (0)
#define REMOVE_TRAIT(target, trait, sources) \
	do { \
		var/list/_L = target._status_traits; \
		var/list/_S; \
		if (sources && !islist(sources)) { \
			_S = list(sources); \
		} else { \
			_S = sources\
		}; \
		if (_L?[trait]) { \
			for (var/_T in _L[trait]) { \
				if ((!_S && (_T != ROUNDSTART_TRAIT)) || (_T in _S)) { \
					_L[trait] -= _T \
				} \
			};\
			if (!length(_L[trait])) { \
				_L -= trait; \
				SEND_SIGNAL(target, SIGNAL_REMOVETRAIT(trait), trait); \
			}; \
			if (!length(_L)) { \
				target._status_traits = null \
			}; \
		} \
	} while (0)
#define REMOVE_TRAIT_NOT_FROM(target, trait, sources) \
	do { \
		var/list/_traits_list = target._status_traits; \
		var/list/_sources_list; \
		if (sources && !islist(sources)) { \
			_sources_list = list(sources); \
		} else { \
			_sources_list = sources\
		}; \
		if (_traits_list?[trait]) { \
			for (var/_trait_source in _traits_list[trait]) { \
				if (!(_trait_source in _sources_list)) { \
					_traits_list[trait] -= _trait_source \
				} \
			};\
			if (!length(_traits_list[trait])) { \
				_traits_list -= trait; \
				SEND_SIGNAL(target, SIGNAL_REMOVETRAIT(trait), trait); \
			}; \
			if (!length(_traits_list)) { \
				target._status_traits = null \
			}; \
		} \
	} while (0)
#define REMOVE_TRAITS_NOT_IN(target, sources) \
	do { \
		var/list/_L = target._status_traits; \
		var/list/_S = sources; \
		if (_L) { \
			for (var/_T in _L) { \
				_L[_T] &= _S;\
				if (!length(_L[_T])) { \
					_L -= _T; \
					SEND_SIGNAL(target, SIGNAL_REMOVETRAIT(_T), _T); \
					}; \
				};\
			if (!length(_L)) { \
				target._status_traits = null\
			};\
		}\
	} while (0)

#define REMOVE_TRAITS_IN(target, sources) \
	do { \
		var/list/_L = target._status_traits; \
		var/list/_S = sources; \
		if (sources && !islist(sources)) { \
			_S = list(sources); \
		} else { \
			_S = sources\
		}; \
		if (_L) { \
			for (var/_T in _L) { \
				_L[_T] -= _S;\
				if (!length(_L[_T])) { \
					_L -= _T; \
					SEND_SIGNAL(target, SIGNAL_REMOVETRAIT(_T)); \
					}; \
				};\
			if (!length(_L)) { \
				target._status_traits = null\
			};\
		}\
	} while (0)

#define HAS_TRAIT(target, trait) (target._status_traits?[trait] ? TRUE : FALSE)
#define HAS_TRAIT_FROM(target, trait, source) (HAS_TRAIT(target, trait) && (source in target._status_traits[trait]))
#define HAS_TRAIT_FROM_ONLY(target, trait, source) (HAS_TRAIT(target, trait) && (source in target._status_traits[trait]) && (length(target._status_traits[trait]) == 1))
#define HAS_TRAIT_NOT_FROM(target, trait, source) (HAS_TRAIT(target, trait) && (length(target._status_traits[trait] - source) > 0))
/// Returns a list of trait sources for this trait. Only useful for wacko cases and internal futzing
/// You should not be using this
#define GET_TRAIT_SOURCES(target, trait) (target._status_traits?[trait] || list())
/// Returns the amount of sources for a trait. useful if you don't want to have a "thing counter" stuck around all the time
#define COUNT_TRAIT_SOURCES(target, trait) length(GET_TRAIT_SOURCES(target, trait))
/// A simple helper for checking traits in a mob's mind
#define HAS_MIND_TRAIT(target, trait) (HAS_TRAIT(target, trait) || (target.mind ? HAS_TRAIT(target.mind, trait) : FALSE))

//Remember to update code/datums/traits/ folder if you're adding/removing/renaming traits.

//mob traits

#define TRAIT_BLIND 			"blind"

#define TRAIT_NEARSIGHT			"nearsighted"

#define TRAIT_MONKEYLIKE		"monkeylike" //sets IsAdvancedToolUser to FALSE

#define TRAIT_REDUCED_DAMAGE_SLOWDOWN "reduced_damage_slowdown"
#define TRAIT_RESISTDAMAGESLOWDOWN "resistdamageslowdown"
#define TRAIT_HIGHRESISTDAMAGESLOWDOWN "highresistdamageslowdown"

#define TRAIT_IMPACTIMMUNE		"impact_immunity" //protects from the damage of getting launched into a wall hard

#define TRAIT_EMPPROOF_SELF		"emp_immunity_self" //for the specific "thing" itself
#define TRAIT_EMPPROOF_CONTENTS "emp_immunity_contents" //for anything the "thing" is carrying, but not itself

#define TRAIT_SAFEWELD		"safe_welding" //prevents blinding from welding without giving actual flash immunity

#define TRAIT_NO_STUN_WEAPONS	"no_stun_weapons" //prevents use of commonly available instant or near instant stun weapons
#define TRAIT_NOINTERACT		"no_interact" //Not allowed to touch anything (even with TK) or use things in hand

#define TRAIT_POWERHUNGRY		"power_hungry" // uses electricity instead of food
///Prevent species from changing while they have the trait
#define TRAIT_SPECIESLOCK "species_lock"
#define TRAIT_NOSLIPICE			"noslip_ice"
#define TRAIT_NOSLIPWATER		"noslip_water"
#define TRAIT_NOSLIPALL			"noslip_all"

#define TRAIT_INFRARED_VISION	"infrared_vision"

#define	TRAIT_CALCIUM_HEALER	"calcium_healer"
#define	TRAIT_MAGIC_CHOKE		"magic_choke"

#define TRAIT_PSYCH				"psych-diagnosis"
#define TRAIT_ALWAYS_CLEAN      "always-clean"

#define TRAIT_QUICKEST_CARRY	"quickest-carry"
#define TRAIT_STRONG_GRIP		"strong-grip"

#define TRAIT_SHELTERED			"sheltered"
#define TRAIT_RANDOM_ACCENT		"random_accent"
#define TRAIT_MEDICALIGNORE     "medical_ignore"
#define TRAIT_SLIME_EMPATHY		"slime-empathy"
#define TRAIT_ACIDBLOOD         "acid_blood"
#define TRAIT_PRESERVED_ORGANS	"preserved_organs"
#define TRAIT_SKINNY			"skinny"  //For those with a slightly thinner torso sprite
#define TRAIT_SURGERY_PREPARED	"surgery_prepared"
#define TRAIT_NO_PASSIVE_COOLING "no-passive-cooling"
#define TRAIT_NO_PASSIVE_HEATING "no-passive-heating"
#define TRAIT_BLOODY_MESS_LITE	"bloody_mess_lite" //weak heparin, otherwise the same
#define TRAIT_NO_BLOOD_REGEN	"no_blood_regen" //prevents regenerating blood
#define TRAIT_NOPULSE           "nopulse" // Your heart doesn't beat
#define TRAIT_MASQUERADE        "masquerade" // Falsifies Health analyzer blood levels
#define TRAIT_NOCLONE			"noclone" // No cloning
#define TRAIT_NODEFIB			"nodefib" // No defibbing
#define TRAIT_COLDBLOODED       "coldblooded" // Your body is literal room temperature. Does not make you immune to the temp
#define TRAIT_EAT_MORE			"eat_more" //You get hungry three times as fast
#define TRAIT_BOTTOMLESS_STOMACH "bottomless_stomach" // Can never be full
#define TRAIT_MESONS			"mesons"
#define TRAIT_MAGBOOTS			"magboots"
#define TRAIT_BADMAIL			"badmail"	//Your mail is going to be worse than average
#define TRAIT_SHORT_TELOMERES	"short_telomeres" //You cannot be CLOONED
#define TRAIT_LONG_TELOMERES	"long_telomeres" //You get CLOONED faster!!!
#define TRAIT_NO_GRENADES		"no_nades"
///You become a Marine that can eat crayons!!!
#define TRAIT_MARINE  "marine"

/// Whether we're sneaking, from the alien sneak ability.
/// Maybe worth generalizing into a general "is sneaky" / "is stealth" trait in the future.
#define TRAIT_ALIEN_SNEAK "sneaking_alien"

///This mob can't use vehicles
#define TRAIT_NOVEHICLE	"no_vehicle"

/// You can't see color!
#define TRAIT_COLORBLIND "color_blind"

/// This person is crying
#define TRAIT_CRYING "crying"

#define TRAIT_NO_STORAGE		"no-storage" //you cannot put this in any container, backpack, box etc

#define TRAIT_POOR_AIM			"poor_aim"

#define TRAIT_DRUNK_HEALING		"drunk_healing"

#define TRAIT_ALLERGIC			"allergic"
#define TRAIT_KLEPTOMANIAC		"kleptomaniac"
#define TRAIT_EAT_LESS			"eat_less"
#define TRAIT_CRAFTY			"crafty"
#define TRAIT_ANOREXIC			"anorexic"

#define TRAIT_SEE_REAGENTS		"see_reagents"
#define TRAIT_STARGAZED			"stargazed"

/// The item is magically cursed
#define CURSED_ITEM_TRAIT(item_type) "cursed_item_[item_type]"

#define PSEUDOCIDER_TRAIT "pseudocider_trait"

#define ATTACHMENT_TRAIT "attachment-trait"

/// A trait given by a specific status effect (not sure why we need both but whatever!)
#define TRAIT_STATUS_EFFECT(effect_id) "[effect_id]-trait"

/// Trait applied by element
#define ELEMENT_TRAIT(source) "element_trait_[source]"


// unique trait sources, still defines
#define CLONING_POD_TRAIT "cloning-pod"
#define CHANGELING_HIVEMIND_MUTE "ling_mute"
#define ABYSSAL_GAZE_BLIND "abyssal_gaze"
#define HIGHLANDER "highlander"
#define CULT_EYES "cult_eyes"
#define NUKEOP_TRAIT "nuke-op"
#define DEATHSQUAD_TRAIT "deathsquad"
#define ANTI_DROP_IMPLANT_TRAIT "anti-drop-implant"
#define HIVEMIND_ONE_MIND_TRAIT "one_mind"
#define VR_ZONE_TRAIT "vr_zone_trait"
#define GUARDIAN_TRAIT "guardian_trait"
#define STARGAZER_TRAIT "stargazer"
#define RANDOM_BLACKOUTS "random_blackouts"
#define MADE_UNCLONEABLE "made-uncloneable"
/// Source trait for Bloodsuckers-related traits
#define BLOODSUCKER_TRAIT "bloodsucker_trait"
/// Source trait for Monster Hunter-related traits
#define HUNTER_TRAIT "monsterhunter_trait"
/// Source trait during a Frenzy
#define FRENZY_TRAIT "frenzy_trait"
/// Source trait while Feeding
#define FEED_TRAIT "feed_trait"
#define HORROR_TRAIT "horror"
#define HOLDER_TRAIT "holder_trait"
#define SINFULDEMON_TRAIT "sinfuldemon"
#define CHANGESTING_TRAIT "changesting"
#define POSIBRAIN_TRAIT "positrait"
#define SYNTHETIC_TRAIT "synthetictrait"
#define WRIST_STRAP_TRAIT "wrist_strap"
#define GRIMOIRE_TRAIT "grimoire_trait"

///Traits given by station traits

#define STATION_TRAIT_MOONSCORCH "station_trait_moonscorch"

///Darkspawn traits
///lets darkspawns walk through weak light
#define TRAIT_DARKSPAWN_LIGHTRES "darkspawn_lightres" 
///lets darkspawns walk through any light
#define TRAIT_DARKSPAWN_CREEP "darkspawn_creep" 
///permanently reduces the lucidity gained from future succs
#define TRAIT_DARKSPAWN_DEVOURED "darkspawn_devoured"
///disable psi regeneration (make sure to remove it after some time)
#define TRAIT_DARKSPAWN_PSIBLOCK "darkspawn_psiblock" 
///make aoe ally buff abilities also affect allied darkspawns
#define TRAIT_DARKSPAWN_BUFFALLIES "darkspawn_allybuff" 
///revives the darkspawn if they're dead and in the dark
#define TRAIT_DARKSPAWN_UNDYING "darkspawn_undying" 

///reduces the cooldown of all used /datum/action/cooldown by 25%
#define TRAIT_FAST_COOLDOWNS "short_spell_cooldowns" 
