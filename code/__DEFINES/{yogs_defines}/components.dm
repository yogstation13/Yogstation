#define COMSIG_STORAGE_INSERTED "storage_inserted"				//from base of /datum/component/storage/handle_item_insertion(): (obj/item/I, mob/M)
#define COMSIG_STORAGE_REMOVED "storage_removed"				//from base of /datum/component/storage/remove_from_storage(): (atom/movable/AM, atom/new_location)


#define COMSIG_JUNGLELAND_TAR_CURSE_PROC "jungleland_tar_curse_proc"
#define COMSIG_REGEN_CORE_HEALED "regen_core_healed"


#define COMSIG_MOB_CHECK_SHIELDS "check_shields"				//from base of /mob/living/carbon/human/proc/check_shields(): 
																//(atom/AM, var/damage, attack_text = "the attack", attack_type = MELEE_ATTACK, armour_penetration = 0)

#define COMSIG_KINETIC_CRUSHER_PROJECTILE_ON_RANGE "kinetic_crusher_projectile_on_range" 				// from base of /obj/projectile/destabilizer/on_range():
																										// (mob/user, /obj/item/twohanded/kinetic_crusher/hammer_synced)
#define COMSIG_KINETIC_CRUSHER_PROJECTILE_FAILED_TO_MARK "kinetic_crusher_projectile_failed_to_mark"	// from base of /obj/projectile/destabilizer/on_hit(): 
																										//(mob/user, /obj/item/twohanded/kinetic_crusher/hammer_synced)
