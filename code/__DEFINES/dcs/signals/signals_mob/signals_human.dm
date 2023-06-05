// Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

// /mob/living/carbon/human signals
// /mob/living/carbon/human signals

///Hit by successful disarm attack (mob/living/carbon/human/attacker,zone_targeted)
#define COMSIG_HUMAN_DISARM_HIT "human_disarm_hit"
///Whenever EquipRanked is called, called after job is set
#define COMSIG_JOB_RECEIVED "job_received"
///from /mob/living/carbon/human/proc/set_coretemperature(): (oldvalue, newvalue)
#define COMSIG_HUMAN_CORETEMP_CHANGE "human_coretemp_change"
///from /datum/species/handle_fire. Called when the human is set on fire and burning clothes and stuff
#define COMSIG_HUMAN_BURNING "human_burning"
///from mob/living/carbon/human/UnarmedAttack(): (atom/target, proximity, modifiers)
#define COMSIG_HUMAN_EARLY_UNARMED_ATTACK "human_early_unarmed_attack"
///from mob/living/carbon/human/UnarmedAttack(): (atom/target, proximity, modifiers)
#define COMSIG_HUMAN_MELEE_UNARMED_ATTACK "human_melee_unarmed_attack"
///from /mob/living/carbon/human/proc/check_shields(): (atom/hit_by, damage, attack_text, attack_type, armour_penetration)
#define COMSIG_HUMAN_CHECK_SHIELDS "human_check_shields"
	#define SHIELD_BLOCK (1<<0)
///from /mob/living/carbon/human/proc/force_say(): ()
#define COMSIG_HUMAN_FORCESAY "human_forcesay"

//Heretics stuff
#define COMSIG_HUMAN_VOID_MASK_ACT "void_mask_act"
