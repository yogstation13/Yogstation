/datum/eldritch_knowledge/base_ash
	name = "Nightwatcher's Secret"
	desc = "Opens up the path of ash to you. Allows you to transmute a match with a knife or its derivatives into an ashen blade. Additionally empowers your mansus grasp to throw away enemies."
	gain_text = "The City Guard knows their watch. If you ask them past dusk they may tell you tales of the Ashy Lantern."
	banned_knowledge = list(/datum/eldritch_knowledge/base_rust,/datum/eldritch_knowledge/base_flesh,/datum/eldritch_knowledge/rust_mark,/datum/eldritch_knowledge/flesh_mark,/datum/eldritch_knowledge/rust_blade_upgrade,/datum/eldritch_knowledge/flesh_blade_upgrade,/datum/eldritch_knowledge/rust_final,/datum/eldritch_knowledge/flesh_final)
	unlocked_transmutations = list(/datum/eldritch_transmutation/ash_knife)
	cost = 1
	route = PATH_ASH
	tier = TIER_PATH

/datum/eldritch_knowledge/base_ash/on_mansus_grasp(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!iscarbon(target))
		return
	var/mob/living/carbon/C = target
	var/atom/throw_target = get_edge_target_turf(C, user.dir)
	if(!C.anchored)
		. = TRUE
		C.throw_at(throw_target, rand(4,8), 14, user)
	return

/datum/eldritch_knowledge/base_ash/on_eldritch_blade(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!iscarbon(target))
		return
	var/mob/living/carbon/C = target
	var/datum/status_effect/eldritch/E = C.has_status_effect(/datum/status_effect/eldritch/rust) || C.has_status_effect(/datum/status_effect/eldritch/ash) || C.has_status_effect(/datum/status_effect/eldritch/flesh)
	if(E)
		E.on_effect()
		for(var/X in user.mind.spell_list)
			if(!istype(X,/obj/effect/proc_holder/spell/targeted/touch/mansus_grasp))
				continue
			var/obj/effect/proc_holder/spell/targeted/touch/mansus_grasp/MG = X
			MG.charge_counter = min(round(MG.charge_counter + MG.charge_max * 0.75),MG.charge_max) // refunds 75% of charge.

/datum/eldritch_knowledge/ashen_shift
	name = "Ashen Shift"
	gain_text = "Ash is so simple, yet so numerous. Is it possible to master it all?"
	desc = "Short range jaunt that can help you escape from bad situations."
	cost = 1
	spells_to_add = list(/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shift/ash)
	route = PATH_ASH
	tier = TIER_1

/datum/eldritch_knowledge/ashen_eyes
	name = "Ashen Eyes"
	gain_text = "These piercing eyes may guide me through the mundane."
	desc = "Allows you to craft an eldritch amulet by transmutating eyes with a glass shard. When worn, the amulet will give you thermal vision."
	unlocked_transmutations = list(/datum/eldritch_transmutation/ashen_eyes)
	cost = 1
	tier = TIER_1


/datum/eldritch_knowledge/ash_mark
	name = "Mark of Ash"
	gain_text = "Spread the famine."
	desc = "Your mansus grasp now applies ash mark on hit. Use your sickly blade to detonate the mark. The Mark of Ash causes stamina damage, and fire loss, and spreads to a nearby carbon. Damage decreases with how many times the mark has spread."
	cost = 2
	banned_knowledge = list(/datum/eldritch_knowledge/rust_mark,/datum/eldritch_knowledge/flesh_mark)
	route = PATH_ASH
	tier = TIER_MARK

/datum/eldritch_knowledge/ash_mark/on_mansus_grasp(atom/target,mob/user,proximity_flag,click_parameters)
	. = ..()
	if(isliving(target))
		. = TRUE
		var/mob/living/living_target = target
		living_target.apply_status_effect(/datum/status_effect/eldritch/ash,5)

/datum/eldritch_knowledge/blindness
	name = "Curse of Blindness"
	gain_text = "The Blind Man walks through the world, unnoticed by the masses."
	desc = "Curse someone with 2 minutes of complete blindness by transmuting a pair of eyes, a screwdriver and a pool of blood, with an object that the victim has touched with their bare hands."
	cost = 1
	unlocked_transmutations = list(/datum/eldritch_transmutation/curse/blindness)
	route = PATH_ASH
	tier = TIER_2

/datum/eldritch_knowledge/corrosion
	name = "Curse of Corrosion"
	gain_text = "Cursed land, Cursed man, Cursed mind."
	desc = "Curse someone for 2 minutes of vomiting and major organ damage by transmuting a wirecutter, a spill of blood, a heart, left arm and a right arm, and an item that the victim touched  with their bare hands."
	cost = 1
	unlocked_transmutations = list(/datum/eldritch_transmutation/curse/corrosion)
	tier = TIER_2

/datum/eldritch_knowledge/paralysis
	name = "Curse of Paralysis"
	gain_text = "Corrupt their flesh, make them suffer."
	desc = "Curse someone for 5 minutes of inability to walk. Using a knife, pool of blood, left leg, right leg, a hatchet and an item that the victim touched with their bare hands. "
	cost = 1
	unlocked_transmutations = list(/datum/eldritch_transmutation/curse/paralysis)
	tier = TIER_2

/datum/eldritch_knowledge/ash_blade_upgrade
	name = "Fiery Blade"
	gain_text = "May the sun burn the heretics."
	desc = "Your blade of choice will now add firestacks."
	cost = 2
	banned_knowledge = list(/datum/eldritch_knowledge/rust_blade_upgrade,/datum/eldritch_knowledge/flesh_blade_upgrade)
	route = PATH_ASH
	tier = TIER_BLADE

/datum/eldritch_knowledge/ash_blade_upgrade/on_eldritch_blade(target,user,proximity_flag,click_parameters)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		C.adjust_fire_stacks(1)
		C.IgniteMob()

/datum/eldritch_knowledge/flame_birth
	name = "Flame Birth"
	gain_text = "The Nightwatcher was a man of principles, and yet he arose from the chaos he vowed to protect from."
	desc = "A healing spell that saps the life from those combusted nearby."
	cost = 1
	spells_to_add = list(/obj/effect/proc_holder/spell/targeted/fiery_rebirth)
	route = PATH_ASH
	tier = TIER_3

/datum/eldritch_knowledge/cleave
	name = "Blood Cleave"
	gain_text = "At first I didn't know these instruments of war, but The Priest told me to use them."
	desc = "Gives AOE spell that causes heavy bleeding and blood loss."
	cost = 1
	spells_to_add = list(/obj/effect/proc_holder/spell/pointed/cleave)
	tier = TIER_3

/datum/eldritch_knowledge/ash_final
	name = "Ashlord's Rite"
	gain_text = "The forgotten lords have spoken! The lord of ash have come! Fear the fire!"
	desc = "Bring 3 corpses onto a transmutation rune, you will become immune to enviromental hazards and become overall sturdier to all other damage. You will additionally gain a spell that creates a massive burst of fire, and one that creates a cloak of flames around you."
	cost = 3
	unlocked_transmutations = list(/datum/eldritch_transmutation/final/ash_final)
	route = PATH_ASH
	tier = TIER_ASCEND
