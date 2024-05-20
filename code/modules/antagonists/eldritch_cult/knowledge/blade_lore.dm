/datum/eldritch_knowledge/base_blade
	name = "The Cutting Edge"
	desc = "Pledges yourself to the path of Blade. Allows you to transmute a bar of silver with a knife or its derivatives into a Sundered Blade. Additionally, empowers your Mansus grasp to deal brute damage and paralyze enemies hit."
	gain_text = "Our great ancestors forged swords and practiced sparring on the eve of great battles."
	unlocked_transmutations = list(/datum/eldritch_transmutation/dark_knife)
	cost = 1
	route = PATH_BLADE
	tier = TIER_PATH

// "Floating ghost blade" effect for blade heretics
/obj/effect/floating_blade
	name = "knife"
	icon = 'icons/obj/kitchen.dmi';
	icon_state = "knife"
	layer = LOW_MOB_LAYER
	/// The color the knife glows around it.
	var/glow_color = "#ececff"

/obj/effect/floating_blade/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/movetype_handler)
	ADD_TRAIT(src, TRAIT_MOVE_FLYING, INNATE_TRAIT)
	add_filter("knife", 2, list("type" = "outline", "color" = glow_color, "size" = 1))

/datum/eldritch_knowledge/base_blade/on_gain(mob/user)
	. = ..()
	var/obj/realknife = new /obj/item/melee/sickly_blade/dark
	user.put_in_hands(realknife)

	///use is if you want to swap out a spell they get upon becoming their certain type of heretic
	var/datum/action/cooldown/spell/basic_jaunt = locate(/datum/action/cooldown/spell/jaunt/ethereal_jaunt/basic) in user.actions
	if(basic_jaunt)
		basic_jaunt.Remove(user)
	var/datum/action/cooldown/spell/jaunt/ethereal_jaunt/blade/blade_jaunt = new(user)
	blade_jaunt.Grant(user)

	ADD_TRAIT(user, TRAIT_SILENT_FOOTSTEPS, INNATE_TRAIT)
	RegisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, PROC_REF(on_mansus_grasp))

/datum/eldritch_knowledge/base_blade/on_lose(mob/user)
	UnregisterSignal(user, COMSIG_HERETIC_MANSUS_GRASP_ATTACK)

/datum/eldritch_knowledge/base_blade/proc/on_mansus_grasp(mob/living/source, mob/living/target)
	SIGNAL_HANDLER

	if(!isliving(target))
		return COMPONENT_BLOCK_HAND_USE
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
		return COMPONENT_BLOCK_HAND_USE

	// We're officially behind them, apply effects
	target.AdjustParalyzed(1.5 SECONDS)
	target.apply_damage(10, BRUTE, wound_bonus = CANT_WOUND)
	target.balloon_alert(source, "backstab!")
	playsound(get_turf(target), 'sound/weapons/guillotine.ogg', 100, TRUE)

/datum/eldritch_knowledge/base_blade/on_eldritch_blade(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!iscarbon(target))
		return COMPONENT_BLOCK_HAND_USE
	var/mob/living/carbon/C = target
	var/datum/status_effect/eldritch/E = C.has_status_effect(/datum/status_effect/eldritch/rust) || C.has_status_effect(/datum/status_effect/eldritch/ash) || C.has_status_effect(/datum/status_effect/eldritch/flesh) || C.has_status_effect(/datum/status_effect/eldritch/void) || C.has_status_effect(/datum/status_effect/eldritch/cosmic)
	if(E)
		// Also refunds 75% of charge!
		var/datum/action/cooldown/spell/touch/mansus_grasp/grasp = locate() in user.actions
		if(grasp)
			grasp.next_use_time = min(round(grasp.next_use_time - grasp.cooldown_time * 0.75, 0), 0)
			grasp.build_all_button_icons()

#define BLADE_DANCE_COOLDOWN (20 SECONDS)

