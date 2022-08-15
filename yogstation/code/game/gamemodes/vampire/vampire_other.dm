/*
	In this file:
		various vampire interactions and items
*/


/obj/item/clothing/suit/draculacoat
	name = "Vampire Coat"
	desc = "What is a man? A miserable little pile of secrets."
	mob_overlay_icon = 'yogstation/icons/mob/clothing/suit/suit.dmi'
	icon = 'yogstation/icons/obj/clothing/suits.dmi'
	icon_state = "draculacoat"
	item_state = "draculacoat"
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	armor = list(MELEE = 30, BULLET = 20, LASER = 10, ENERGY = 10, BOMB = 0, BIO = 0, RAD = 0)
	allowed = null
	var/blood_restoration_delay = 200
	var/next_blood_restoration_tick = 0

/obj/item/clothing/suit/draculacoat/Initialize()
	if(!allowed)
		allowed = GLOB.security_vest_allowed
	START_PROCESSING(SSobj, src)
	return ..()

/obj/item/clothing/suit/draculacoat/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/clothing/suit/draculacoat/process()
	var/mob/living/carbon/human/user = src.loc
	if(user && ishuman(user) && is_vampire(user) && (user.wear_suit == src))
		if (world.time > next_blood_restoration_tick)
			next_blood_restoration_tick = world.time + blood_restoration_delay
			var/datum/antagonist/vampire/vampire = user.mind.has_antag_datum(/datum/antagonist/vampire)
			if (vampire.total_blood >= 5 && vampire.usable_blood <= vampire.total_blood * 0.25)
				vampire.usable_blood = min(vampire.usable_blood + 5, vampire.total_blood * 0.25) // 5 units every 20 seconds

/mob/living/carbon/human/handle_fire()
	. = ..()
	if(mind)
		var/datum/antagonist/vampire/L = mind.has_antag_datum(/datum/antagonist/vampire)
		if(on_fire && stat == DEAD && L && !L.get_ability(/datum/vampire_passive/full))
			dust()

/obj/item/storage/book/bible/attack(mob/living/M, mob/living/carbon/human/user, heal_mode = TRUE)
	. = ..()
	if(!(user.mind && user.mind.holy_role) && is_vampire(user))
		to_chat(user, span_danger("[deity_name] channels through \the [src] and sets you ablaze for your blasphemy!"))
		user.fire_stacks += 5
		user.IgniteMob()
		user.emote("scream", 1)
