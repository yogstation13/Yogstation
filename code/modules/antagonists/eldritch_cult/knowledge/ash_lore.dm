/datum/eldritch_knowledge/base_ash
	name = "Nightwatcher's Secret"
	desc = "Pledges yourself to the path of Ash. Allows you to transmute a pile of ash with a knife or its derivatives into an ashen blade. Additionally, empowers your Mansus grasp to throw enemies away from you. You will also become more resistant to fire."
	gain_text = "Night on the Kilnplains reveals the Ashy Lantern in the sky. In your dreams, you reached out and touched it. Now, like it, you are a part of the dunes. Forever."
	unlocked_transmutations = list(/datum/eldritch_transmutation/ash_knife)
	cost = 1
	route = PATH_ASH
	tier = TIER_PATH

/datum/eldritch_knowledge/base_ash/on_gain(mob/user)
	. = ..()
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.physiology.heat_mod *= 0.4
		H.physiology.burn_mod *= 0.8
	var/obj/realknife = new /obj/item/melee/sickly_blade/ash
	user.put_in_hands(realknife)
	///use is if you want to swap out a spell they get upon becoming their certain type of heretic
	var/datum/action/cooldown/spell/basic_jaunt = locate(/datum/action/cooldown/spell/jaunt/ethereal_jaunt/basic) in user.actions
	if(basic_jaunt)
		basic_jaunt.Remove(user)
	var/datum/action/cooldown/spell/jaunt/ethereal_jaunt/ash/ash_jaunt = new(user)
	ash_jaunt.Grant(user)

	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, PROC_REF(on_mansus_grasp))

/datum/eldritch_knowledge/base_ash/on_lose(mob/user)
	UnregisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK)

/datum/eldritch_knowledge/base_ash/proc/on_mansus_grasp(mob/living/source, mob/living/target)
	SIGNAL_HANDLER

	if(!iscarbon(target))
		return COMPONENT_BLOCK_HAND_USE
	var/mob/living/carbon/C = target
	var/atom/throw_target = get_edge_target_turf(C, source.dir)
	if(!C.anchored)
		C.throw_at(throw_target, rand(4,8), 14, source)

/datum/eldritch_knowledge/base_ash/on_eldritch_blade(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!iscarbon(target))
		return
	var/mob/living/carbon/C = target
	var/datum/status_effect/eldritch/E = C.has_status_effect(/datum/status_effect/eldritch/rust) || C.has_status_effect(/datum/status_effect/eldritch/ash) || C.has_status_effect(/datum/status_effect/eldritch/flesh) || C.has_status_effect(/datum/status_effect/eldritch/void) || C.has_status_effect(/datum/status_effect/eldritch/cosmic)
	if(E)
		// Also refunds 75% of charge!
		var/datum/action/cooldown/spell/touch/mansus_grasp/grasp = locate() in user.actions
		if(grasp)
			grasp.next_use_time = min(round(grasp.next_use_time - grasp.cooldown_time * 0.75, 0), 0)
			grasp.build_all_button_icons()

/datum/eldritch_knowledge/madness_mask
	name = "T1 - Mask of Madness"
	gain_text = "Those cursed to walk this forsaken ash covered desert don this masks to protect them from the heat, and to scare away unwanted visitors"
	desc = "Transmute a mask, and a raw liver to create a Mask of Madness. It causes passive stamina damage and hallucinations to everyone around the wearer."
	cost = 1
	unlocked_transmutations = list(/datum/eldritch_transmutation/madness_mask)
	route = PATH_ASH
	tier = TIER_1

/datum/eldritch_knowledge/ashen_eyes
	name = "T1 - Eldritch Medallion"
	gain_text = "The City Guard wore these amulets when Amgala was beset by the Sanguine Horde. So too shall you be able to see the blood that flows in others."
	desc = "Allows you to craft an eldritch amulet by transmuting a pair of eyes with a glass shard. When worn, the amulet will give you thermal vision."
	unlocked_transmutations = list(/datum/eldritch_transmutation/ashen_eyes)
	cost = 1
	route = PATH_ASH
	tier = TIER_1

/datum/eldritch_knowledge/ash_mark
	name = "Grasp Mark - Touch of the Spark"
	gain_text = "All living things are linked through their sparks. This technique represents a fraction of the Shrouded One's communality."
	desc = "Your Mansus grasp now applies a mark on hit. Use your ashen blade to detonate the mark, which causes burning that can spread to nearby targets, decreasing in damage with each jump."
	cost = 2
	route = PATH_ASH
	tier = TIER_MARK

/datum/eldritch_knowledge/ash_mark/on_gain(mob/user)
	. = ..()
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, PROC_REF(on_mansus_grasp))

/datum/eldritch_knowledge/ash_mark/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	UnregisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK)

