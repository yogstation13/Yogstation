////////////////////////////////////////////////////////////////////////////////////
//------------------------------Station traits------------------------------------//
////////////////////////////////////////////////////////////////////////////////////
///Traits given by station traits
#define STATION_TRAIT_BANANIUM_SHIPMENTS "station_trait_bananium_shipments"
#define STATION_TRAIT_BIGGER_PODS "station_trait_bigger_pods"
#define STATION_TRAIT_BIRTHDAY "station_trait_birthday"
#define STATION_TRAIT_BOTS_GLITCHED "station_trait_bot_glitch"
#define STATION_TRAIT_CARP_INFESTATION "station_trait_carp_infestation"
#define STATION_TRAIT_CYBERNETIC_REVOLUTION "station_trait_cybernetic_revolution"
#define STATION_TRAIT_EMPTY_MAINT "station_trait_empty_maint"
#define STATION_TRAIT_FILLED_MAINT "station_trait_filled_maint"
#define STATION_TRAIT_FORESTED "station_trait_forested"
#define STATION_TRAIT_HANGOVER "station_trait_hangover"
#define STATION_TRAIT_LATE_ARRIVALS "station_trait_late_arrivals"
#define STATION_TRAIT_LOANER_SHUTTLE "station_trait_loaner_shuttle"
#define STATION_TRAIT_MEDBOT_MANIA "station_trait_medbot_mania"
#define STATION_TRAIT_PDA_GLITCHED "station_trait_pda_glitched"
#define STATION_TRAIT_PREMIUM_INTERNALS "station_trait_premium_internals"
#define STATION_TRAIT_RADIOACTIVE_NEBULA "station_trait_radioactive_nebula"
#define STATION_TRAIT_RANDOM_ARRIVALS "station_trait_random_arrivals"
#define STATION_TRAIT_REVOLUTIONARY_TRASHING "station_trait_revolutionary_trashing"
#define STATION_TRAIT_SHUTTLE_SALE "station_trait_shuttle_sale"
#define STATION_TRAIT_SMALLER_PODS "station_trait_smaller_pods"
#define STATION_TRAIT_SPIDER_INFESTATION "station_trait_spider_infestation"
#define STATION_TRAIT_UNIQUE_AI "station_trait_unique_ai"
#define STATION_TRAIT_UNNATURAL_ATMOSPHERE "station_trait_unnatural_atmosphere"
#define STATION_TRAIT_VENDING_SHORTAGE "station_trait_vending_shortage"
#define STATION_TRAIT_MOONSCORCH "station_trait_moonscorch"



////////////////////////////////////////////////////////////////////////////////////
//-----------------------------------Mob traits-----------------------------------//
////////////////////////////////////////////////////////////////////////////////////
#define TRAIT_QUICKEST_CARRY	"quickest-carry"
#define TRAIT_STRONG_GRIP		"strong-grip"
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
#define TRAIT_MESONS			"mesons"
#define TRAIT_MAGBOOTS			"magboots"
/// Whether we're sneaking, from the alien sneak ability.
/// Maybe worth generalizing into a general "is sneaky" / "is stealth" trait in the future.
#define TRAIT_ALIEN_SNEAK "sneaking_alien"
///This mob can't use vehicles
#define TRAIT_NOVEHICLE	"no_vehicle"
/// This mech is fully disabled
#define TRAIT_MECH_DISABLED "mech_disabled"
/// You can't see color!
#define TRAIT_COLORBLIND "color_blind"
/// This person is crying
#define TRAIT_CRYING "crying"
/// you cannot put this in any container, backpack, box etc
#define TRAIT_NO_STORAGE		"no-storage" 
/// Crafts items using the crafting menu faster
#define TRAIT_CRAFTY			"crafty"
/// Gets a more detailed reagent breakdown when examining
#define TRAIT_SEE_REAGENTS		"see_reagents"
/// Clock cultist, item is already upgraded by a stargazer
#define TRAIT_STARGAZED			"stargazed"
/// Heals over time while drunk
#define TRAIT_DRUNK_HEALING		"drunk_healing"
/// Gets hungry slower
#define TRAIT_EAT_LESS			"eat_less"
/// Gets hungry three times as fast
#define TRAIT_EAT_MORE			"eat_more"
/// Can never be full
#define TRAIT_BOTTOMLESS_STOMACH "bottomless_stomach"
/// Randomly makes nearby lights flicker
#define RANDOM_BLACKOUTS "random_blackouts"
/// Provides the cultist red eyes overlay
#define CULT_EYES "cult_eyes"
/// organs won't decay
#define TRAIT_PRESERVED_ORGANS	"preserved_organs"

////////////////////////////////////////////////////////////////////////////////////
//--------------------------Utility activity defines------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/// Provides a bonus to brain trauma healing
#define TRAIT_PSYCH				"psych-diagnosis"


////////////////////////////////////////////////////////////////////////////////////
//---------------------------Combat related defines-------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/// Requires getting lower health before damage slowdown begins
#define TRAIT_REDUCED_DAMAGE_SLOWDOWN "reduced_damage_slowdown"
/// Reduces the strength of damage slowdown by 50% (stacks with high resist)
#define TRAIT_RESISTDAMAGESLOWDOWN "resistdamageslowdown"
/// Reduces the strength of damage slowdown by 75% (stacks with regular resist)
#define TRAIT_HIGHRESISTDAMAGESLOWDOWN "highresistdamageslowdown"
/// Prevents use of commonly available instant or near instant stun weapons
#define TRAIT_NO_STUN_WEAPONS	"no_stun_weapons"
/// Reduced accuracy when shooting
#define TRAIT_POOR_AIM			"poor_aim"
/// Can't prime grenades
#define TRAIT_NO_GRENADES		"no_nades"
/// Can't be slowed down
#define TRAIT_IGNORESLOWDOWN "ignoreslow"
/// Can't be slowed down via damage taken
#define TRAIT_IGNOREDAMAGESLOWDOWN "ignoredamageslowdown"
/// Makes the screen go black and white while illuminating all mobs based on their body temperature
#define TRAIT_INFRARED_VISION	"infrared_vision"

////////////////////////////////////////////////////////////////////////////////////
//-------------------------Species Specific defines-------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/// Uses electricity instead of food (does not provide a way to recharge)
#define TRAIT_POWERHUNGRY		"power_hungry"
/// Prevent species from changing while they have the trait
#define TRAIT_SPECIESLOCK "species_lock"
/// Heals when drinking milk and certain milk based drinks
#define	TRAIT_CALCIUM_HEALER	"calcium_healer"
/// Used for Durathread golem choking
#define	TRAIT_MAGIC_CHOKE		"magic_choke"

#define TRAIT_MEDICALIGNORE     "medical_ignore"
#define TRAIT_SLIME_EMPATHY		"slime-empathy"
#define TRAIT_ACIDBLOOD         "acid_blood"
#define TRAIT_SKINNY			"skinny"  //For those with a slightly thinner torso sprite
/// Wonky legs that make more work for spriters and coders
#define TRAIT_DIGITIGRADE		"digitigrade" // the funny lizard legs
/// If the legs are to be displayed like regular legs
#define TRAIT_DIGI_SQUISH       "didi_squish"

