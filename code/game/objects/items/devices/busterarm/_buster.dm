/// Welcome to the Hell that is Buster Arm
/// I hope you find yourself at home here
/// Originally shitcoded by Lazenn, reorganized by ynot01

/* Formatting for these files, from top to bottom:
	* Action
	* Trigger()
	* IsAvailable()
	* Items
	In regards to actions or items with left and right subtypes, list the base, then left, then right.
*/
/// Base for all buster arm actions
/datum/action/cooldown/buster
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_STUN|AB_CHECK_CONSCIOUS
	transparent_when_unavailable = TRUE
	icon_icon = 'icons/mob/actions/actions_arm.dmi'

/datum/action/cooldown/buster/IsAvailable()
	. = ..()
	if(!isliving(owner))
		return FALSE
	if(HAS_TRAIT(owner, TRAIT_PACIFISM))
		return FALSE

/// Base damage application proc
/datum/action/cooldown/buster/proc/grab(mob/living/user, mob/living/target, damage)
		var/obj/item/bodypart/limb_to_hit = target.get_bodypart(user.zone_selected)
		var/armor = target.run_armor_check(limb_to_hit, MELEE, armour_penetration = 35)
		target.apply_damage(damage, BRUTE, limb_to_hit, armor, wound_bonus=CANT_WOUND)

/// Parent to buster arm items: Megabuster and Grapple (Wire snatch is a magic gun)
/obj/item/buster
	item_flags = DROPDEL
	w_class = 5
	icon = 'icons/obj/wizard.dmi'
	icon_state = "disintegrate"
	item_state = "disintegrate"
	lefthand_file = 'icons/mob/inhands/misc/touchspell_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/touchspell_righthand.dmi'

/obj/item/buster/Initialize(mob/living/user)
	. = ..()
	ADD_TRAIT(src, HAND_REPLACEMENT_TRAIT, NOBLUDGEON)

/// Item counterpart to the action's grab(), applies damage
/obj/item/buster/proc/hit(mob/living/user, mob/living/target, damage)
		var/obj/item/bodypart/limb_to_hit = target.get_bodypart(user.zone_selected)
		var/armor = target.run_armor_check(limb_to_hit, MELEE, armour_penetration = 35)
		target.apply_damage(damage, BRUTE, limb_to_hit, armor, wound_bonus=CANT_WOUND)

//knocking them down
/datum/action/cooldown/buster/proc/footsies(mob/living/target)
	if((target.mobility_flags & MOBILITY_STAND))
		animate(target, transform = matrix(90, MATRIX_ROTATE), time = 0.01 SECONDS, loop = 0)

//Check for if someone is allowed to be stood back up
/datum/action/cooldown/buster/proc/wakeup(mob/living/target)
	if((target.mobility_flags & MOBILITY_STAND))
		animate(target, transform = null, time = 0.4 SECONDS, loop = 0)
