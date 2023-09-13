/datum/eldritch_knowledge/base_mind
	name = "Precipice Of Enlightenment"
	desc = "Pledge yourself to knowledge everlasting. Allows you to transmute a knife and a book into a blade of pure thought. Additionally, Your mansus grasp now functions at a range, marking targets and causing them to hallucinate."
	gain_text = "A student of the Grand Library, one day you awoke with a hunger, a thirst. No amount of food nor drink could quench either, so you turned towards the only thing left, the books on the shelves. One new tome caught your hungry eye, it's single word title changing your world forever. Vermis."
	banned_knowledge = list(/datum/eldritch_knowledge/base_ash,/datum/eldritch_knowledge/base_rust,/datum/eldritch_knowledge/base_flesh,/datum/eldritch_knowledge/ash_mark,/datum/eldritch_knowledge/rust_mark,/datum/eldritch_knowledge/flesh_mark,/datum/eldritch_knowledge/ash_blade_upgrade,/datum/eldritch_knowledge/rust_blade_upgrade,/datum/eldritch_knowledge/flesh_blade_upgrade,/datum/eldritch_knowledge/ash_final,/datum/eldritch_knowledge/rust_final,/datum/eldritch_knowledge/flesh_final)
	unlocked_transmutations = list(/datum/eldritch_transmutation/mind_knife)
	cost = 1
	route = PATH_MIND
	tier = TIER_PATH

/datum/eldritch_knowledge/base_mind/on_gain(mob/user)
	. = ..()
	var/obj/realknife = new /obj/item/gun/magic/hook/sickly_blade/mind
	user.put_in_hands(realknife)
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, PROC_REF(on_mansus_grasp))

/datum/eldritch_knowledge/base_mind/on_lose(mob/user)
	UnregisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK)

/datum/eldritch_knowledge/base_mind/proc/on_mansus_grasp(mob/living/source, mob/living/target)
//	SIGNAL_HANDLER

	if(!iscarbon(target))
		return
	if(!iscarbon(target))
		return
	var/mob/living/carbon/C = target
	var/atom/throw_target = get_edge_target_turf(C, source.dir)
	if(!C.anchored)
		C.throw_at(throw_target, rand(4,8), 14, source)

/datum/eldritch_knowledge/base_mind/on_eldritch_blade(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!iscarbon(target))
		return
	var/mob/living/carbon/C = target
	var/datum/status_effect/eldritch/E = C.has_status_effect(/datum/status_effect/eldritch/rust) || C.has_status_effect(/datum/status_effect/eldritch/ash) || C.has_status_effect(/datum/status_effect/eldritch/flesh)
	if(E)
		// Also refunds 75% of charge!
		var/datum/action/cooldown/spell/touch/mansus_grasp/grasp = locate() in user.actions
		if(grasp)
			grasp.next_use_time = min(round(grasp.next_use_time - grasp.cooldown_time * 0.75, 0), 0)
			grasp.build_all_button_icons()
			
/datum/eldritch_knowledge/spell/mental_obfuscation
	name = "Mental Obfuscation"
	gain_text = "Lore"
	desc = "Send out 3 false copies of yourself in random directions, alt clicking allows you to swap places with them."
	cost = 1
	spell_to_add = /datum/action/cooldown/spell/jaunt/ethereal_jaunt/ash 
	route = PATH_MIND
	tier = TIER_1

/datum/eldritch_knowledge/eldritch_lantern 
	name = "Eldritch Lantern"
	gain_text = "Lore"
	desc = "Allows you to craft an eldritch lantern by transmuting a flash light and a metal grille. Grants the user a hud type of their choosing."
	unlocked_transmutations = list(/datum/eldritch_transmutation/eldritch_lantern)
	cost = 1
	tier = TIER_1

/datum/eldritch_knowledge/mind_mark 
	name = "Occipital Oblivion"
	gain_text = "Lore"
	desc = "Your mansus grasp now applies a mark on hit, and in a 3x3 aoe around the target causing those caught in the AOE to hallucinate all living mobs as robed heretics with knives, additionally they are temporarily slowed."
	cost = 2
	banned_knowledge = list(/datum/eldritch_knowledge/rust_mark,/datum/eldritch_knowledge/flesh_mark,/datum/eldritch_knowledge/ash_mark)
	route = PATH_MIND
	tier = TIER_MARK

/datum/eldritch_knowledge/assault
	name = "Amygdalla Assault"
	gain_text = "Lore"
	desc = "Blast a single ray of concentrated mental energy at a target, causing the target to lose control of their mental faculties temporarily and make the dizzy for several seconds."
	cost = 1
	unlocked_transmutations = list(/datum/eldritch_transmutation/curse/blindness) 
	route = PATH_MIND
	tier = TIER_2

/datum/eldritch_knowledge/famished_roar
	name = "Famished Roar"
	gain_text = "Lore"
	desc = "An AOE roar spell that sends all near by people flying after a short channel."
	cost = 1
	unlocked_transmutations = list(/datum/eldritch_transmutation/curse/corrosion)
	tier = TIER_2

/datum/eldritch_knowledge/mind_blade_upgrade
	name = "Spine of The Infinite Beast"
	gain_text = "Lore"
	desc = "Your mind blade will now grant you stacking temporary damage resistance, stacking up to a certain amount when hitting targets."
	cost = 2
	banned_knowledge = list(/datum/eldritch_knowledge/rust_blade_upgrade,/datum/eldritch_knowledge/flesh_blade_upgrade,/datum/eldritch_knowledge/ash_blade_upgrade)
	route = PATH_MIND
	tier = TIER_BLADE

/datum/eldritch_knowledge/mind_blade_upgrade/on_eldritch_blade(target,user,proximity_flag,click_parameters)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		C.adjust_fire_stacks(2)
		C.ignite_mob()

/datum/eldritch_knowledge/spell/cerebral_control
	name = "Full Cerebral Control"
	gain_text = "Lore"
	desc = "Temporarily enhance your brain, allowing you to process information at highs speeds, causing all actions taken to increase at the cost of brute damage per second."
	cost = 1
	spell_to_add = /datum/action/cooldown/spell/aoe/fiery_rebirth
	route = PATH_MIND
	tier = TIER_3

/datum/eldritch_knowledge/eldritch_blast
	name = "Eldritch Blast"
	gain_text = "Lore"
	desc = "A strong single target spell, shoot a target with pure force, sending them flying a far distance."
	cost = 1
	unlocked_transmutations = list(/datum/eldritch_transmutation/curse/paralysis)
	tier = TIER_3

/datum/eldritch_knowledge/mind_final
	name = "Beyond All Knowldege Lies Despair"
	gain_text = "Lore"
	desc = "Transmute three corpses to ascend as a Monarch of Knowledge. Your form twists and shapes into a new being, instantly gaining 6 points of knowledge to use, as well as granting you access to your new bodies full potential, becoming resistant to all damage types. Additionally, you generate an AOE of raw mental damage, causing high levels of traumas and brain damage to anyone who walks near you."
	cost = 3
	unlocked_transmutations = list(/datum/eldritch_transmutation/final/mind_final)
	route = PATH_MIND
	tier = TIER_ASCEND