////////////////////////////////////////////////////////////////////////////////////
//---------------------------------Quirk defines----------------------------------//
////////////////////////////////////////////////////////////////////////////////////
#define TRAIT_SHELTERED			"sheltered"
#define TRAIT_RANDOM_ACCENT		"random_accent"
#define TRAIT_ALCOHOL_TOLERANCE "alcohol_tolerance"
#define TRAIT_HEAVY_DRINKER "heavy_drinker"
#define TRAIT_AGEUSIA "ageusia"
#define TRAIT_HEAVY_SLEEPER "heavy_sleeper"
#define TRAIT_NIGHT_VISION "night_vision"
#define TRAIT_LIGHT_STEP "light_step"
#define TRAIT_SPIRITUAL "spiritual"
#define TRAIT_CLOWN_ENJOYER "clown_enjoyer"
#define TRAIT_MIME_FAN "mime_fan"
#define TRAIT_VORACIOUS "voracious"
#define TRAIT_SELF_AWARE "self_aware"
#define TRAIT_FREERUNNING "freerunning"
#define TRAIT_SKITTISH "skittish"
#define TRAIT_PROSOPAGNOSIA "prosopagnosia"
#define TRAIT_TAGGER "tagger"
#define TRAIT_PHOTOGRAPHER "photographer"
#define TRAIT_MUSICIAN "musician"
#define TRAIT_LIGHT_DRINKER "light_drinker"
#define TRAIT_EMPATH "empath"
#define TRAIT_FRIENDLY "friendly"
#define TRAIT_GRABWEAKNESS "grab_weakness"
#define TRAIT_SNOB "snob"
#define TRAIT_BALD "bald"
#define TRAIT_SHAVED "shaved"
#define TRAIT_BADTOUCH "bad_touch"
#define TRAIT_EXTROVERT "extrovert"
#define TRAIT_INTROVERT "introvert"
#define TRAIT_ANXIOUS "anxious"
#define TRAIT_SMOKER "smoker"
#define TRAIT_POSTERBOY "poster_boy"
#define TRAIT_THROWINGARM "throwing_arm"
#define TRAIT_SETTLER "settler"
///You become a Marine that can eat crayons!!!
#define TRAIT_MARINE  "marine"
#define TRAIT_BADMAIL			"badmail"	//Your mail is going to be worse than average
#define TRAIT_SHORT_TELOMERES	"short_telomeres" //You cannot be CLOONED
#define TRAIT_LONG_TELOMERES	"long_telomeres" //You get CLOONED faster!!!


////////////////////////////////////////////////////////////////////////////////////
//----------------------------Immunity trait defines------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/// Provides complete emp immunity to the atom, but not anything they're holding
#define TRAIT_EMPPROOF_SELF		"emp_immunity_self"
/// Provides complete emp immunity to everything being held, but not the atom itself
#define TRAIT_EMPPROOF_CONTENTS "emp_immunity_contents"
/// Provides immunity to the blinding of welding without providing immunity to other sources of flash
#define TRAIT_SAFEWELD		"safe_welding"
/// protects the holder from throw_impact
#define TRAIT_IMPACTIMMUNE		"impact_immunity"
/// Immunity to slipping on ice
#define TRAIT_NOSLIPICE			"noslip_ice"
/// Immunity to slipping on water
#define TRAIT_NOSLIPWATER		"noslip_water"
/// Immunity to slipping
#define TRAIT_NOSLIPALL			"noslip_all"
/// This mob is immune to stun causing status effects and stamcrit.
/// Prefer to use [/mob/living/proc/check_stun_immunity] over checking for this trait exactly.
#define TRAIT_STUNIMMUNE "stun_immunity"
/// Can't fall asleep
#define TRAIT_SLEEPIMMUNE "sleep_immunity"
/// Can't be pushed
#define TRAIT_PUSHIMMUNE "push_immunity"
/// Are we immune to shocks?
#define TRAIT_SHOCKIMMUNE "shock_immunity"
/// Immunity to low temperature damage
#define TRAIT_RESISTCOLD "resist_cold"
/// Immunity to high temperature damage
#define TRAIT_RESISTHEAT "resist_heat"
/// For when you want to be able to touch hot things, but still want fire to be an issue.
#define TRAIT_RESISTHEATHANDS "resist_heat_handsonly"
/// Immunity to high pressure atmos damage
#define TRAIT_RESISTHIGHPRESSURE "resist_high_pressure"
/// Immunity to low pressure atmos damage
#define TRAIT_RESISTLOWPRESSURE "resist_low_pressure"
/// This human is immune to the effects of being exploded. (ex_act)
#define TRAIT_BOMBIMMUNE "bomb_immunity"
/// Immune to being irradiated
#define TRAIT_RADIMMUNE "rad_immunity"
/// Can't be given viruses
#define TRAIT_VIRUSIMMUNE "virus_immunity"
/// Can't be injected with syringes and other similar things
#define TRAIT_PIERCEIMMUNE "pierce_immunity"
/// Can't be dismembered
#define TRAIT_NODISMEMBER "dismember_immunity"
/// Can't be set on fire
#define TRAIT_NOFIRE "nonflammable"
/// Mob is immune to toxin damage
#define TRAIT_TOXIMMUNE "toxin_immune"
/// Makes you immune to flashes
#define TRAIT_NOFLASH "noflash"
/// One can breath under water, you get me?
#define TRAIT_WATER_BREATHING "water_breathing"



////////////////////////////////////////////////////////////////////////////////////
//-----------------------------Unique trait sources-------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/// The item is magically cursed
#define CURSED_ITEM_TRAIT(item_type) "cursed_item_[item_type]"

/// A trait given by a specific status effect (not sure why we need both but whatever!)
#define TRAIT_STATUS_EFFECT(effect_id) "[effect_id]-trait"

/// Trait applied by element
#define ELEMENT_TRAIT(source) "element_trait_[source]"

#define PSEUDOCIDER_TRAIT "pseudocider_trait"
#define ATTACHMENT_TRAIT "attachment-trait"
#define CLONING_POD_TRAIT "cloning-pod"
#define CHANGELING_HIVEMIND_MUTE "ling_mute"
#define ABYSSAL_GAZE_BLIND "abyssal_gaze"
#define HIGHLANDER "highlander"
#define NUKEOP_TRAIT "nuke-op"
#define DEATHSQUAD_TRAIT "deathsquad"
#define ANTI_DROP_IMPLANT_TRAIT "anti-drop-implant"
#define HIVEMIND_ONE_MIND_TRAIT "one_mind"
#define VR_ZONE_TRAIT "vr_zone_trait"
#define GUARDIAN_TRAIT "guardian_trait"
#define STARGAZER_TRAIT "stargazer"
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

/**
 * END OF YOGS REORGANIZE, MIGHT COME BACK TO THIS
 */