/datum/eldritch_knowledge/ash_mark/proc/on_mansus_grasp(mob/living/source, mob/living/target)
	SIGNAL_HANDLER

	if(isliving(target))
		var/mob/living/living_target = target
		living_target.apply_status_effect(/datum/status_effect/eldritch/ash, 5)

// WILL COME BACK TO CURSES AT A LATER DATE 

// /datum/eldritch_knowledge/blindness
	// name = "T1 - Curse of Blindness"
	// gain_text = "The Betrayed eternally walks the Kilnplains with a pair of blood-stained needles. She is willing to come to our world, for a price."
	// desc = "Curse someone with two minutes of complete blindness by transmuting a pair of eyes, a screwdriver, and a pool of blood with an object that the victim has touched with their bare hands."
	// cost = 1
	// unlocked_transmutations = list(/datum/eldritch_transmutation/curse/blindness)
	// tier = TIER_1

/datum/eldritch_knowledge/spell/volcano_blast
	name = "T2 - Volcano Blast"
	gain_text = "The strongest fires come from within, expel a piece of your burning soul to show you enemies the truth of flame."
	desc = "Shoot a strong blast of fire at an enemy."
	cost = 1
	spell_to_add = /datum/action/cooldown/spell/pointed/projectile/fireball/eldritch
	route = PATH_ASH
	tier = TIER_2

// /datum/eldritch_knowledge/corrosion
	//name = "T2 - Curse of Corrosion"
	//gain_text = "The night before he was crowned, the Nightwatcher met with each of the City Guard. Through this ritual, only one lived to see the dawn."
	//desc = "Curse someone with two minutes of vomiting and major organ damage by transmuting a wirecutter, a spill of blood, a heart, a left arm, and a right arm with an item that the victim has touched with their bare hands."
	//cost = 1
	//unlocked_transmutations = list(/datum/eldritch_transmutation/curse/corrosion)
	//tier = TIER_2

// /datum/eldritch_knowledge/paralysis
	//name = "T2 - Curse of Paralysis"
	//gain_text = "An acolyte must provide intense envy of another's well-being, which is absorbed with the rite's materials by the Shrouded One to grant opportunity for power."
	//desc = "Curse someone with five minutes of an inability to walk by transmuting a knife, a pool of blood, a left leg, a right leg, and a hatchet with an item that the victim touched with their bare hands."
	//cost = 1
	//unlocked_transmutations = list(/datum/eldritch_transmutation/curse/paralysis)
	//tier = TIER_2

/datum/eldritch_knowledge/ash_blade_upgrade
	name = "Blade Upgrade - Blade of the City Guard"
	gain_text = "The stench of boiling blood was common in the wake of the City Guard. Though they are gone, the memory of their pikes and greatswords may yet benefit you."
	desc = "Your ashen blade will now ignite targets."
	cost = 2
	route = PATH_ASH
	tier = TIER_BLADE

/datum/eldritch_knowledge/ash_blade_upgrade/on_eldritch_blade(target,user,proximity_flag,click_parameters)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		C.adjust_fire_stacks(2)
		C.ignite_mob()

/datum/eldritch_knowledge/spell/flame_birth
	name = "T3 - Flame Birth"
	gain_text = "The Nightwatcher was a man of principles, yet he arose from the chaos he vowed to protect from. This incantation sealed the fate of Amgala."
	desc = "A healing-damage spell that saps the life from those on fire nearby, killing any who are in a critical condition."
	cost = 1
	spell_to_add = /datum/action/cooldown/spell/aoe/fiery_rebirth
	route = PATH_ASH
	tier = TIER_3

/datum/eldritch_knowledge/spell/cleave
	name = "T3 - Blood Cleave"
	gain_text = "The Shrouded One connects all. This technique, a particular favorite of theirs, rips at the bodies of those who hunch too close to permit casuality."
	desc = "A powerful ranged spell that causes heavy bleeding and blood loss in an area around your target."
	cost = 1
	spell_to_add = /datum/action/cooldown/spell/pointed/cleave
	route = PATH_ASH
	tier = TIER_3

/datum/eldritch_knowledge/ash_final
	name = "Ascension Rite - Amgala's Ruin"
	gain_text = "Ash feeds the soil, and fire consumes the plants that grow thereafter. On and on and on. The Nightwatcher consumed the sparks of a whole city, yet you will rise with only three: the first step of many to claim his crown."
	desc = "Transmute three corpses to ascend as an Ashbringer. You will become immune to environmental hazards and grow more resistant to damage. You will additionally gain a spell that creates a massive burst of fire and another spell that creates a cloak of flames around you."
	cost = 3
	unlocked_transmutations = list(/datum/eldritch_transmutation/final/ash_final)
	route = PATH_ASH
	tier = TIER_ASCEND
