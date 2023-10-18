/datum/eldritch_knowledge/base_blade
	name = "The Cutting Edge"
	desc = "Pledges yourself to the path of Blade. Allows you to transmute a bar of silver with a knife or its derivatives into a Sundered Blade. Additionally, empowers your Mansus grasp to throw enemies away from you. You will also become more resistant to fire."
	gain_text = "Our great ancestors forged swords and practiced sparring on the eve of great battles."
	banned_knowledge = list(
		/datum/eldritch_knowledge/base_ash,
		/datum/eldritch_knowledge/base_rust,
		/datum/eldritch_knowledge/base_flesh,
		/datum/eldritch_knowledge/base_mind,
		/datum/eldritch_knowledge/base_void,
		/datum/eldritch_knowledge/ash_mark,
		/datum/eldritch_knowledge/rust_mark,
		/datum/eldritch_knowledge/flesh_mark,
		/datum/eldritch_knowledge/mind_mark,
		/datum/eldritch_knowledge/void_mark,
		/datum/eldritch_knowledge/ash_blade_upgrade,
		/datum/eldritch_knowledge/rust_blade_upgrade,
		/datum/eldritch_knowledge/flesh_blade_upgrade,
		/datum/eldritch_knowledge/mind_blade_upgrade,
		/datum/eldritch_knowledge/void_blade_upgrade,
		/datum/eldritch_knowledge/ash_final,
		/datum/eldritch_knowledge/rust_final,
		/datum/eldritch_knowledge/flesh_final,
		/datum/eldritch_knowledge/mind_final,
		/datum/eldritch_knowledge/void_final)
	unlocked_transmutations = list(/datum/eldritch_transmutation/dark_knife)
	cost = 1
	route = PATH_BLADE
	tier = TIER_PATH

/datum/eldritch_knowledge/base_blade/on_gain(mob/user)
	. = ..()
	var/obj/realknife = new /obj/item/melee/sickly_blade/dark
	user.put_in_hands(realknife)
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, PROC_REF(on_mansus_grasp))

/datum/eldritch_knowledge/base_blade/on_lose(mob/user)
	UnregisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK)

/datum/eldritch_knowledge/base_blade/proc/on_mansus_grasp(mob/living/source, mob/living/target)
	SIGNAL_HANDLER

	// Let's see if source is behind target
	// "Behind" is defined as 3 tiles directly to the back of the target
	// x . .
	// x > .
	// x . .

	var/are_we_behind = FALSE
	// No tactical spinning allowed
	if(target.flags_1 & IS_SPINNING_1)
		are_we_behind = TRUE

	// We'll take "same tile" as "behind" for ease
	if(target.loc == source.loc)
		are_we_behind = TRUE

	// We'll also assume lying down is behind, as mob directions when lying are unclear
	if(target.body_position == LYING_DOWN)
		are_we_behind = TRUE

	// Exceptions aside, let's actually check if they're, yknow, behind
	var/dir_target_to_source = get_dir(target, source)
	if(target.dir & REVERSE_DIR(dir_target_to_source))
		are_we_behind = TRUE

	if(!are_we_behind)
		return

	// We're officially behind them, apply effects
	target.AdjustParalyzed(1.5 SECONDS)
	target.apply_damage(10, BRUTE, wound_bonus = CANT_WOUND)
	target.balloon_alert(source, "backstab!")
	playsound(get_turf(target), 'sound/weapons/guillotine.ogg', 100, TRUE)


/datum/eldritch_knowledge/base_blade/on_eldritch_blade(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!iscarbon(target))
		return
	var/mob/living/carbon/C = target
	var/datum/status_effect/eldritch/E = C.has_status_effect(/datum/status_effect/eldritch/rust) || C.has_status_effect(/datum/status_effect/eldritch/ash) || C.has_status_effect(/datum/status_effect/eldritch/flesh) || C.has_status_effect(/datum/status_effect/eldritch/void)
	if(E)
		// Also refunds 75% of charge!
		var/datum/action/cooldown/spell/touch/mansus_grasp/grasp = locate() in user.actions
		if(grasp)
			grasp.next_use_time = min(round(grasp.next_use_time - grasp.cooldown_time * 0.75, 0), 0)
			grasp.build_all_button_icons()