////////////////////////////////////////////////////////////////////////////////////
//--------------------------------Basic defines-----------------------------------//
////////////////////////////////////////////////////////////////////////////////////
/// Not allowed to touch anything (even with TK) or use things in hand
#define TRAIT_NOINTERACT		"no_interact"
/// Makes the mob blind
#define TRAIT_BLIND 			"blind"
/// Makes the mob have a blur around the outer half of the screen
#define TRAIT_NEARSIGHT			"nearsighted"
/// Prevents the mob from using tools
#define TRAIT_MONKEYLIKE		"monkeylike" //sets IsAdvancedToolUser to FALSE
/// Forces the user to stay unconscious.
#define TRAIT_KNOCKEDOUT "knockedout"
/// Prevents voluntary movement.
#define TRAIT_IMMOBILIZED "immobilized"
/// Prevents interacting with things
#define TRAIT_INCAPACITATED "incapacitated"
/// Prevents voluntary standing or staying up on its own.
#define TRAIT_FLOORED "floored"
/// Forces user to stay standing
#define TRAIT_FORCED_STANDING "forcedstanding"
/// Prevents usage of manipulation appendages (picking, holding or using items, manipulating storage).
#define TRAIT_HANDS_BLOCKED "handsblocked"
/// Inability to access UI hud elements. Turned into a trait from [MOBILITY_UI] to be able to track sources.
#define TRAIT_UI_BLOCKED "uiblocked"
/// Inability to pull things. Turned into a trait from [MOBILITY_PULL] to be able to track sources.
#define TRAIT_PULL_BLOCKED "pullblocked"
/// Abstract condition that prevents movement if being pulled and might be resisted against. Handcuffs and straight jackets, basically.
#define TRAIT_RESTRAINED "restrained"
/// In some kind of critical condition. Is able to succumb.
#define TRAIT_CRITICAL_CONDITION "critical-condition"
/// Mute. Can't talk.
#define TRAIT_MUTE "mute"
/// Emotemute. Can't... emote.
#define TRAIT_EMOTEMUTE "emotemute"
#define TRAIT_DEAF "deaf"
#define TRAIT_FAT "fat"
#define TRAIT_HUSK "husk"
#define TRAIT_BADDNA "baddna"
#define TRAIT_CLUMSY "clumsy"
#define TRAIT_DUMB "dumb"
#define TRAIT_PACIFISM "pacifism"
/// Can't hold people up with guns, for whatever reason
#define TRAIT_NO_HOLDUP "no_holdup"
/// Causes death-like unconsciousness
#define TRAIT_DEATHCOMA "deathcoma"
/// Makes the owner appear as dead to most forms of medical examination
#define TRAIT_FAKEDEATH "fakedeath"
#define TRAIT_DISFIGURED "disfigured"
/// Tracks whether we're gonna be a baby alien's mummy.
#define TRAIT_XENO_HOST "xeno_host"
#define TRAIT_STABLEHEART "stable_heart"
#define TRAIT_STABLELIVER "stable_liver"
/// Prevents you from leaving your corpse
#define TRAIT_CORPSELOCKED "corpselocked"
#define TRAIT_GENELESS "geneless"
#define TRAIT_NOGUNS "no_guns"
/// Species with this trait are genderless
#define TRAIT_AGENDER "agender"
/// Species with this trait have a blood clan mechanic
#define TRAIT_BLOOD_CLANS "blood_clans"
/// Species with this trait have markings (this SUCKS, remove this later in favor of bodypart overlays)
#define TRAIT_HAS_MARKINGS "has_markings"
/// Species with this trait use skin tones for coloration
#define TRAIT_USES_SKINTONES "uses_skintones"
/// Species with this trait use mutant colors for coloration
#define TRAIT_MUTANT_COLORS "mutcolors"
/// Species with this trait have mutant colors that cannot be chosen by the player, nor altered ingame by external means
#define TRAIT_FIXED_MUTANT_COLORS "fixed_mutcolors"
/// Species with this trait have a haircolor that cannot be chosen by the player, nor altered ingame by external means
#define TRAIT_FIXED_HAIRCOLOR "fixed_haircolor"
/// Humans with this trait won't get bloody hands, nor bloody feet
#define TRAIT_NO_BLOOD_OVERLAY "no_blood_overlay"
/// Humans with this trait cannot have underwear
#define TRAIT_NO_UNDERWEAR "no_underwear"
/// This carbon doesn't get hungry
#define TRAIT_NOHUNGER "no_hunger"
/// This just means that the carbon will always have functional liverless metabolism
#define TRAIT_LIVERLESS_METABOLISM "liverless_metabolism"
/// Humans with this trait cannot be turned into zombies
#define TRAIT_NO_ZOMBIFY "no_zombify"
/// Carbons with this trait can't have their DNA copied by diseases nor changelings
#define TRAIT_NO_DNA_COPY "no_dna_copy"
/// Carbons with this trait cant have their dna scrambled by genetics or a disease retrovirus.
#define TRAIT_NO_DNA_SCRAMBLE "no_dna_scramble"
/// Carbons with this trait can eat blood to regenerate their own blood volume, instead of injecting it
#define TRAIT_DRINKS_BLOOD "drinks_blood"
/// Mob is immune to oxygen damage, does not need to breathe
#define TRAIT_NOBREATH "no_breath"
/// Mob is currently disguised as something else (like a morph being another mob or an object). Holds a reference to the thing that applied the trait.
#define TRAIT_DISGUISED "disguised"
/// Use when you want a mob to be able to metabolize plasma temporarily (e.g. plasma fixation disease symptom)
#define TRAIT_PLASMA_LOVER_METABOLISM "plasma_lover_metabolism"
#define TRAIT_EASYDISMEMBER "easy_dismember"
#define TRAIT_LIMBATTACHMENT "limb_attach"
#define TRAIT_NOLIMBDISABLE "no_limb_disable"
#define TRAIT_EASILY_WOUNDED "easy_limb_wound"
#define TRAIT_HARDLY_WOUNDED "hard_limb_wound"
#define TRAIT_NEVER_WOUNDED "never_wounded"
/// Species with this trait have 50% extra chance of bleeding from piercing and slashing wounds
#define TRAIT_EASYBLEED "easybleed"
#define TRAIT_TOXINLOVER "toxinlover"
/// Doesn't get overlays from being in critical.
#define TRAIT_NOCRITOVERLAY "no_crit_overlay"
/// reduces the use time of syringes, pills, patches and medigels but only when using on someone
#define TRAIT_FASTMED "fast_med_use"
/// The mob is holy and resistance to cult magic
#define TRAIT_HOLY "holy"
/// This mob or weapon is unholy, and is easier to block using holy weapons.
#define TRAIT_UNHOLY "unholy"
/// This mob is antimagic, and immune to spells / cannot cast spells
#define TRAIT_ANTIMAGIC "anti_magic"
/// This allows a person who has antimagic to cast spells without getting blocked
#define TRAIT_ANTIMAGIC_NO_SELFBLOCK "anti_magic_no_selfblock"
/// This mob recently blocked magic with some form of antimagic
#define TRAIT_RECENTLY_BLOCKED_MAGIC "recently_blocked_magic"
/// The user can do things like use magic staffs without penalty
#define TRAIT_MAGICALLY_GIFTED "magically_gifted"
/// This object innately spawns with fantasy variables already applied (the magical component is given to it on initialize), and thus we never want to give it the component again.
#define TRAIT_INNATELY_FANTASTICAL_ITEM "innately_fantastical_item"
#define TRAIT_DEPRESSION "depression"
#define TRAIT_BLOOD_DEFICIENCY "blood_deficiency"
#define TRAIT_JOLLY "jolly"
#define TRAIT_NOCRITDAMAGE "no_crit"
///Added to mob or mind, changes the icons of the fish shown in the minigame UI depending on the possible reward.
#define TRAIT_REVEAL_FISH "reveal_fish"

/// Added to a mob, allows that mob to experience flavour-based moodlets when examining food
#define TRAIT_REMOTE_TASTING "remote_tasting"


