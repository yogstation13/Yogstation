/obj/item/storage/lockbox
	name = "lockbox"
	desc = "A locked box."
	icon_state = "lockbox+l"
	item_state = "syringe_kit"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	req_access = list(ACCESS_ARMORY)
	var/broken = FALSE
	var/open = FALSE
	var/icon_locked = "lockbox+l"
	var/icon_closed = "lockbox"
	var/icon_broken = "lockbox+b"

/obj/item/storage/lockbox/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_w_class = WEIGHT_CLASS_NORMAL
	STR.max_combined_w_class = 14
	STR.max_items = 4
	STR.locked = TRUE

/obj/item/storage/lockbox/attackby(obj/item/W, mob/user, params)
	var/locked = SEND_SIGNAL(src, COMSIG_IS_STORAGE_LOCKED)
	if(W.GetID())
		togglelock(user)
	if(!locked)
		return ..()
	else
		to_chat(user, span_danger("It's locked!"))

/obj/item/storage/lockbox/proc/togglelock(mob/living/user, silent)
	var/locked = SEND_SIGNAL(src, COMSIG_IS_STORAGE_LOCKED)
	if(broken)
		to_chat(user, span_danger("It appears to be broken."))
		return
	if(allowed(user))
		SEND_SIGNAL(src, COMSIG_TRY_STORAGE_SET_LOCKSTATE, !locked)
		locked = SEND_SIGNAL(src, COMSIG_IS_STORAGE_LOCKED)
		if(locked)
			icon_state = icon_locked
			to_chat(user, span_danger("You lock the [src.name]!"))
			SEND_SIGNAL(src, COMSIG_TRY_STORAGE_HIDE_ALL)
		else
			icon_state = icon_closed
			to_chat(user, span_danger("You unlock the [src.name]!"))
			return
	else
		to_chat(user, span_danger("Access Denied."))
		return

/obj/item/storage/lockbox/emag_act(mob/user)
	if(!broken)
		broken = TRUE
		SEND_SIGNAL(src, COMSIG_TRY_STORAGE_SET_LOCKSTATE, FALSE)
		desc += "It appears to be broken."
		icon_state = src.icon_broken
		if(user)
			visible_message(span_warning("\The [src] has been broken by [user] with an electromagnetic card!"))
			return

/obj/item/storage/lockbox/Entered()
	. = ..()
	open = TRUE
	update_icon()

/obj/item/storage/lockbox/Exited()
	. = ..()
	open = TRUE
	update_icon()

/obj/item/storage/lockbox/AltClick(mob/user)
	..()
	if(!user.canUseTopic(src, BE_CLOSE))
		return
	togglelock(user)

/obj/item/storage/lockbox/emp_act(severity)
	switch(severity)
		if(EMP_HEAVY)
			emag_act()
		if(EMP_LIGHT)
			if(prob(60))
				var/locked = SEND_SIGNAL(src, COMSIG_IS_STORAGE_LOCKED)
				SEND_SIGNAL(src, COMSIG_TRY_STORAGE_SET_LOCKSTATE, !locked)
				locked = SEND_SIGNAL(src, COMSIG_IS_STORAGE_LOCKED)
				if(locked)
					icon_state = icon_locked
					SEND_SIGNAL(src, COMSIG_TRY_STORAGE_HIDE_ALL)
				else
					icon_state = icon_closed

/obj/item/storage/lockbox/loyalty
	name = "lockbox of mindshield implants"
	req_access = list(ACCESS_SECURITY)

/obj/item/storage/lockbox/loyalty/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/implantcase/mindshield(src)
	new /obj/item/implanter/mindshield(src)

/obj/item/storage/lockbox/clusterbang
	name = "lockbox of clusterbangs"
	desc = "You have a bad feeling about opening this."
	req_access = list(ACCESS_SECURITY)

/obj/item/storage/lockbox/clusterbang/PopulateContents()
	new /obj/item/grenade/clusterbuster(src)

/obj/item/storage/lockbox/medal
	name = "medal box"
	desc = "A locked box used to store medals of honor."
	icon_state = "medalbox+l"
	item_state = "syringe_kit"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	req_access = list(ACCESS_CAPTAIN)
	icon_locked = "medalbox+l"
	icon_closed = "medalbox"
	icon_broken = "medalbox+b"

