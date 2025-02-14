/obj/item/clothing/shoes/magboots/boomboots

	desc = "The ultimate in clown shoe technology. WARNING: EXPLODES ON REMOVAL! VERY FUNNY!"
	name = "boom boots"
	icon = 'monkestation/icons/obj/clothing/shoes.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/feet.dmi'
	icon_state = "boomboot0"
	base_icon_state = "boomboot0"
	inhand_icon_state = "clown_shoes"
	slowdown = SHOES_SLOWDOWN + 1
	actions_types = list(/datum/action/item_action/toggle)
	var/enabled_waddle = TRUE
	var/waddle
	slot_flags = ITEM_SLOT_FEET
	body_parts_covered = FEET
/obj/item/clothing/shoes/magboots/boomboots/Initialize()
	. = ..()
	AddComponent(/datum/component/squeak, list('monkestation/sound/misc/Boomboot1.ogg'=1), 50)
	create_storage(storage_type = /datum/storage/pockets/shoes/clown)
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_CLOWN, CELL_VIRUS_TABLE_GENERIC, rand(2,3), 0)

/obj/item/clothing/shoes/magboots/boomboots/update_icon_state()
	. = ..()
	if(magpulse)
		icon_state = "boomboot1"
	else
		icon_state = "boomboot0"

/obj/item/clothing/shoes/magboots/boomboots/equipped(mob/user, slot)
	. = ..()
	var/mob/living/carbon/human/clown_user = user
	if(slot == ITEM_SLOT_FEET)
		if(enabled_waddle)
			waddle = user.AddElement(/datum/element/waddling)
		if(is_clown_job(user.mind?.assigned_role))
			clown_user.add_mood_event("clownshoes", /datum/mood_event/clownshoes)
			RegisterSignal(src, COMSIG_LIVING_DEATH, PROC_REF(on_mob_death))
		update_icon_state()

/obj/item/clothing/shoes/magboots/boomboots/item_action_slot_check(slot, mob/user)
	if(slot == ITEM_SLOT_FEET)
		return 1

/obj/item/clothing/shoes/magboots/boomboots/dropped(mob/user)
	. = ..()
	QDEL_NULL(waddle)
	var/mob/living/carbon/human/clown_user = user
	if(user.mind && user.mind.assigned_role == "Clown")
		clown_user.clear_mood_event("clownshoes")
	if(magpulse)//make sure they're being worn and activated
		explosion(src,2,4,8,6)//used the size of the big rubber ducky bomb
		UnregisterSignal(src, COMSIG_LIVING_DEATH, PROC_REF(on_mob_death))
	update_icon_state()

/obj/item/clothing/shoes/magboots/boomboots/verb/toggle_boomboots()
	set name = "Toggle Boom Boots"
	set category = "Object"
	set src in usr

	if(!can_use(usr))
		return
	attack_self(usr)

/obj/item/clothing/shoes/magboots/boomboots/attack_self(mob/user)
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		if(src == C.shoes)
			. = .. ()
			if(magpulse)
				update_icon_state()
			else
				update_icon_state()
			to_chat(user, "<span class='notice'>You [magpulse ? "enable" : "disable"] the anti-tamper system.</span>")
			update_appearance()
		else
			to_chat(user, "<span class='userdanger'>You have to wear the boots to activate them!</span>")
	user.update_equipment_speed_mods()

/obj/item/clothing/shoes/magboots/boomboots/proc/on_mob_death(mob/living/carbon/human/source)
	SIGNAL_HANDLER
	UnregisterSignal(src, COMSIG_LIVING_DEATH, PROC_REF(on_mob_death))
	if(iscarbon(source))
		if(source.shoes == src)
			if(magpulse)
				explosion(src,2,4,8,6)//used the size of the big rubber ducky bomb