/// Unlinks gliding from movement speed, meaning that there will be a delay between movements rather than a single move movement between tiles
#define TRAIT_NO_GLIDE "no_glide"

/// Applied into wounds when they're scanned with the wound analyzer, halves time to treat them manually.
#define TRAIT_WOUND_SCANNED "wound_scanned"

#define TRAIT_NODEATH "nodeath"
#define TRAIT_NOHARDCRIT "nohardcrit"
#define TRAIT_NOSOFTCRIT "nosoftcrit"
#define TRAIT_MINDSHIELD "mindshield"
#define TRAIT_DISSECTED "dissected"
#define TRAIT_SURGICALLY_ANALYZED "surgically_analyzed"
/// Lets the user succumb even if they got NODEATH
#define TRAIT_SUCCUMB_OVERRIDE "succumb_override"
/// Can hear observers
#define TRAIT_SIXTHSENSE "sixth_sense"
#define TRAIT_FEARLESS "fearless"
/// Ignores darkness for hearing
#define TRAIT_HEAR_THROUGH_DARKNESS "hear_through_darkness"
/// These are used for brain-based paralysis, where replacing the limb won't fix it
#define TRAIT_PARALYSIS_L_ARM "para-l-arm"
#define TRAIT_PARALYSIS_R_ARM "para-r-arm"
#define TRAIT_PARALYSIS_L_LEG "para-l-leg"
#define TRAIT_PARALYSIS_R_LEG "para-r-leg"
#define TRAIT_CANNOT_OPEN_PRESENTS "cannot-open-presents"
#define TRAIT_PRESENT_VISION "present-vision"
#define TRAIT_DISK_VERIFIER "disk-verifier"
#define TRAIT_NOMOBSWAP "no-mob-swap"
/// Can examine IDs to see if they are roundstart.
#define TRAIT_ID_APPRAISER "id_appraiser"
/// Gives us turf, mob and object vision through walls
#define TRAIT_XRAY_VISION "xray_vision"
/// Gives us mob vision through walls and slight night vision
#define TRAIT_THERMAL_VISION "thermal_vision"
/// Gives us turf vision through walls and slight night vision
#define TRAIT_MESON_VISION "meson_vision"
/// Gives us Night vision
#define TRAIT_TRUE_NIGHT_VISION "true_night_vision"
/// Negates our gravity, letting us move normally on floors in 0-g
#define TRAIT_NEGATES_GRAVITY "negates_gravity"
/// We are ignoring gravity
#define TRAIT_IGNORING_GRAVITY "ignores_gravity"
/// We have some form of forced gravity acting on us
#define TRAIT_FORCED_GRAVITY "forced_gravity"
/// Makes whispers clearly heard from seven tiles away, the full hearing range
#define TRAIT_GOOD_HEARING "good_hearing"
/// Allows you to hear speech through walls
#define TRAIT_XRAY_HEARING "xray_hearing"