/obj/item/storage/lockbox/medal/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_w_class = WEIGHT_CLASS_SMALL
	STR.max_items = 15
	STR.max_combined_w_class = 20
	STR.set_holdable(list(/obj/item/clothing/accessory/medal))

/obj/item/storage/lockbox/medal/examine(mob/user)
	. = ..()
	if(!SEND_SIGNAL(src, COMSIG_IS_STORAGE_LOCKED))
		. += span_notice("Alt-click to [open ? "close":"open"] it.")

/obj/item/storage/lockbox/medal/AltClick(mob/user)
	if(user.canUseTopic(src, BE_CLOSE))
		if(!SEND_SIGNAL(src, COMSIG_IS_STORAGE_LOCKED))
			open = (open ? FALSE : TRUE)
			update_icon()
		..()

/obj/item/storage/lockbox/medal/PopulateContents()
	new /obj/item/clothing/accessory/medal/gold/captain(src)
	new /obj/item/clothing/accessory/medal/silver/valor(src)
	new /obj/item/clothing/accessory/medal/silver/valor(src)
	new /obj/item/clothing/accessory/medal/silver/security(src)
	new /obj/item/clothing/accessory/medal/silver/medical(src)
	new /obj/item/clothing/accessory/medal/silver/engineering(src)
	new /obj/item/clothing/accessory/medal/bronze_heart(src)
	new /obj/item/clothing/accessory/medal/plasma/nobel_science(src)
	new /obj/item/clothing/accessory/medal/plasma/nobel_science(src)
	for(var/i in 1 to 3)
		new /obj/item/clothing/accessory/medal/conduct(src)

/obj/item/storage/lockbox/medal/update_icon()
	cut_overlays()
	var/locked = SEND_SIGNAL(src, COMSIG_IS_STORAGE_LOCKED)
	if(locked)
		icon_state = "medalbox+l"
		open = FALSE
	else
		icon_state = "medalbox"
		if(open)
			icon_state += "open"
		if(broken)
			icon_state += "+b"
		if(contents && open)
			for (var/i in 1 to contents.len)
				var/obj/item/clothing/accessory/medal/M = contents[i]
				var/mutable_appearance/medalicon = mutable_appearance(initial(icon), M.medaltype)
				if(i > 1 && i <= 5)
					medalicon.pixel_x += ((i-1)*3)
				else if(i > 5)
					medalicon.pixel_y -= 7
					medalicon.pixel_x -= 2
					medalicon.pixel_x += ((i-6)*3)
				add_overlay(medalicon)

/obj/item/storage/lockbox/medal/sec
	name = "security medal box"
	desc = "A locked box used to store medals to be given to members of the security department."
	req_access = list(ACCESS_HOS)

/obj/item/storage/lockbox/medal/sec/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/clothing/accessory/medal/silver/security(src)

/obj/item/storage/lockbox/medal/cargo
	name = "cargo award box"
	desc = "A locked box used to store awards to be given to members of the cargo department."
	req_access = list(ACCESS_QM)

/obj/item/storage/lockbox/medal/cargo/PopulateContents()
		new /obj/item/clothing/accessory/medal/ribbon/cargo(src)

/obj/item/storage/lockbox/medal/service
	name = "service award box"
	desc = "A locked box used to store awards to be given to members of the service department."
	req_access = list(ACCESS_HOP)

/obj/item/storage/lockbox/medal/service/PopulateContents()
		new /obj/item/clothing/accessory/medal/silver/excellence(src)

/obj/item/storage/lockbox/medal/sci
	name = "science medal box"
	desc = "A locked box used to store medals to be given to members of the science department."
	req_access = list(ACCESS_RD)

/obj/item/storage/lockbox/medal/sci/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/clothing/accessory/medal/plasma/nobel_science(src)

/obj/item/storage/lockbox/medal/med
	name = "medical medal box"
	desc = "A locked box used to store medals to be given to members of the medical department."
	req_access = list(ACCESS_CMO)

/obj/item/storage/lockbox/medal/med/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/clothing/accessory/medal/silver/medical(src)

/obj/item/storage/lockbox/medal/eng
	name = "engineering medal box"
	desc = "A locked box used to store medals to be given to members of the engineering department."
	req_access = list(ACCESS_CE)

