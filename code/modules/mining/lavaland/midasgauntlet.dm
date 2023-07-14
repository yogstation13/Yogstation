/obj/item/midasgaunt
	name ="enchanted flowers"
	desc ="A charming bunch of flowers, most animals seem to find the bearer amicable after momentary contact with it. Squeeze the bouquet to summon tamed creatures. Megafauna cannot be summoned. <b>Megafauna need to be exposed 35 times to become friendly.</b>"
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "eflower"
	var/next_summon = 0
	var/list/summons = list()
	attack_verb = list("thumped", "brushed", "bumped")

/obj/item/midasgaunt/attack_self(mob/user)
	var/turf/T = get_turf(user)
	var/area/A = get_area(user)
	if(next_summon > world.time)
		to_chat(user, span_warning("You can't do that yet!"))
		return
	if(is_station_level(T.z) && !A.outdoors)
		to_chat(user, span_warning("You feel like calling a bunch of animals indoors is a bad idea."))
		return
	user.visible_message(span_warning("[user] holds the bouquet out, summoning their allies!"))
	for(var/mob/m in summons)
		m.forceMove(T)
	playsound(T, 'sound/effects/splat.ogg', 80, 5, -1)
	next_summon = world.time + COOLDOWN_SUMMON

/obj/item/midasgaunt/afterattack(mob/living/simple_animal/M, mob/user, proximity)
	var/datum/status_effect/taming/G = M.has_status_effect(STATUS_EFFECT_TAMING)
	. = ..()
	if(!proximity)
		return
	if(M.client)
		to_chat(user, span_warning("[M] is too intelligent to tame!"))
		return
	if(M.stat)
		to_chat(user, span_warning("[M] is dead!"))
		return
	if(M.faction == user.faction)
		to_chat(user, span_warning("[M] is already on your side!"))
		return
	if(!M.magic_tameable)
		to_chat(user, span_warning("[M] cannot be tamed!"))
		return
	if(M.sentience_type == SENTIENCE_BOSS)
		if(!G)
			M.apply_status_effect(STATUS_EFFECT_TAMING, user)
		else
			G.add_tame(G.tame_buildup)
			if(ISMULTIPLE(G.tame_crit-G.tame_amount, 5))
				to_chat(user, span_notice("[M] has to be exposed [G.tame_crit-G.tame_amount] more times to accept your gift!"))
		return
	if(M.sentience_type != SENTIENCE_ORGANIC)
		to_chat(user, span_warning("[M] cannot be tamed!"))
		return
	if(!do_after(user, 1.5 SECONDS, M))
		return
	M.visible_message(span_notice("[M] seems happy with you after exposure to the bouquet!"))
	M.add_atom_colour("#11c42f", FIXED_COLOUR_PRIORITY)
	M.drop_loot()
	M.faction = user.faction
	summons |= M