/// Lets us scan reagents
#define TRAIT_REAGENT_SCANNER "reagent_scanner"
/// Lets us scan machine parts and tech unlocks
#define TRAIT_RESEARCH_SCANNER "research_scanner"
/// Can weave webs into cloth
#define TRAIT_WEB_WEAVER "web_weaver"
/// Can navigate the web without getting stuck
#define TRAIT_WEB_SURFER "web_surfer"
/// A web is being spun on this turf presently
#define TRAIT_SPINNING_WEB_TURF "spinning_web_turf"
#define TRAIT_ABDUCTOR_TRAINING "abductor-training"
#define TRAIT_ABDUCTOR_SCIENTIST_TRAINING "abductor-scientist-training"
#define TRAIT_SURGEON "surgeon"
#define TRAIT_STRONG_GRABBER "strong_grabber"
#define TRAIT_SOOTHED_THROAT "soothed-throat"
#define TRAIT_BOOZE_SLIDER "booze-slider"
/// We place people into a fireman carry quicker than standard
#define TRAIT_QUICK_CARRY "quick-carry"
/// We place people into a fireman carry especially quickly compared to quick_carry
#define TRAIT_QUICKER_CARRY "quicker-carry"
#define TRAIT_QUICK_BUILD "quick-build"
/// We can handle 'dangerous' plants in botany safely
#define TRAIT_PLANT_SAFE "plant_safe"
/// Prevents the overlay from nearsighted
#define TRAIT_NEARSIGHTED_CORRECTED "fixes_nearsighted"
#define TRAIT_UNINTELLIGIBLE_SPEECH "unintelligible-speech"
#define TRAIT_UNSTABLE "unstable"
#define TRAIT_OIL_FRIED "oil_fried"
#define TRAIT_MEDICAL_HUD "med_hud"
#define TRAIT_SECURITY_HUD "sec_hud"
/// for something granting you a diagnostic hud
#define TRAIT_DIAGNOSTIC_HUD "diag_hud"
/// Is a medbot healing you
#define TRAIT_MEDIBOTCOMINGTHROUGH "medbot"
#define TRAIT_PASSTABLE "passtable"
/// Allows the species to equip items that normally require a jumpsuit without having one equipped. Used by golems.
#define TRAIT_NO_JUMPSUIT "no_jumpsuit"
#define TRAIT_NAIVE "naive"
/// always detect storms on icebox
#define TRAIT_DETECT_STORM "detect_storm"
#define TRAIT_PRIMITIVE "primitive"
#define TRAIT_GUNFLIP "gunflip"
/// Increases chance of getting special traumas, makes them harder to cure
#define TRAIT_SPECIAL_TRAUMA_BOOST "special_trauma_boost"
#define TRAIT_SPACEWALK "spacewalk"
/// Sanity trait to keep track of when we're in hyperspace and add the appropriate element if we werent
#define TRAIT_HYPERSPACED "hyperspaced"
///Gives the movable free hyperspace movement without being pulled during shuttle transit
#define TRAIT_FREE_HYPERSPACE_MOVEMENT "free_hyperspace_movement"
///Lets the movable move freely in the soft-cordon area of transit space, which would otherwise teleport them away just before they got to see the true cordon
#define TRAIT_FREE_HYPERSPACE_SOFTCORDON_MOVEMENT "free_hyperspace_softcordon_movement"
///Deletes the object upon being dumped into space, usually from exiting hyperspace. Useful if you're spawning in a lot of stuff for hyperspace events that dont need to flood the entire game
#define TRAIT_DEL_ON_SPACE_DUMP "del_on_hyperspace_leave"
/// We can walk up or around cliffs, or at least we don't fall off of it
#define TRAIT_CLIFF_WALKER "cliff_walker"
/// Gets double arcade prizes
#define TRAIT_GAMERGOD "gamer-god"
#define TRAIT_GIANT "giant"
#define TRAIT_DWARF "dwarf"
/// makes your footsteps completely silent
#define TRAIT_SILENT_FOOTSTEPS "silent_footsteps"
/// prevents the damage done by a brain tumor
#define TRAIT_TUMOR_SUPPRESSED "brain_tumor_suppressed"
/// Prevents hallucinations from the hallucination brain trauma (RDS)
#define TRAIT_RDS_SUPPRESSED "rds_suppressed"
/// Indicates if the mob is currently speaking with sign language
#define TRAIT_SIGN_LANG "sign_language"
/// This mob is able to use sign language over the radio.
#define TRAIT_CAN_SIGN_ON_COMMS "can_sign_on_comms"
/// nobody can use martial arts on this mob
#define TRAIT_MARTIAL_ARTS_IMMUNE "martial_arts_immune"
/// Immune to being afflicted by time stop (spell)
#define TRAIT_TIME_STOP_IMMUNE "time_stop_immune"
/// Revenants draining you only get a very small benefit.
#define TRAIT_WEAK_SOUL "weak_soul"
/// This mob has no soul
#define TRAIT_NO_SOUL "no_soul"
/// Prevents mob from riding mobs when buckled onto something
#define TRAIT_CANT_RIDE "cant_ride"
/// Prevents a mob from being unbuckled, currently only used to prevent people from falling over on the tram
#define TRAIT_CANNOT_BE_UNBUCKLED "cannot_be_unbuckled"
/// from heparin and nitrous oxide, makes open bleeding wounds rapidly spill more blood
#define TRAIT_BLOODY_MESS "bloody_mess"
/// from coagulant reagents, this doesn't affect the bleeding itself but does affect the bleed warning messages
#define TRAIT_COAGULATING "coagulating"
/// From anti-convulsant medication against seizures.
#define TRAIT_ANTICONVULSANT "anticonvulsant"
/// The holder of this trait has antennae or whatever that hurt a ton when noogied
#define TRAIT_ANTENNAE "antennae"
/// Blowing kisses actually does damage to the victim
#define TRAIT_KISS_OF_DEATH "kiss_of_death"
/// Used to activate french kissing
#define TRAIT_GARLIC_BREATH "kiss_of_garlic_death"
/// Addictions don't tick down, basically they're permanently addicted
#define TRAIT_HOPELESSLY_ADDICTED "hopelessly_addicted"
/// This mob has a cult halo.
#define TRAIT_CULT_HALO "cult_halo"
/// Their eyes glow an unnatural red colour. Currently used to set special examine text on humans. Does not guarantee the mob's eyes are coloured red, nor that there is any visible glow on their character sprite.
#define TRAIT_UNNATURAL_RED_GLOWY_EYES "unnatural_red_glowy_eyes"
/// Their eyes are bloodshot. Currently used to set special examine text on humans. Examine text is overridden by TRAIT_UNNATURAL_RED_GLOWY_EYES.
#define TRAIT_BLOODSHOT_EYES "bloodshot_eyes"
/// This mob should never close UI even if it doesn't have a client
#define TRAIT_PRESERVE_UI_WITHOUT_CLIENT "preserve_ui_without_client"
/// This mob overrides certian SSlag_switch measures with this special trait
#define TRAIT_BYPASS_MEASURES "bypass_lagswitch_measures"
/// Someone can safely be attacked with honorbound with ONLY a combat mode check, the trait is assuring holding a weapon and hitting won't hurt them..
#define TRAIT_ALLOWED_HONORBOUND_ATTACK "allowed_honorbound_attack"
/// The user is sparring
#define TRAIT_SPARRING "sparring"
/// The user is currently challenging an elite mining mob. Prevents him from challenging another until he's either lost or won.
#define TRAIT_ELITE_CHALLENGER "elite_challenger"
/// For living mobs. It signals that the mob shouldn't have their data written in an external json for persistence.
#define TRAIT_DONT_WRITE_MEMORY "dont_write_memory"
/// This mob can be painted with the spraycan
#define TRAIT_SPRAY_PAINTABLE "spray_paintable"
/// This atom can ignore the "is on a turf" check for simple AI datum attacks, allowing them to attack from bags or lockers as long as any other conditions are met
#define TRAIT_AI_BAGATTACK "bagattack"
/// This mobs bodyparts are invisible but still clickable.
#define TRAIT_INVISIBLE_MAN "invisible_man"
/// Don't draw external organs/species features like wings, horns, frills and stuff
#define TRAIT_HIDE_EXTERNAL_ORGANS "hide_external_organs"
///When people are floating from zero-grav or something, we can move around freely!
#define TRAIT_FREE_FLOAT_MOVEMENT "free_float_movement"
// You can stare into the abyss, but it does not stare back.
// You're immune to the hallucination effect of the supermatter, either
// through force of will, or equipment. Present on /mob or /datum/mind
#define TRAIT_MADNESS_IMMUNE "supermatter_madness_immune"
// You can stare into the abyss, and it turns pink.
// Being close enough to the supermatter makes it heal at higher temperatures
// and emit less heat. Present on /mob or /datum/mind
#define TRAIT_SUPERMATTER_SOOTHER "supermatter_soother"
/// Mob has fov applied to it
#define TRAIT_FOV_APPLIED "fov_applied"

/// Trait added when a revenant is visible.
#define TRAIT_REVENANT_REVEALED "revenant_revealed"
/// Trait added when a revenant has been inhibited (typically by the bane of a holy weapon)
#define TRAIT_REVENANT_INHIBITED "revenant_inhibited"

/// Trait which prevents you from becoming overweight
#define TRAIT_NOFAT "cant_get_fat"

/// Trait which allows you to eat rocks
#define TRAIT_ROCK_EATER "rock_eater"
/// Trait which allows you to gain bonuses from consuming rocks
#define TRAIT_ROCK_METAMORPHIC "rock_metamorphic"

/// `do_teleport` will not allow this atom to teleport
#define TRAIT_NO_TELEPORT "no-teleport"
/// This atom is a secluded location, which is counted as out of bounds.
/// Anything that enters this atom's contents should react if it wants to stay in bounds.
#define TRAIT_SECLUDED_LOCATION "secluded_loc"

/// Trait used by fugu glands to avoid double buffing
#define TRAIT_FUGU_GLANDED "fugu_glanded"

/// Trait that tracks if something has been renamed. Typically holds a REF() to the object itself (AKA src) for wide addition/removal.
#define TRAIT_WAS_RENAMED "was_renamed"

/// When someone with this trait fires a ranged weapon, their fire delays and click cooldowns are halved
#define TRAIT_DOUBLE_TAP "double_tap"

/// Trait applied to [/datum/mind] to stop someone from using the cursed hot springs to polymorph more than once.
#define TRAIT_HOT_SPRING_CURSED "hot_spring_cursed"

/// If something has been engraved/cannot be engraved
#define TRAIT_NOT_ENGRAVABLE "not_engravable"

/// Whether or not orbiting is blocked or not
#define TRAIT_ORBITING_FORBIDDEN "orbiting_forbidden"
/// Trait applied to mob/living to mark that spiders should not gain further enriched eggs from eating their corpse.
#define TRAIT_SPIDER_CONSUMED "spider_consumed"
/// Whether we're sneaking, from the creature sneak ability.
#define TRAIT_SNEAK "sneaking_creatures"

/// Item still allows you to examine items while blind and actively held.
#define TRAIT_BLIND_TOOL "blind_tool"

/// The person with this trait always appears as 'unknown'.
#define TRAIT_UNKNOWN "unknown"

/// If the mob has this trait and die, their bomb implant doesn't detonate automatically. It must be consciously activated.
#define TRAIT_PREVENT_IMPLANT_AUTO_EXPLOSION "prevent_implant_auto_explosion"