/datum/eldritch_knowledge/blade_dance
	name = "T1 - Dance of the Brand"
	gain_text = "Having the prowess to wield such a thing requires great dedication and terror."
	desc = "Being attacked while wielding a Heretic Blade in either hand will deliver a riposte \
		towards your attacker. This effect can only trigger once every 20 seconds."
	cost = 1
	route = PATH_BLADE
	tier = TIER_1
	/// Whether the counter-attack is ready or not.
	/// Used instead of cooldowns, so we can give feedback when it's ready again
	var/riposte_ready = TRUE

/datum/eldritch_knowledge/blade_dance/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
	RegisterSignal(user, COMSIG_HUMAN_CHECK_SHIELDS, PROC_REF(on_shield_reaction))

/datum/eldritch_knowledge/blade_dance/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
	UnregisterSignal(user, COMSIG_HUMAN_CHECK_SHIELDS)

/datum/eldritch_knowledge/blade_dance/proc/on_shield_reaction(mob/living/carbon/human/source, atom/movable/hitby, damage = 0, attack_text = "the attack", attack_type = MELEE_ATTACK, armour_penetration = 0,damage_type = BRUTE)

	SIGNAL_HANDLER

	if(attack_type != MELEE_ATTACK)
		return

	if(!riposte_ready)
		return

	var/mob/living/attacker = hitby.loc

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
	weapon.melee_attack_chain(source, target)

/datum/eldritch_knowledge/blade_dance/proc/reset_riposte(mob/living/carbon/human/source)
	riposte_ready = TRUE
	source.balloon_alert(source, "riposte ready")

#undef BLADE_DANCE_COOLDOWN

/datum/eldritch_knowledge/blade_mark
	name = "Grasp Mark - Mark of the Blade"
	gain_text = "There was no room for cowardace here. Those who ran were scolded. \
		That is how I met them. Their name was The Colonel."
	desc = "Allows you to craft Eldrtich Whetstones, one time use items that can enhance the sharpness of your blades up to a certain degree."
	cost = 2
	unlocked_transmutations = list(/datum/eldritch_transmutation/eldritch_whetstone)
	route = PATH_BLADE
	tier = TIER_MARK

/datum/eldritch_knowledge/blade_mark/on_gain(mob/user)
	. = ..()
	var/obj/eldwhetstone = new /obj/item/sharpener/eldritch
	user.put_in_hands(eldwhetstone)

/datum/eldritch_knowledge/duel_stance
	name = "T2 - Stance of the Torn Champion"
	desc = "Grants immunity to having your limbs dismembered. \
		Additionally, when damaged below 50% of your maximum health, \
		you gain increased resistance to gaining wounds and reduced damage slowdown."
	gain_text = "In time, it was he who stood alone among the bodies of his former comrades, awash in blood, none of it his own. \
		He was without rival, equal, or purpose."
	cost = 1
	route = PATH_BLADE
	/// Whether we're currently in duelist stance, gaining certain buffs (low health)
	var/in_duelist_stance = FALSE
	route = PATH_BLADE
	tier = TIER_2

/datum/eldritch_knowledge/spell/realignment
	name = "T2 - Realignment"
	desc = "Grants you Realignment a spell that wil realign your body rapidly for a short period. \
		During this process, you will rapidly regenerate stamina and quickly recover from stuns, however, you will be unable to attack. \
		This spell can be cast in rapid succession, but doing so will increase the cooldown."
	gain_text = "In the flurry of death, he found peace within himself. Despite insurmountable odds, he forged on."
	cost = 1
	spell_to_add = /datum/action/cooldown/spell/realignment
	route = PATH_BLADE
	tier = TIER_2