#define BLADE_DANCE_COOLDOWN (20 SECONDS)

/datum/eldritch_knowledge/blade_dance
	name = "T1 - Dance of the Brand"
	gain_text = "Being attacked while wielding a Heretic Blade in either hand will deliver a riposte \
		towards your attacker. This effect can only trigger once every 20 seconds."
	desc = "Transmute a mask, and a raw liver to create a Mask of Madness. It causes passive stamina damage and hallucinations to everyone around the wearer."
	cost = 1
	route = PATH_BLADE
	tier = TIER_1
	/// Whether the counter-attack is ready or not.
	/// Used instead of cooldowns, so we can give feedback when it's ready again
	var/riposte_ready = TRUE

/datum/eldritch_knowledge/blade_dance/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	RegisterSignal(user, COMSIG_HUMAN_CHECK_SHIELDS, PROC_REF(on_shield_reaction))

/datum/eldritch_knowledge/blade_dance/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	UnregisterSignal(user, COMSIG_HUMAN_CHECK_SHIELDS)

/datum/eldritch_knowledge/blade_dance/proc/on_shield_reaction(mob/living/carbon/human/source, atom/movable/hitby, damage = 0, attack_text = "the attack", attack_type = MELEE_ATTACK, armour_penetration = 0,damage_type = BRUTE)

	SIGNAL_HANDLER

	// if(attack_type != MELEE_ATTACK)
	// 	return

	// if(!riposte_ready)
	// 	return

	// if(source.incapacitated(IGNORE_GRAB))
	// 	return

	var/mob/living/attacker = hitby.loc
	// if(!istype(attacker))
	// 	return

	// if(!source.Adjacent(attacker))
	// 	return

	// // Let's check their held items to see if we can do a riposte
	var/obj/item/main_hand = source.get_active_held_item()
	var/obj/item/off_hand = source.get_inactive_held_item()
	// // This is the item that ends up doing the "blocking" (flavor)
	var/obj/item/striking_with

	// First we'll check if the offhand is valid
	if(!QDELETED(off_hand) && istype(off_hand, /obj/item/melee/sickly_blade))
		striking_with = off_hand

	// Then we'll check the mainhand
	// We do mainhand second, because we want to prioritize it over the offhand
	if(!QDELETED(main_hand) && istype(main_hand, /obj/item/melee/sickly_blade))
		striking_with = main_hand

	// No valid item in either slot? No riposte
	if(!striking_with)
		return
	
	// If we made it here, deliver the strike
	INVOKE_ASYNC(src, PROC_REF(counter_attack), source, attacker, striking_with, attack_text)

	// And reset after a bit
	riposte_ready = FALSE
	addtimer(CALLBACK(src, PROC_REF(reset_riposte), source), BLADE_DANCE_COOLDOWN)

/datum/eldritch_knowledge/blade_dance/proc/counter_attack(mob/living/carbon/human/source, mob/living/target, obj/item/melee/sickly_blade/weapon, attack_text)
	playsound(get_turf(source), 'sound/weapons/parry.ogg', 100, TRUE)
	source.balloon_alert(source, "riposte used")
	source.visible_message(
		span_warning("[source] leans into [attack_text] and delivers a sudden riposte back at [target]!"),
		span_warning("You lean into [attack_text] and deliver a sudden riposte back at [target]!"),
		span_hear("You hear a clink, followed by a stab."),
	)
	message_admins("successful counter before attack")
	weapon.melee_attack_chain(source, target)

/datum/eldritch_knowledge/blade_dance/proc/reset_riposte(mob/living/carbon/human/source)
	riposte_ready = TRUE
	source.balloon_alert(source, "riposte ready")

