/datum/eldritch_knowledge/base_ash
	name = "Nightwatcher's Secret"
	desc = "Pledges yourself to the path of Ash. Allows you to transmute a pile of ash with a knife or its derivatives into an ashen blade. Additionally, empowers your Mansus grasp to throw away enemies. You will also become more resistant to fire."
	gain_text = "Night on the Kilnplains reveals the Ashy Lantern in the sky. In your dreams, you reached out and touched it. Now, like it, you are a part of the dunes. Forever."
	banned_knowledge = list(/datum/eldritch_knowledge/base_rust,/datum/eldritch_knowledge/base_flesh,/datum/eldritch_knowledge/rust_mark,/datum/eldritch_knowledge/flesh_mark,/datum/eldritch_knowledge/rust_blade_upgrade,/datum/eldritch_knowledge/flesh_blade_upgrade,/datum/eldritch_knowledge/rust_final,/datum/eldritch_knowledge/flesh_final)
	unlocked_transmutations = list(/datum/eldritch_transmutation/ash_knife)
	cost = 1
	route = PATH_ASH
	tier = TIER_PATH

/datum/eldritch_knowledge/base_ash/on_gain(mob/user)
	. = ..()
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.physiology.heat_mod *= 0.6
	var/obj/realknife = new /obj/item/gun/magic/hook/sickly_blade/ash
	user.put_in_hands(realknife)

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
	gain_text = "Essence is versatile, flexible. It is so easy for grains to blow into all sorts of small crevices."
	desc = "A very short range jaunt that can help you escape from bad situations or navigate past obstacles."
	cost = 1
	spells_to_add = list(/obj/effect/proc_holder/spell/targeted/ethereal_jaunt/shift/ash)
	route = PATH_ASH
	tier = TIER_1

/datum/eldritch_knowledge/ashen_eyes
	name = "Eldritch Medallion"
	gain_text = "The City Guard wore these amulets when Amgala was beset by the Sanguine Horde. So too shall you be able to see the blood that flows in others."
	desc = "Allows you to craft an eldritch amulet by transmutating a pair of eyes with a glass shard. When worn, the amulet will give you thermal vision."
	unlocked_transmutations = list(/datum/eldritch_transmutation/ashen_eyes)
	cost = 1
	tier = TIER_1

/datum/eldritch_knowledge/ash_mark
	name = "Touch of the Spark"
	gain_text = "All living things are linked through their sparks. This technique represents a fraction of the Shrouded One's communality."
	desc = "Your Mansus grasp now applies a mark on hit. Use your ashen blade to detonate the mark, which causes burning that can spread to nearby targets, decreasing in damage with each jump."
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
	gain_text = "The Betrayed eternally walks the Kilnplains with a pair of blood-stained needles. She is willing to come to our world, for a price."
	desc = "Curse someone with two minutes of complete blindness by transmuting a pair of eyes, a screwdriver, and a pool of blood with an object that the victim has touched with their bare hands."
	cost = 1
	unlocked_transmutations = list(/datum/eldritch_transmutation/curse/blindness)
	route = PATH_ASH
	tier = TIER_2

/datum/eldritch_knowledge/corrosion
	name = "Curse of Corrosion"
	gain_text = "The night before he was crowned, the Nightwatcher met with each of the City Guard. Through this ritual, only one lived to see the dawn."
	desc = "Curse someone with two minutes of vomiting and major organ damage by transmuting a wirecutter, a spill of blood, a heart, a left arm, and a right arm with an item that the victim has touched with their bare hands."
	cost = 1
	unlocked_transmutations = list(/datum/eldritch_transmutation/curse/corrosion)
	tier = TIER_2

/datum/eldritch_knowledge/paralysis
	name = "Curse of Paralysis"
	gain_text = "An acolyte must provide intense envy of another's well-being, which is absorbed with the rite's materials by the Shrouded One to grant opportunity for power."
	desc = "Curse someone with five minutes of an inability to walk by transmuting a knife, a pool of blood, a left leg, a right leg, and a hatchet with an item that the victim touched with their bare hands."
	cost = 1
	unlocked_transmutations = list(/datum/eldritch_transmutation/curse/paralysis)
	tier = TIER_2

/datum/eldritch_knowledge/ash_blade_upgrade
	name = "Blade of the City Guard"
	gain_text = "The stench of boiling blood was common in the wake of the City Guard. Though they are gone, the memory of their pikes and greatswords may yet benefit you."
	desc = "Your ashen blade will now ignite targets."
	cost = 2
	banned_knowledge = list(/datum/eldritch_knowledge/rust_blade_upgrade,/datum/eldritch_knowledge/flesh_blade_upgrade)
	route = PATH_ASH
	tier = TIER_BLADE

/datum/eldritch_knowledge/ash_blade_upgrade/on_eldritch_blade(target,user,proximity_flag,click_parameters)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		C.adjust_fire_stacks(2)
		C.IgniteMob()

/datum/eldritch_knowledge/flame_birth
	name = "Flame Birth"
	gain_text = "The Nightwatcher was a man of principles, yet he arose from the chaos he vowed to protect from. This incantation sealed the fate of Amgala."
	desc = "A healing-damage spell that saps the life from those on fire nearby, killing any who are in a critical condition."
	cost = 1
	spells_to_add = list(/obj/effect/proc_holder/spell/targeted/fiery_rebirth)
	route = PATH_ASH
	tier = TIER_3

/datum/eldritch_knowledge/cleave
	name = "Blood Cleave"
	gain_text = "The Shrouded One connects all. This technique, a particular favorite of theirs, rips at the bodies of those who hunch too close to permit casuality."
	desc = "A powerful ranged spell that causes heavy bleeding and blood loss in an area around your target."
	cost = 1
	spells_to_add = list(/obj/effect/proc_holder/spell/pointed/cleave)
	tier = TIER_3

/datum/eldritch_knowledge/ash_final
	name = "Amgala's Ruin"
	gain_text = "Ash feeds the soil, and fire consumes the plants that grow thereafter. On and on and on. The Nightwatcher consumed the sparks of a whole city, yet you will rise with only three: the first step of many to claim his crown."
	desc = "Transmute three corpses to ascend as an Ashbringer. You will become immune to enviromental hazards and grow more resistant to damage. You will additionally gain a spell that creates a massive burst of fire and another spell that creates a cloak of flames around you."
	cost = 3
	unlocked_transmutations = list(/datum/eldritch_transmutation/final/ash_final)
	route = PATH_ASH
	tier = TIER_ASCEND
