/datum/eldritch_knowledge/base_rust
	name = "Blacksmith's Tale"
	desc = "Opens up the path of rust to you. Allows you to transmute a knife with any trash item into a Rusty Blade. Additionally, your mansus grasp now deal 500 damage to inorganic matter. Rusts any surface it's used on, and destroys any surface that is already rusty."
	gain_text = "Let me tell you a story, The Blacksmith said as he gazed into his rusty blade."
	banned_knowledge = list(/datum/eldritch_knowledge/base_ash,/datum/eldritch_knowledge/base_flesh,/datum/eldritch_knowledge/ash_mark,/datum/eldritch_knowledge/flesh_mark,/datum/eldritch_knowledge/ash_blade_upgrade,/datum/eldritch_knowledge/flesh_blade_upgrade,/datum/eldritch_knowledge/ash_final,/datum/eldritch_knowledge/flesh_final)
	cost = 1
	unlocked_transmutations = list(/datum/eldritch_transmutation/rust_blade)
	route = PATH_RUST
	tier = TIER_PATH

/datum/eldritch_knowledge/base_rust/on_mansus_grasp(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	target.rust_heretic_act()
	return TRUE

/datum/eldritch_knowledge/base_rust/on_eldritch_blade(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		var/datum/status_effect/eldritch/E = H.has_status_effect(/datum/status_effect/eldritch/rust) || H.has_status_effect(/datum/status_effect/eldritch/ash) || H.has_status_effect(/datum/status_effect/eldritch/flesh)
		if(E)
			E.on_effect()
			H.adjustOrganLoss(pick(ORGAN_SLOT_BRAIN,ORGAN_SLOT_EARS,ORGAN_SLOT_EYES,ORGAN_SLOT_LIVER,ORGAN_SLOT_LUNGS,ORGAN_SLOT_STOMACH,ORGAN_SLOT_HEART),25)
	else if(user.a_intent == INTENT_HARM)
		. = TRUE
		target.rust_heretic_act()

/datum/eldritch_knowledge/rust_regen
	name = "Leeching Walk"
	desc = "Passively heals you when you are on rusted tiles."
	gain_text = "His strength was unparalleled, it was unnatural. The Blacksmith was smiling."
	cost = 1
	route = PATH_RUST
	tier = TIER_1

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

/datum/eldritch_knowledge/armor
	name = "Armorer's ritual"
	desc = "You can now create a powerful set of armor by transmuting a table and gas mask."
	gain_text = "For I am the heir to the throne of their doom."
	cost = 1
	unlocked_transmutations = list(/datum/eldritch_transmutation/armor)
	tier = TIER_1

/datum/eldritch_knowledge/essence
	name = "Priest's ritual"
	desc = "You can now transmute a tank of water into a bottle of eldritch water."
	gain_text = "I learned an old recipe, taught by an Owl in my dreams."
	cost = 1
	unlocked_transmutations = list(/datum/eldritch_transmutation/water)
	tier = TIER_1

/datum/eldritch_knowledge/rust_mark
	name = "Mark of Rust"
	desc = "Your mansus grasp now applies a rust mark. To Detonate the mark use your eldritch blade on it. The rust mark has a chance to deal between 0 to 200 damage to 75% of enemies items."
	gain_text = "Lords of the depths help those in dire need at a cost."
	cost = 2
	banned_knowledge = list(/datum/eldritch_knowledge/ash_mark,/datum/eldritch_knowledge/flesh_mark)
	route = PATH_RUST
	tier = TIER_MARK

/datum/eldritch_knowledge/rust_mark/on_mansus_grasp(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(isliving(target))
		var/mob/living/living_target = target
		living_target.apply_status_effect(/datum/status_effect/eldritch/rust)

/datum/eldritch_knowledge/area_conversion
	name = "Agressive Spread"
	desc = "Spreads rust to nearby turfs. Destroys already rusted walls."
	gain_text = "All men wise know not to touch the bound king."
	cost = 1
	spells_to_add = list(/obj/effect/proc_holder/spell/aoe_turf/rust_conversion)
	route = PATH_RUST
	tier = TIER_2

/datum/eldritch_knowledge/rust_blade_upgrade
	name = "Toxic blade"
	gain_text = "Let your blade guide you through the flesh."
	desc = "Your blade of choice will now add toxin to enemies bloodstream."
	cost = 2
	banned_knowledge = list(/datum/eldritch_knowledge/ash_blade_upgrade,/datum/eldritch_knowledge/flesh_blade_upgrade)
	route = PATH_RUST
	tier = TIER_BLADE

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
	route = PATH_RUST
	tier = TIER_3

/datum/eldritch_knowledge/rust_final
	name = "Rustbringer's Oath"
	desc = "Bring 3 corpses onto the transmutation rune. After you finish the ritual rust will now automatically spread from the rune. Your healing on rust is also tripled, while you become more resillient overall."
	gain_text = "Champion of rust. Corruptor of steel. Fear the dark for the Rustbringer has come!"
	cost = 3
	unlocked_transmutations = list(/datum/eldritch_transmutation/final/rust_final)
	route = PATH_RUST
	tier = TIER_ASCEND