#undef BLADE_DANCE_COOLDOWN


/datum/eldritch_knowledge/ashen_eyes
	name = "T1 - Eldritch Medallion"
	gain_text = "The City Guard wore these amulets when Amgala was beset by the Sanguine Horde. So too shall you be able to see the blood that flows in others."
	desc = "Allows you to craft an eldritch amulet by transmuting a pair of eyes with a glass shard. When worn, the amulet will give you thermal vision."
	unlocked_transmutations = list(/datum/eldritch_transmutation/ashen_eyes)
	cost = 1
	tier = TIER_1

/datum/eldritch_knowledge/blade_mark
	name = "Grasp Mark - Touch of the Spark"
	gain_text = "All living things are linked through their sparks. This technique represents a fraction of the Shrouded One's communality."
	desc = "Your Mansus grasp now applies a mark on hit. Use your ashen blade to detonate the mark, which causes burning that can spread to nearby targets, decreasing in damage with each jump."
	cost = 2
	banned_knowledge = list(
		/datum/eldritch_knowledge/ash_mark,
		/datum/eldritch_knowledge/rust_mark,
		/datum/eldritch_knowledge/flesh_mark,
		/datum/eldritch_knowledge/mind_mark,
		/datum/eldritch_knowledge/void_mark)
	route = PATH_BLADE
	tier = TIER_MARK

/datum/eldritch_knowledge/blade_mark/on_gain(mob/user)
	. = ..()
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, PROC_REF(on_mansus_grasp))

/datum/eldritch_knowledge/blade_mark/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	UnregisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK)

/datum/eldritch_knowledge/blade_mark/proc/on_mansus_grasp(mob/living/source, mob/living/target)
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
	desc = "Shoot a stong blast of fire at an enemy."
	cost = 1
	spell_to_add = /datum/action/cooldown/spell/pointed/projectile/fireball/eldritch
	route = PATH_BLADE
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

/datum/eldritch_knowledge/blade_blade_upgrade
	name = "Blade Upgrade - Blade of the City Guard"
	gain_text = "The stench of boiling blood was common in the wake of the City Guard. Though they are gone, the memory of their pikes and greatswords may yet benefit you."
	desc = "Your ashen blade will now ignite targets."
	cost = 2
	banned_knowledge = list(
		/datum/eldritch_knowledge/rust_blade_upgrade,
		/datum/eldritch_knowledge/flesh_blade_upgrade,
		/datum/eldritch_knowledge/mind_blade_upgrade,
		/datum/eldritch_knowledge/void_blade_upgrade)
	route = PATH_BLADE
	tier = TIER_BLADE

/datum/eldritch_knowledge/blade_blade_upgrade/on_eldritch_blade(target,user,proximity_flag,click_parameters)
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
	route = PATH_BLADE
	tier = TIER_3

/datum/eldritch_knowledge/spell/cleave
	name = "T3 - Blood Cleave"
	gain_text = "The Shrouded One connects all. This technique, a particular favorite of theirs, rips at the bodies of those who hunch too close to permit casuality."
	desc = "A powerful ranged spell that causes heavy bleeding and blood loss in an area around your target."
	cost = 1
	spell_to_add = /datum/action/cooldown/spell/pointed/cleave
	tier = TIER_3

/datum/eldritch_knowledge/blade_final
	name = "Ascension Rite - Amgala's Ruin"
	gain_text = "Ash feeds the soil, and fire consumes the plants that grow thereafter. On and on and on. The Nightwatcher consumed the sparks of a whole city, yet you will rise with only three: the first step of many to claim his crown."
	desc = "Transmute three corpses to ascend as an Ashbringer. You will become immune to environmental hazards and grow more resistant to damage. You will additionally gain a spell that creates a massive burst of fire and another spell that creates a cloak of flames around you."
	cost = 3
	unlocked_transmutations = list(/datum/eldritch_transmutation/final/ash_final)
	route = PATH_BLADE
	tier = TIER_ASCEND
