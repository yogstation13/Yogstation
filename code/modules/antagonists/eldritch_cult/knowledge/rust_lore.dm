/datum/eldritch_knowledge/base_rust
	name = "Blacksmith's Tale"
	desc = "Opens up the path of rust to you. Allows you to transmute a knife with any trash item into a Rusty Blade."
	gain_text = "Let me tell you a story, The Blacksmith said as he gazed into his rusty blade."
	banned_knowledge = list(/datum/eldritch_knowledge/base_ash,/datum/eldritch_knowledge/base_flesh,/datum/eldritch_knowledge/ash_final,/datum/eldritch_knowledge/flesh_final)
	next_knowledge = list(/datum/eldritch_knowledge/rust_fist)
	cost = 1
	unlocked_transmutations = list(/datum/eldritch_transmutation/rust_blade)
	route = PATH_RUST

/datum/eldritch_knowledge/rust_fist
	name = "Grasp of rust"
	desc = "Empowers your mansus grasp to deal 500 damage to non-living matter and rust any turf it touches. Destroys already rusted turfs."
	gain_text = "Rust grows on the ceiling of the mansus."
	cost = 1
	next_knowledge = list(/datum/eldritch_knowledge/rust_regen)
	var/rust_force = 500
	var/static/list/blacklisted_turfs = typecacheof(list(/turf/closed,/turf/open/space,/turf/open/lava,/turf/open/chasm,/turf/open/floor/plating/rust))
	route = PATH_RUST

/datum/eldritch_knowledge/rust_fist/on_mansus_grasp(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		var/datum/status_effect/eldritch/E = H.has_status_effect(/datum/status_effect/eldritch/rust) || H.has_status_effect(/datum/status_effect/eldritch/ash) || H.has_status_effect(/datum/status_effect/eldritch/flesh)
		if(E)
			E.on_effect()
			H.adjustOrganLoss(pick(ORGAN_SLOT_BRAIN,ORGAN_SLOT_EARS,ORGAN_SLOT_EYES,ORGAN_SLOT_LIVER,ORGAN_SLOT_LUNGS,ORGAN_SLOT_STOMACH,ORGAN_SLOT_HEART),25)
	target.rust_heretic_act()
	return TRUE

/datum/eldritch_knowledge/area_conversion
	name = "Agressive Spread"
	desc = "Spreads rust to nearby turfs. Destroys already rusted walls."
	gain_text = "All men wise know not to touch the bound king."
	cost = 1
	spells_to_add = list(/obj/effect/proc_holder/spell/aoe_turf/rust_conversion)
	next_knowledge = list(/datum/eldritch_knowledge/rust_blade_upgrade,/datum/eldritch_knowledge/corrosion,/datum/eldritch_knowledge/blood_siphon)
	route = PATH_RUST

/datum/eldritch_knowledge/rust_regen
	name = "Leeching Walk"
	desc = "Passively heals you when you are on rusted tiles."
	gain_text = "His strength was unparallel, it was unnatural. The Blacksmith was smiling."
	cost = 1
	next_knowledge = list(/datum/eldritch_knowledge/rust_mark,/datum/eldritch_knowledge/armor,/datum/eldritch_knowledge/essence)
	route = PATH_RUST

/datum/eldritch_knowledge/rust_regen/on_life(mob/user)
	. = ..()
	var/turf/user_loc_turf = get_turf(user)
	if(!istype(user_loc_turf, /turf/open/floor/plating/rust) || !isliving(user))
		return
	var/mob/living/living_user = user
	living_user.adjustBruteLoss(-2, FALSE)
	living_user.adjustFireLoss(-2, FALSE)
	living_user.adjustToxLoss(-2, FALSE)
	living_user.adjustOxyLoss(-0.5, FALSE)
	living_user.adjustStaminaLoss(-2)

/datum/eldritch_knowledge/rust_mark
	name = "Mark of Rust"
	desc = "Your eldritch blade now applies a rust mark. The Rust Mark has a chance to deal between 0 to 200 damage to 75% of enemies items. To Detonate the Mark use your mansus grasp on it."
	gain_text = "Lords of the depths help those in dire need at a cost."
	cost = 2
	next_knowledge = list(/datum/eldritch_knowledge/area_conversion)
	banned_knowledge = list(/datum/eldritch_knowledge/ash_mark,/datum/eldritch_knowledge/flesh_mark)
	route = PATH_RUST

/datum/eldritch_knowledge/rust_mark/on_eldritch_blade(target,user,proximity_flag,click_parameters)
	. = ..()
	if(isliving(target))
		var/mob/living/living_target = target
		living_target.apply_status_effect(/datum/status_effect/eldritch/rust)

/datum/eldritch_knowledge/rust_blade_upgrade
	name = "Toxic blade"
	gain_text = "Let your blade guide you through the flesh."
	desc = "Your blade of choice will now add toxin to enemies bloodstream."
	cost = 2
	next_knowledge = list(/datum/eldritch_knowledge/entropic_plume)
	banned_knowledge = list(/datum/eldritch_knowledge/ash_blade_upgrade,/datum/eldritch_knowledge/flesh_blade_upgrade)
	route = PATH_RUST

/datum/eldritch_knowledge/rust_blade_upgrade/on_eldritch_blade(target,user,proximity_flag,click_parameters)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/carbon_target = target
		carbon_target.reagents.add_reagent(/datum/reagent/eldritch, 2)

/datum/eldritch_knowledge/entropic_plume
	name = "Entropic Plume"
	desc = "You can now send a befuddling plume that blinds, poisons and makes enemies strike each other. Also converts the area into rust."
	gain_text = "Messengers of hope fear I, the Rustbringer!"
	cost = 1
	spells_to_add = list(/obj/effect/proc_holder/spell/cone/staggered/entropic_plume)
	next_knowledge = list(/datum/eldritch_knowledge/rust_final,/datum/eldritch_knowledge/cleave,/datum/eldritch_knowledge/rusty)
	route = PATH_RUST

/datum/eldritch_knowledge/armor
	name = "Armorer's ritual"
	desc = "You can now create a powerful set of armor by transmuting a table and gas mask."
	gain_text = "For I am the heir to the throne of their doom."
	cost = 1
	next_knowledge = list(/datum/eldritch_knowledge/rust_regen,/datum/eldritch_knowledge/flesh_ghoul)
	unlocked_transmutations = list(/datum/eldritch_transmutation/armor)

/datum/eldritch_knowledge/essence
	name = "Priest's ritual"
	desc = "You can now transmute a tank of water into a bottle of eldritch water."
	gain_text = "I learned an old recipe, tought by an Owl in my dreams."
	cost = 1
	next_knowledge = list(/datum/eldritch_knowledge/rust_regen,/datum/eldritch_knowledge/ashen_shift)
	unlocked_transmutations = list(/datum/eldritch_transmutation/water)

/datum/eldritch_knowledge/rust_final
	name = "Rustbringer's Oath"
	desc = "Bring 3 corpses onto the transmutation rune. After you finish the ritual rust will now automatically spread from the rune. Your healing on rust is also tripled, while you become more resillient overall."
	gain_text = "Champion of rust. Corruptor of steel. Fear the dark for the Rustbringer has come!"
	cost = 3
	unlocked_transmutations = list(/datum/eldritch_transmutation/final/rust_final)
	route = PATH_RUST