/datum/eldritch_knowledge/duel_stance/on_gain(mob/user, datum/antagonist/heretic/our_heretic)
	. = ..()
	ADD_TRAIT(user, TRAIT_NODISMEMBER, type)
	RegisterSignal(user, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(user, COMSIG_LIVING_HEALTH_UPDATE, PROC_REF(on_health_update))

	on_health_update(user) // Run this once, so if the knowledge is learned while hurt it activates properly

/datum/eldritch_knowledge/duel_stance/on_lose(mob/user, datum/antagonist/heretic/our_heretic)
	REMOVE_TRAIT(user, TRAIT_NODISMEMBER, type)
	if(in_duelist_stance)
		user.remove_traits(list(TRAIT_HARDLY_WOUNDED, TRAIT_REDUCED_DAMAGE_SLOWDOWN), type)

	UnregisterSignal(user, list(COMSIG_ATOM_EXAMINE, COMSIG_CARBON_GAIN_WOUND, COMSIG_LIVING_HEALTH_UPDATE))

/datum/eldritch_knowledge/duel_stance/proc/on_examine(mob/living/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	var/obj/item/held_item = source.get_active_held_item()
	if(in_duelist_stance)
		examine_list += span_warning("[source] looks unnaturally poised[held_item?.force >= 15 ? " and ready to strike out":""].")

/datum/eldritch_knowledge/duel_stance/proc/on_health_update(mob/living/source)
	SIGNAL_HANDLER

	if(in_duelist_stance && source.health > source.maxHealth * 0.5)
		source.balloon_alert(source, "exited duelist stance")
		in_duelist_stance = FALSE
		source.remove_traits(list(TRAIT_HARDLY_WOUNDED, TRAIT_REDUCED_DAMAGE_SLOWDOWN), type)
		return

	if(!in_duelist_stance && source.health <= source.maxHealth * 0.5)
		source.balloon_alert(source, "entered duelist stance")
		in_duelist_stance = TRUE
		source.add_traits(list(TRAIT_HARDLY_WOUNDED, TRAIT_REDUCED_DAMAGE_SLOWDOWN), type)
		return

/datum/eldritch_knowledge/blade_blade_upgrade
	name = "Blade Upgrade - Swift Blades"
	desc = "Allows you to craft a bone blade from a knife and a bar of gold. \
		Additionally will allow you to attack with both a sundered blade, and bone blade at once."
	gain_text = "I found him cleaved in twain, halves locked in a duel without end; \
		a flurry of blades, neither hitting their mark, for the Champion was indomitable."
	cost = 2
	unlocked_transmutations = list(/datum/eldritch_transmutation/bone_knife)
	route = PATH_BLADE
	tier = TIER_BLADE

/datum/eldritch_knowledge/blade_blade_upgrade/on_gain(mob/user)
	. = ..()
	var/obj/offhandknife = new /obj/item/melee/sickly_blade/bone
	user.put_in_hands(offhandknife)

/datum/eldritch_knowledge/spell/furious_steel
	name = "T3 - Furious Steel"
	desc = "Grants you Furious Steel, a targeted spell. Using it will summon three \
		orbiting blades around you. These blades will protect you from all attacks, \
		but are consumed on use. Additionally, you can click to fire the blades \
		at a target, dealing damage and causing bleeding."
	gain_text = "Without thinking, I took the knife of a fallen soldier and threw with all my might. My aim was true! \
		The Torn Champion smiled at their first taste of agony, and with a nod, their blades became my own."
	cost = 1
	spell_to_add = /datum/action/cooldown/spell/pointed/projectile/furious_steel
	route = PATH_BLADE
	tier = TIER_3

/datum/eldritch_knowledge/blade_final
	name = "Ascension Rite - Maelstrom of Silver"
	gain_text = "A mountain of blades stand before you, your masterpiece in hand, you raise it high and cleave reality in twine."
	desc = "Transmute three corpses to ascend as a Master of blades. You will become immune to stuns, resistant to wounds, and reduced overall damage. Additionally your spell 'furious steel' will have reduced cooldown, and you will create a shield of blades overtime."
	cost = 3
	unlocked_transmutations = list(/datum/eldritch_transmutation/final/blade_final)
	route = PATH_BLADE
	tier = TIER_ASCEND
