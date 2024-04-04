#define SUPER_CREDIT_REROLL_COST 1
GLOBAL_VAR_INIT(anvil_cooldown, 1 SECONDS)

/obj/machinery/anvil
	name = "Enchantment Anvil"
	desc = "Used to enchant your weapons and armor to Win The Game!"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	icon = 'icons/obj/lavaland/anvil.dmi'
	icon_state = "fool"
	density = TRUE
	var/list/concurrent_users = list()

/obj/machinery/anvil/Destroy()
	QDEL_LIST_ASSOC_VAL(concurrent_users)
	return ..()

/obj/machinery/anvil/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	use_anvil_ui(user)

/obj/machinery/anvil/attackby(obj/item/reforge_target, mob/user, params)
	if(!reforge_target.GetComponent(/datum/component/fantasy))
		to_chat(user, span_danger("You can't enchant this item."))
		return
	
	use_anvil_ui(user, reforge_target)

/obj/machinery/anvil/proc/use_anvil_ui(mob/user, obj/item/reforge_target)

	if(!concurrent_users[user.ckey])
		concurrent_users[user.ckey] = new /datum/reforge_menu(user, src)

	var/datum/reforge_menu/player_menu = concurrent_users[user.ckey]
	if(reforge_target)
		player_menu.set_target_item(reforge_target)
	
	player_menu.ui_interact(user)

/obj/machinery/anvil/proc/reroll(obj/item/reforge_target, mob/user, datum/reforge_menu/player_menu)
	if(player_menu.use_super_credits)
		if(user.mind.super_credits < SUPER_CREDIT_REROLL_COST)
			to_chat(user, "You don't have any Super Credit(TM) to use!")
			player_menu.use_super_credits = FALSE
			return
		to_chat(user, "You spend a Super Credit(TM) to boost your reroll chances!")
		user.mind.super_credits -= SUPER_CREDIT_REROLL_COST
	var/old_name = reforge_target.name
	var/datum/component/fantasy/F = reforge_target.GetComponent(/datum/component/fantasy)
	reforge_target.AddComponent(/datum/component/fantasy, 0, null, null, FALSE, FALSE) //this is bad code
	var/new_rarity = F.rarity
	playsound(get_turf(src), "sound/effects/anvil/tinker.ogg", 40)
	to_chat(user, "You reroll your [old_name] to a [reforge_target.name]!")
	set_light(l_range = 3, l_power = 3, l_color = GLOB.rarity_to_color[new_rarity])
	addtimer(CALLBACK(src, PROC_REF(reset_light)), GLOB.anvil_cooldown, TIMER_UNIQUE|TIMER_OVERRIDE)
	if(new_rarity == TIER_LEGENDARY || new_rarity == TIER_MYTHICAL)
		for(var/mob/M in SSmobs.clients_by_zlevel[z])
			to_chat(M, span_alert("[user] has rolled [reforge_target]!"))
			if(M.client.prefs.toggles & SOUND_AMBIENCE)
				playsound(get_turf(src), "sound/effects/anvil/congrats.ogg", 60, extrarange = 100) //EVERYONE
				playsound(get_turf(src), "sound/effects/anvil/fireworks.ogg", 60, extrarange = 100)
	COOLDOWN_START(player_menu, reroll_cooldown, GLOB.anvil_cooldown)


/obj/machinery/anvil/proc/reset_light()
	set_light(l_range = 0, l_power = 0, l_color = null)
