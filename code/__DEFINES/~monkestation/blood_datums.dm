#define COMSIG_HUMAN_ON_HANDLE_BLOOD "human_on_handle_blood"
	#define HANDLE_BLOOD_HANDLED (1<<0)
	#define HANDLE_BLOOD_NO_NUTRITION_DRAIN (1<<1)
	#define HANDLE_BLOOD_NO_EFFECTS (1<<2)

#define COLOR_BLOOD "#c90000"

/// Modifier used in math involving bloodiness, so the above values can be adjusted easily
#define BLOOD_PER_UNIT_MODIFIER 0.5

/// from /datum/status_effect/limp/proc/check_step()
#define COMSIG_CARBON_LIMPING "mob_limp_check"
	#define COMPONENT_CANCEL_LIMP (1<<0)

/// Mob can walk despite having two disabled/missing legs so long as they have two of this trait.
/// Kind of jank, refactor at a later day when I can think of a better solution.
/// Just be sure to call update_limbless_locomotion() after applying / removal
#define TRAIT_NO_LEG_AID "no_leg_aid"

/// Updating a mob's movespeed when lacking limbs. (list/modifiers)
#define COMSIG_LIVING_LIMBLESS_MOVESPEED_UPDATE "living_get_movespeed_modifiers"

/// Updating a mob's movespeed when they have the feeble trait. (list/modifiers)
#define COMSIG_LIVING_FEEBLE_MOVESPEED_UPDATE "living_get_movespeed_modifiers_feeble"