/// If applied to a mob, nearby dogs will have a small chance to nonharmfully harass said mob
#define TRAIT_HATED_BY_DOGS "hated_by_dogs"
/// Mobs with this trait will not be immobilized when held up
#define TRAIT_NOFEAR_HOLDUPS "no_fear_holdup"
/// Mob has gotten an armor buff from adamantine extract
#define TRAIT_ADAMANTINE_EXTRACT_ARMOR "adamantine_extract_armor"
/// Mobs with this trait won't be able to dual wield guns.
#define TRAIT_NO_GUN_AKIMBO "no_gun_akimbo"

/// Projectile with this trait will always hit the defined zone of a struck living mob.
#define TRAIT_ALWAYS_HIT_ZONE "always_hit_zone"

/// Mobs with this trait do care about a few grisly things, such as digging up graves. They also really do not like bringing people back to life or tending wounds, but love autopsies and amputations.
#define TRAIT_MORBID "morbid"

/// Whether or not the user is in a MODlink call, prevents making more calls
#define TRAIT_IN_CALL "in_call"

/// Is the mob standing on an elevated surface? This prevents them from dropping down if not elevated first.
#define TRAIT_ON_ELEVATED_SURFACE "on_elevated_surface"

/// Prevents you from twohanding weapons.
#define TRAIT_NO_TWOHANDING "no_twohanding"

/// Halves the time of tying a tie.
#define TRAIT_FAST_TYING "fast_tying"

/// Sells for more money on the pirate bounty pad.
#define TRAIT_HIGH_VALUE_RANSOM "high_value_ransom"

// METABOLISMS
// Various jobs on the station have historically had better reactions
// to various drinks and foodstuffs. Security liking donuts is a classic
// example. Through years of training/abuse, their livers have taken
// a liking to those substances. Steal a sec officer's liver, eat donuts good.

// These traits are applied to /obj/item/organ/internal/liver
#define TRAIT_LAW_ENFORCEMENT_METABOLISM "law_enforcement_metabolism"
#define TRAIT_CULINARY_METABOLISM "culinary_metabolism"
#define TRAIT_COMEDY_METABOLISM "comedy_metabolism"
#define TRAIT_MEDICAL_METABOLISM "medical_metabolism"
#define TRAIT_ENGINEER_METABOLISM "engineer_metabolism"
#define TRAIT_ROYAL_METABOLISM "royal_metabolism"
#define TRAIT_PRETENDER_ROYAL_METABOLISM "pretender_royal_metabolism"
#define TRAIT_BALLMER_SCIENTIST "ballmer_scientist"
#define TRAIT_MAINTENANCE_METABOLISM "maintenance_metabolism"
#define TRAIT_CORONER_METABOLISM "coroner_metabolism"


/// The mob has an active mime vow of silence, and thus is unable to speak and has other mime things going on
#define TRAIT_MIMING "miming"

/// This mob is phased out of reality from magic, either a jaunt or rod form
#define TRAIT_MAGICALLY_PHASED "magically_phased"


///Movement type traits for movables. See elements/movetype_handler.dm
#define TRAIT_MOVE_GROUND "move_ground"
#define TRAIT_MOVE_FLYING "move_flying"
#define TRAIT_MOVE_VENTCRAWLING "move_ventcrawling"
#define TRAIT_MOVE_FLOATING "move_floating"
#define TRAIT_MOVE_PHASING "move_phasing"
#define TRAIT_MOVE_UPSIDE_DOWN "move_upside_down"
/// Disables the floating animation. See above.
#define TRAIT_NO_FLOATING_ANIM "no-floating-animation"

//non-mob traits
/// Used for limb-based paralysis, where replacing the limb will fix it.
#define TRAIT_PARALYSIS "paralysis"
/// Used for limbs.
#define TRAIT_DISABLED_BY_WOUND "disabled-by-wound"
/// This movable atom has the explosive block element
#define TRAIT_BLOCKING_EXPLOSIVES "blocking_explosives"

///Lava will be safe to cross while it has this trait.
#define TRAIT_LAVA_STOPPED "lava_stopped"
///Chasms will be safe to cross while they've this trait.
#define TRAIT_CHASM_STOPPED "chasm_stopped"
///The effects of the immerse element will be halted while this trait is present.
#define TRAIT_IMMERSE_STOPPED "immerse_stopped"
/// The effects of hyperspace drift are blocked when the tile has this trait
#define TRAIT_HYPERSPACE_STOPPED "hyperspace_stopped"

///Turf slowdown will be ignored when this trait is added to a turf.
#define TRAIT_TURF_IGNORE_SLOWDOWN "turf_ignore_slowdown"
///Mobs won't slip on a wet turf while it has this trait
#define TRAIT_TURF_IGNORE_SLIPPERY "turf_ignore_slippery"

/// Mobs with this trait can't send the mining shuttle console when used outside the station itself
#define TRAIT_FORBID_MINING_SHUTTLE_CONSOLE_OUTSIDE_STATION "forbid_mining_shuttle_console_outside_station"

//important_recursive_contents traits
/*
 * Used for movables that need to be updated, via COMSIG_ENTER_AREA and COMSIG_EXIT_AREA, when transitioning areas.
 * Use [/atom/movable/proc/become_area_sensitive(trait_source)] to properly enable it. How you remove it isn't as important.
 */
#define TRAIT_AREA_SENSITIVE "area-sensitive"
///every hearing sensitive atom has this trait
#define TRAIT_HEARING_SENSITIVE "hearing_sensitive"
///every object that is currently the active storage of some client mob has this trait
#define TRAIT_ACTIVE_STORAGE "active_storage"

/// Climbable trait, given and taken by the climbable element when added or removed. Exists to be easily checked via HAS_TRAIT().
#define TRAIT_CLIMBABLE "trait_climbable"

///Used for managing KEEP_TOGETHER in [/atom/var/appearance_flags]
#define TRAIT_KEEP_TOGETHER "keep-together"

// cargo traits
///If the crate's contents are immune to the missing item manifest error
#define TRAIT_NO_MISSING_ITEM_ERROR "no_missing_item_error"
///If the crate is immune to the wrong content in manifest error
#define TRAIT_NO_MANIFEST_CONTENTS_ERROR "no_manifest_contents_error"

///SSeconomy trait, if the market is crashing and people can't withdraw credits from ID cards.
#define TRAIT_MARKET_CRASHING "market_crashing"

// item traits
#define TRAIT_NODROP "nodrop"
/// Visible on t-ray scanners if the atom/var/level == 1
#define TRAIT_T_RAY_VISIBLE "t-ray-visible"
/// Properly wielded two handed item
#define TRAIT_WIELDED "wielded"
/// This item is currently performing a cleaving attack
#define TRAIT_CLEAVING "cleaving"
/// This item is currently parrying.
#define TRAIT_PARRYING "parrying"
/// Cannot be blocked with weapons, only shields.
#define TRAIT_UNPARRIABLE "unparriable"
/// A transforming item that is actively extended / transformed
#define TRAIT_TRANSFORM_ACTIVE "active_transform"
/// Knocks shields out of people's hands.
#define TRAIT_SHIELDBUSTER "shieldbuster"
/// Incapable of blocking.
#define TRAIT_NO_BLOCKING "no_blocking"
/// Buckling yourself to objects with this trait won't immobilize you
#define TRAIT_NO_IMMOBILIZE "no_immobilize"
/// Prevents stripping this equipment
#define TRAIT_NO_STRIP "no_strip"
/// Disallows this item from being pricetagged with a barcode
#define TRAIT_NO_BARCODES "no_barcode"
/// Allows heretics to cast their spells.
#define TRAIT_ALLOW_HERETIC_CASTING "allow_heretic_casting"
/// Designates a heart as a living heart for a heretic.
#define TRAIT_LIVING_HEART "living_heart"
/// Prevents the same person from being chosen multiple times for kidnapping objective
#define TRAIT_HAS_BEEN_KIDNAPPED "has_been_kidnapped"
/// An item still plays its hitsound even if it has 0 force, instead of the tap
#define TRAIT_CUSTOM_TAP_SOUND "no_tap_sound"
/// Makes the feedback message when someone else is putting this item on you more noticeable
#define TRAIT_DANGEROUS_OBJECT "dangerous_object"
/// determines whether or not objects are haunted and teleport/attack randomly
#define TRAIT_HAUNTED "haunted"