/obj/item/storage/lockbox/medal/eng/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/clothing/accessory/medal/silver/engineering(src)

//Yogs: Vial Holder
/obj/item/storage/lockbox/vialbox
	name = "vial box"
	desc = "A small box that can hold up to six vials in a sealed enviroment."
	icon = 'icons/obj/vial_box.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	icon_state = "vialbox"
	req_access = list(ACCESS_MEDICAL)
	icon_locked = "vialbox"
	icon_closed = "vialbox"
	icon_broken = "vialbox"

/obj/item/storage/lockbox/vialbox/update_icon()
	cut_overlays()
	var/locked = SEND_SIGNAL(src, COMSIG_IS_STORAGE_LOCKED)
	var/slot = 1
	for(var/obj/item/reagent_containers/glass/G in contents)
		var/mutable_appearance/vial = mutable_appearance(icon, "vialboxvial[slot]")
		var/mutable_appearance/filling = mutable_appearance(icon, "vialboxvial[slot]-")
		if(G.reagents.total_volume)
			var/percent = round((G.reagents.total_volume / G.volume) * 100)
			switch(percent)
				if(75 to 79)
					filling.icon_state = "vialboxvial[slot]-75"
				if(80 to 90)
					filling.icon_state = "vialboxvial[slot]-80"
				if(91 to INFINITY)
					filling.icon_state = "vialboxvial[slot]-100"

			filling.color = mix_color_from_reagents(G.reagents.reagent_list)
		add_overlay(vial)
		add_overlay(filling)
		slot++
	if(!broken)
		var/mutable_appearance/led = mutable_appearance(icon, "led[locked]")
		add_overlay(led)
	..()

/obj/item/storage/lockbox/vialbox/Initialize()
	. = ..()
	update_icon()

/obj/item/storage/lockbox/vialbox/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_w_class = WEIGHT_CLASS_SMALL
	STR.max_combined_w_class = 12
	STR.max_items = 6
	STR.locked = TRUE
	STR.set_holdable(list(/obj/item/reagent_containers/glass/bottle/vial))

/obj/item/storage/lockbox/vialbox/attackby(obj/item/W, mob/user, params)
	. = ..()
	update_icon()

/obj/item/storage/lockbox/vialbox/AltClick(mob/user)
	..()
	update_icon()

/obj/item/storage/lockbox/vialbox/full/PopulateContents()
	for(var/i in 1 to 6)
		new /obj/item/reagent_containers/glass/bottle/vial(src)

/obj/item/storage/lockbox/vialbox/hypo_deluxe
	name = "deluxe hypospray vial box"
	desc = "A small box that can hold up to six vials in a sealed enviroment. This one contains a plethora of different vials for various medical ailments, designed for use in a deluxe hypospray."
	req_access = list(ACCESS_MEDICAL)

/obj/item/storage/lockbox/vialbox/hypo_deluxe/PopulateContents()
	new /obj/item/reagent_containers/glass/bottle/vial/large/omnizine(src)
	new /obj/item/reagent_containers/glass/bottle/vial/large/brute(src)
	new /obj/item/reagent_containers/glass/bottle/vial/large/burn(src)
	new /obj/item/reagent_containers/glass/bottle/vial/large/tox(src)
	new /obj/item/reagent_containers/glass/bottle/vial/large/oxy(src)
	new /obj/item/reagent_containers/glass/bottle/vial/large/epi(src)

/obj/item/storage/lockbox/vialbox/virology
	name = "virology vial box"
	desc = "A small box that can hold up to six vials in a sealed enviroment. This one requires virology access to open."
	req_access = list(ACCESS_MEDICAL)

/obj/item/storage/lockbox/vialbox/virology/PopulateContents()
	new /obj/item/reagent_containers/glass/bottle/vial/cold(src)
	new /obj/item/reagent_containers/glass/bottle/vial/flu_virion(src)
	for(var/i in 1 to 4)
		new /obj/item/reagent_containers/glass/bottle/vial(src)

/obj/item/storage/lockbox/vialbox/blood
	name = "blood sample box"
	desc = "A small box that can hold up to six vials in a sealed enviroment. This one is intended to store blood."

/obj/item/storage/lockbox/vialbox/blood/PopulateContents()
	for(var/i in 1 to 6)
		new /obj/item/reagent_containers/glass/bottle/vial(src)
