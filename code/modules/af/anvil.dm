GLOBAL_VAR_INIT(anvil_cooldown, 1 SECONDS)

/obj/machinery/anvil
	name = "Enchantment Anvil"
	desc = "Used to enchant your weapons and armor to Win The Game!"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	icon = 'icons/obj/lavaland/anvil.dmi'
	icon_state = "fool"
	density = TRUE
	COOLDOWN_DECLARE(reroll_cooldown)

/obj/machinery/anvil/attackby(obj/item/O, mob/user, params)
	if(!O.GetComponent(/datum/component/fantasy))
		to_chat(user, span_danger("You can't enchant this item."))
		return
	if(!COOLDOWN_FINISHED(src, reroll_cooldown))
		to_chat(user, span_danger("You can't reroll that quickly!"))
		return
	reroll(O, user)

/obj/machinery/anvil/proc/reroll(obj/item/O, mob/user)
	var/old_name = O.name
	var/datum/component/fantasy/F = O.GetComponent(/datum/component/fantasy)
	O.AddComponent(/datum/component/fantasy, 0, null, null, FALSE, FALSE) //this is bad code
	var/new_rarity = F.rarity
	playsound(get_turf(src), "sound/effects/anvil/tinker.ogg", 40)
	to_chat(user, "You reroll your [old_name] to a [O.name]!")
	set_light(l_range = 3, l_power = 3, l_color = GLOB.rarity_to_color[new_rarity])
	addtimer(CALLBACK(src, PROC_REF(reset_light)), GLOB.anvil_cooldown, TIMER_UNIQUE|TIMER_OVERRIDE)
	if(new_rarity == TIER_LEGENDARY || new_rarity == TIER_MYTHICAL)
		for(var/mob/M in SSmobs.clients_by_zlevel[z])
			to_chat(M, span_alert("[user] has rolled [O]!"))
			if(M.client.prefs.toggles & SOUND_AMBIENCE)
				playsound(get_turf(src), "sound/effects/anvil/congrats.ogg", 60, extrarange = 100) //EVERYONE
				playsound(get_turf(src), "sound/effects/anvil/fireworks.ogg", 60, extrarange = 100)
	COOLDOWN_START(src, reroll_cooldown, GLOB.anvil_cooldown)

/obj/machinery/anvil/proc/reset_light()
	set_light(l_range = 0, l_power = 0, l_color = null)