/// This mob always lands on their feet when they fall, for better or for worse.
#define TRAIT_CATLIKE_GRACE "catlike_grace"

///if the atom has a sticker attached to it
#define TRAIT_STICKERED "stickered"

// Debug traits
/// This object has light debugging tools attached to it
#define TRAIT_LIGHTING_DEBUGGED "lighting_debugged"

/// Gives you the Shifty Eyes quirk, rarely making people who examine you think you examined them back even when you didn't
#define TRAIT_SHIFTY_EYES "shifty_eyes"

///Trait for the gamer quirk.
#define TRAIT_GAMER "gamer"

///Trait for dryable items
#define TRAIT_DRYABLE "trait_dryable"
///Trait for dried items
#define TRAIT_DRIED "trait_dried"
/// Trait for customizable reagent holder
#define TRAIT_CUSTOMIZABLE_REAGENT_HOLDER "customizable_reagent_holder"
/// Trait for allowing an item that isn't food into the customizable reagent holder
#define TRAIT_ODD_CUSTOMIZABLE_FOOD_INGREDIENT "odd_customizable_food_ingredient"

/// Used to prevent multiple floating blades from triggering over the same target
#define TRAIT_BEING_BLADE_SHIELDED "being_blade_shielded"

/// This mob doesn't count as looking at you if you can only act while unobserved
#define TRAIT_UNOBSERVANT "trait_unobservant"

/* Traits for ventcrawling.
 * Both give access to ventcrawling, but *_NUDE requires the user to be
 * wearing no clothes and holding no items. If both present, *_ALWAYS
 * takes precedence.
 */
#define TRAIT_VENTCRAWLER_ALWAYS "ventcrawler_always"
#define TRAIT_VENTCRAWLER_NUDE "ventcrawler_nude"

/// Minor trait used for beakers, or beaker-ishes. [/obj/item/reagent_containers], to show that they've been used in a reagent grinder.
#define TRAIT_MAY_CONTAIN_BLENDED_DUST "may_contain_blended_dust"

/// Trait put on [/mob/living/carbon/human]. If that mob has a crystal core, also known as an ethereal heart, it will not try to revive them if the mob dies.
#define TRAIT_CANNOT_CRYSTALIZE "cannot_crystalize"

///Trait applied to turfs when an atmos holosign is placed on them. It will stop firedoors from closing.
#define TRAIT_FIREDOOR_STOP "firedoor_stop"

/// Trait applied when the MMI component is added to an [/obj/item/integrated_circuit]
#define TRAIT_COMPONENT_MMI "component_mmi"

/// Trait applied when an integrated circuit/module becomes undupable
#define TRAIT_CIRCUIT_UNDUPABLE "circuit_undupable"

/// Trait applied when an integrated circuit opens a UI on a player (see list pick component)
#define TRAIT_CIRCUIT_UI_OPEN "circuit_ui_open"

/// PDA/ModPC Traits. This one makes PDAs explode if the user opens the messages menu
#define TRAIT_PDA_MESSAGE_MENU_RIGGED "pda_message_menu_rigged"
/// This one denotes a PDA has received a rigged message and will explode when the user tries to reply to a rigged PDA message
#define TRAIT_PDA_CAN_EXPLODE "pda_can_explode"
///The download speeds of programs from the dowloader is halved.
#define TRAIT_MODPC_HALVED_DOWNLOAD_SPEED "modpc_halved_download_speed"

/// If present on a [/mob/living/carbon], will make them appear to have a medium level disease on health HUDs.
#define TRAIT_DISEASELIKE_SEVERITY_MEDIUM "diseaselike_severity_medium"

/// trait denoting someone will crawl faster in soft crit
#define TRAIT_TENACIOUS "tenacious"

/// trait denoting someone will sometimes recover out of crit
#define TRAIT_UNBREAKABLE "unbreakable"

/// trait that prevents AI controllers from planning detached from ai_status to prevent weird state stuff.
#define TRAIT_AI_PAUSED "TRAIT_AI_PAUSED"

/// this is used to bypass tongue language restrictions but not tongue disabilities
#define TRAIT_TOWER_OF_BABEL "tower_of_babel"

/// This target has recently been shot by a marksman coin and is very briefly immune to being hit by one again to prevent recursion
#define TRAIT_RECENTLY_COINED "recently_coined"

/// Receives echolocation images.
#define TRAIT_ECHOLOCATION_RECEIVER "echolocation_receiver"
/// Echolocation has a higher range.
#define TRAIT_ECHOLOCATION_EXTRA_RANGE "echolocation_extra_range"

/// Trait given to a living mob and any observer mobs that stem from them if they suicide.
/// For clarity, this trait should always be associated/tied to a reference to the mob that suicided- not anything else.
#define TRAIT_SUICIDED "committed_suicide"

/// Trait given to a living mob to prevent wizards from making it immortal
#define TRAIT_PERMANENTLY_MORTAL "permanently_mortal"

///Trait given to a mob with a ckey currently in a temporary body, allowing people to know someone will re-enter the round later.
#define TRAIT_MIND_TEMPORARILY_GONE "temporarily_gone"

/// Similar trait given to temporary bodies inhabited by players
#define TRAIT_TEMPORARY_BODY "temporary_body"

/// Trait given to objects with the wallmounted component
#define TRAIT_WALLMOUNTED "wallmounted"

/// Trait given to mechs that can have orebox functionality on movement
#define TRAIT_OREBOX_FUNCTIONAL "orebox_functional"

///A trait for mechs that were created through the normal construction process, and not spawned by map or other effects.
#define TRAIT_MECHA_CREATED_NORMALLY "trait_mecha_created_normally"

/// Trait given to angelic constructs to let them purge cult runes
#define TRAIT_ANGELIC "angelic"

/// Trait given to a dreaming carbon when they are currently doing dreaming stuff
#define TRAIT_DREAMING "currently_dreaming"

