/datum/material_trait
	var/name = "Generic Material Trait"
	var/desc = "Does generic material things."
	var/trait_flags = NONE
	var/reforges = 4
	var/value_bonus = 0
///Called when added to an object
/datum/material_trait/proc/on_trait_add(atom/movable/parent)
	return
///Called when removed from an object
/datum/material_trait/proc/on_remove(atom/movable/parent)
	return
///Called on processing tick
/datum/material_trait/proc/on_process(atom/movable/parent, datum/material_stats/host)
	return
///Called when used to attack a living mob
/datum/material_trait/proc/on_mob_attack(atom/movable/parent, datum/material_stats/host, mob/living/target, mob/living/attacker)
	return
///Called after the atom has been Initialized. Modfiy the finished products here.
/datum/material_trait/proc/post_parent_init(atom/movable/parent)
	return
