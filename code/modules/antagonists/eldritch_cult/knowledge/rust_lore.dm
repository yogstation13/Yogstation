/datum/eldritch_knowledge/base_rust
	name = "Blacksmith's Tale"
	desc = "Pledges yourself to the path of Rust. Allows you to transmute a piece of trash with a knife into a rusty blade. Additionally, your Mansus grasp now deal 500 damage to inorganic matter, rusts any surface it's used on, while destroying any surface that is already rusty."
	gain_text = "Outside the Ruined Keep, you drank of the River Krym. Its poison seeping through your body, years shriveled away. Yet, you were spared. Now, your purpose is clear."
	banned_knowledge = list(/datum/eldritch_knowledge/base_ash,/datum/eldritch_knowledge/base_flesh,/datum/eldritch_knowledge/ash_mark,/datum/eldritch_knowledge/flesh_mark,/datum/eldritch_knowledge/ash_blade_upgrade,/datum/eldritch_knowledge/flesh_blade_upgrade,/datum/eldritch_knowledge/ash_final,/datum/eldritch_knowledge/flesh_final)
	cost = 1
	unlocked_transmutations = list(/datum/eldritch_transmutation/rust_blade)
	route = PATH_RUST
	tier = TIER_PATH

/datum/eldritch_knowledge/base_rust/on_gain(mob/user)
	. = ..()
	var/obj/realknife = new /obj/item/gun/magic/hook/sickly_blade/rust
	user.put_in_hands(realknife)

/datum/eldritch_knowledge/base_rust/on_mansus_grasp(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(user.a_intent == INTENT_HARM)
		. = TRUE
		target.rust_heretic_act()

/datum/eldritch_knowledge/base_rust/on_eldritch_blade(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		var/datum/status_effect/eldritch/E = H.has_status_effect(/datum/status_effect/eldritch/rust) || H.has_status_effect(/datum/status_effect/eldritch/ash) || H.has_status_effect(/datum/status_effect/eldritch/flesh)
		if(E)
			E.on_effect()
			H.adjustOrganLoss(pick(ORGAN_SLOT_BRAIN,ORGAN_SLOT_EARS,ORGAN_SLOT_EYES,ORGAN_SLOT_LIVER,ORGAN_SLOT_LUNGS,ORGAN_SLOT_STOMACH,ORGAN_SLOT_HEART),25)

/datum/eldritch_knowledge/rust_regen
	name = "Leeching Walk"
	gain_text = "His strength was unparalleled, it was unnatural. The Blacksmith was smiling."
	desc = "Passively heals you when you are on rusted tiles."
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
	living_user.adjustToxLoss(-2, FALSE, TRUE)
	living_user.adjustOxyLoss(-0.5, FALSE)
	living_user.adjustStaminaLoss(-2)

/datum/eldritch_knowledge/armor
	name = "Eldritch Armor"
	gain_text = "For I am the heir to the throne of their doom."
	desc = "Allows you to craft a set of eldritch armor by transmuting a table and a gas mask. The robes significantly reduce most incoming damage."
	cost = 1
	unlocked_transmutations = list(/datum/eldritch_transmutation/armor)
	tier = TIER_1

/datum/eldritch_knowledge/essence
	name = "Eldritch Essence"
	gain_text = "I learned an old recipe, taught by an Owl in my dreams."
	desc = "Allows you to craft a flask of eldritch essence by transmuting a water tank. The reagent will heal you and damage those not linked to the Mansus."
	cost = 1
	unlocked_transmutations = list(/datum/eldritch_transmutation/water)
	tier = TIER_1

/datum/eldritch_knowledge/rust_mark
	name = "Mark of Rust"
	gain_text = "Lords of the depths help those in dire need at a cost."
	desc = "Your Mansus grasp now applies a mark on hit. Use your rusty blade to detonate the mark, which has a chance to deal between 0 to 200 damage to 75% of your target's items."
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
	gain_text = "All men wise know not to touch the bound king."
	desc = "An instant spell that spreads rust onto nearby tiles, destroying any already rusted."
	cost = 1
	spells_to_add = list(/obj/effect/proc_holder/spell/aoe_turf/rust_conversion)
	route = PATH_RUST
	tier = TIER_2

/datum/eldritch_knowledge/rust_blade_upgrade
	name = "Toxic Blade"
	gain_text = "Let your blade guide you through the flesh."
	desc = "Your rusted blade now injects eldritch essence on hit."
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
	gain_text = "Messengers of hope fear I, the Rustbringer!"
	desc = "A cone spell that expels befuddling plume that rusts tiles, then blinds, poisons, and forces targets to strike each other."
	cost = 1
	spells_to_add = list(/obj/effect/proc_holder/spell/cone/staggered/entropic_plume)
	route = PATH_RUST
	tier = TIER_3

/datum/eldritch_knowledge/rust_final
	name = "Rustbringer's Oath"
	gain_text = "Champion of rust. Corruptor of steel. Fear the dark for the Rustbringer has come!"
	desc = "Transmute three corpses to ascend as a Sovereign of Decay. Your healing on rust tiles will be tripled, and you will become much more resilient to damage. In addition, rust will spread from your ritual site."
	cost = 3
	unlocked_transmutations = list(/datum/eldritch_transmutation/final/rust_final)
	route = PATH_RUST
	tier = TIER_ASCEND