///generic atom traits
/// Trait from [/datum/element/rust]. Its rusty and should be applying a special overlay to denote this.
#define TRAIT_RUSTY "rust_trait"
/// Stops someone from splashing their reagent_container on an object with this trait
#define TRAIT_DO_NOT_SPLASH "do_not_splash"
/// Marks an atom when the cleaning of it is first started, so that the cleaning overlay doesn't get removed prematurely
#define TRAIT_CURRENTLY_CLEANING "currently_cleaning"
/// Objects with this trait are deleted if they fall into chasms, rather than entering abstract storage
#define TRAIT_CHASM_DESTROYED "chasm_destroyed"
/// Trait from being under the floor in some manner
#define TRAIT_UNDERFLOOR "underfloor"
/// If the movable shouldn't be reflected by mirrors.
#define TRAIT_NO_MIRROR_REFLECTION "no_mirror_reflection"
/// If this movable is currently treading in a turf with the immerse element.
#define TRAIT_IMMERSED "immersed"
/// From [/datum/element/elevation_core] for purpose of checking if the turf has the trait from an instance of the element
#define TRAIT_ELEVATED_TURF "elevated_turf"
/**
 * With this, the immerse overlay will give the atom its own submersion visual overlay
 * instead of one that's also shared with other movables, thus making editing its appearance possible.
 */
#define TRAIT_UNIQUE_IMMERSE "unique_immerse"

/// This item is currently under the control of telekinesis
#define TRAIT_TELEKINESIS_CONTROLLED "telekinesis_controlled"

/// changelings with this trait can no longer talk over the hivemind
#define TRAIT_CHANGELING_HIVEMIND_MUTE "ling_mute"
#define TRAIT_HULK "hulk"
/// Isn't attacked harmfully by blob structures
#define TRAIT_BLOB_ALLY "blob_ally"


/// This atom is currently spinning.
#define TRAIT_SPINNING "spinning"

/// Denotes that this id card was given via the job outfit, aka the first ID this player got.
#define TRAIT_JOB_FIRST_ID_CARD "job_first_id_card"
/// ID cards with this trait will attempt to forcibly occupy the front-facing ID card slot in wallets.
#define TRAIT_MAGNETIC_ID_CARD "magnetic_id_card"
/// ID cards with this trait have special appraisal text.
#define TRAIT_TASTEFULLY_THICK_ID_CARD "impressive_very_nice"
/// things with this trait are treated as having no access in /obj/proc/check_access(obj/item)
#define TRAIT_ALWAYS_NO_ACCESS "alwaysnoaccess"

/// This human wants to see the color of their glasses, for some reason
#define TRAIT_SEE_GLASS_COLORS "see_glass_colors"

// Radiation defines

/// Marks that this object is irradiated
#define TRAIT_IRRADIATED "iraddiated"

/// Harmful radiation effects, the toxin damage and the burns, will not occur while this trait is active
#define TRAIT_HALT_RADIATION_EFFECTS "halt_radiation_effects"

/// This clothing protects the user from radiation.
/// This should not be used on clothing_traits, but should be applied to the clothing itself.
#define TRAIT_RADIATION_PROTECTED_CLOTHING "radiation_protected_clothing"

/// Whether or not this item will allow the radiation SS to go through standard
/// radiation processing as if this wasn't already irradiated.
/// Basically, without this, COMSIG_IN_RANGE_OF_IRRADIATION won't fire once the object is irradiated.
#define TRAIT_BYPASS_EARLY_IRRADIATED_CHECK "radiation_bypass_early_irradiated_check"

/// Simple trait that just holds if we came into growth from a specific mob type. Should hold a REF(src) to the type of mob that caused the growth, not anything else.
#define TRAIT_WAS_EVOLVED "was_evolved_from_the_mob_we_hold_a_textref_to"

// Traits to heal for

/// This mob heals from carp rifts.
#define TRAIT_HEALS_FROM_CARP_RIFTS "heals_from_carp_rifts"

/// This mob heals from cult pylons.
#define TRAIT_HEALS_FROM_CULT_PYLONS "heals_from_cult_pylons"

/// Allows crew monitor tracking without a suit
#define TRAIT_SUITLESS_SENSORS "suitless_sensors"

/// Ignore Crew monitor Z levels
#define TRAIT_MULTIZ_SUIT_SENSORS "multiz_suit_sensors"

/// Ignores body_parts_covered during the add_fingerprint() proc. Works both on the person and the item in the glove slot.
#define TRAIT_FINGERPRINT_PASSTHROUGH "fingerprint_passthrough"

/// this object has been frozen
#define TRAIT_FROZEN "frozen"

/// Currently fishing
#define TRAIT_GONE_FISHING "fishing"

/// Makes a species be better/worse at tackling depending on their wing's status
#define TRAIT_TACKLING_WINGED_ATTACKER "tacking_winged_attacker"

/// Makes a species be frail and more likely to roll bad results if they hit a wall
#define TRAIT_TACKLING_FRAIL_ATTACKER "tackling_frail_attacker"

/// Makes a species be better/worse at defending against tackling depending on their tail's status
#define TRAIT_TACKLING_TAILED_DEFENDER "tackling_tailed_defender"

/// Is runechat for this atom/movable currently disabled, regardless of prefs or anything?
#define TRAIT_RUNECHAT_HIDDEN "runechat_hidden"

/// the object has a label applied
#define TRAIT_HAS_LABEL "labeled"

/// Trait given to a mob that is currently thinking (giving off the "thinking" icon), used in an IC context
#define TRAIT_THINKING_IN_CHARACTER "currently_thinking_IC"

///without a human having this trait, they speak as if they have no tongue.
#define TRAIT_SPEAKS_CLEARLY "speaks_clearly"

// specific sources for TRAIT_SPEAKS_CLEARLY

///Trait given by /datum/component/germ_sensitive
#define TRAIT_GERM_SENSITIVE "germ_sensitive"

/// This atom can have spells cast from it if a mob is within it
/// This means the "caster" of the spell is changed to the mob's loc
/// Note this doesn't mean all spells are guaranteed to work or the mob is guaranteed to cast
#define TRAIT_CASTABLE_LOC "castable_loc"

///Trait given by /datum/element/relay_attacker
#define TRAIT_RELAYING_ATTACKER "relaying_attacker"

///Trait given to limb by /mob/living/basic/living_limb_flesh
#define TRAIT_IGNORED_BY_LIVING_FLESH "livingflesh_ignored"

/// Trait given while using /datum/action/cooldown/mob_cooldown/wing_buffet
#define TRAIT_WING_BUFFET "wing_buffet"
/// Trait given while tired after using /datum/action/cooldown/mob_cooldown/wing_buffet
#define TRAIT_WING_BUFFET_TIRED "wing_buffet_tired"
/// Trait given to a dragon who fails to defend their rifts
#define TRAIT_RIFT_FAILURE "fail_dragon_loser"

///trait determines if this mob can breed given by /datum/component/breeding
#define TRAIT_MOB_BREEDER "mob_breeder"
/// Trait given to mobs that we do not want to mindswap
#define TRAIT_NO_MINDSWAP "no_mindswap"
///trait given to food that can be baked by /datum/component/bakeable
#define TRAIT_BAKEABLE "bakeable"

/// Trait given to foam darts that have an insert in them
#define TRAIT_DART_HAS_INSERT "dart_has_insert"

///Trait granted by janitor skillchip, allows communication with cleanbots
#define TRAIT_CLEANBOT_WHISPERER "cleanbot_whisperer"

/// Trait given when a mob is currently in invisimin mode
#define TRAIT_INVISIMIN "invisimin"

///Trait given when a mob has been tipped
#define TRAIT_MOB_TIPPED "mob_tipped"

/// Trait which self-identifies as an enemy of the law
#define TRAIT_ALWAYS_WANTED "always_wanted"

// END TRAIT DEFINES
