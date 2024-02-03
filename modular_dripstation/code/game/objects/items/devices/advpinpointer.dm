#define SETTING_DISK 0
#define SETTING_OBJECT 1
#define SETTING_PERSON 2
GLOBAL_LIST_INIT(HIGHRISK, typecacheof(list(/obj/item/disk/nuclear,
			/obj/item/gun/energy/laser/captain,
			/obj/item/hand_tele,
			/obj/item/clothing/accessory/medal/gold/captain,
			/obj/item/melee/sabre,
			/obj/item/gun/energy/e_gun/hos,
			/obj/item/card/id/captains_spare,
			/obj/item/tank/jetpack/oxygen/captain,
			/obj/item/aicard,
			/obj/item/hypospray/deluxe/cmo,
			/obj/item/clothing/suit/armor/reactive/teleport,
			/obj/item/clothing/suit/armor/laserproof,
			/obj/item/blackbox,
			/obj/item/holotool,
			/obj/item/areaeditor/blueprints)))
			///obj/item/clothing/gloves/krav_maga/sec,
			///obj/item/cargo_teleporter,
/obj/item/pinpointer/adv
	var/modelocked = FALSE // If true, user cannot change mode.
	var/obj/item/highrisk_rem = null
	var/remember_target = null
	var/setting = SETTING_DISK

/obj/item/pinpointer/adv/examine(mob/user)
	. = ..()
	var/msg = "Its tracking indicator reads "
	if(is_syndicate(user))
		switch(setting)
			if(SETTING_DISK)
				msg += "\"nuclear_disk\"."
			if(SETTING_OBJECT)
				msg += "\"target\"."
			if(SETTING_PERSON)
				msg += "\"person\"."
			else
				msg = "Its tracking indicator is blank."
	else
		msg += "\"nuclear_disk\"."
	. += msg

/obj/item/pinpointer/adv/toggle_on()
	active = !active
	playsound(src, 'sound/items/screwdriver2.ogg', 50, 1)
	if(active)
		if(!is_syndicate(usr))
			setting = SETTING_DISK
		START_PROCESSING(SSfastprocess, src)
	else
		target = null
		highrisk_rem = null
		remember_target = null
		setting = SETTING_DISK
		STOP_PROCESSING(SSfastprocess, src)
	update_appearance(UPDATE_ICON)

/obj/item/pinpointer/adv/scan_for_target()
	target = null
	switch(setting)
		if(SETTING_DISK)
			var/obj/item/disk/nuclear/N = locate() in GLOB.poi_list
			target = N
		if(SETTING_OBJECT)
			if(!highrisk_rem)
				setting = SETTING_DISK
				playsound(src, 'sound/machines/triple_beep.ogg', 50, 1)
				return
			var/obj/item/H = highrisk_rem
			target = H
		if(SETTING_PERSON)
			if(!remember_target)
				setting = SETTING_DISK
				playsound(src, 'sound/machines/triple_beep.ogg', 50, 1)
				return
			target = remember_target
	..()

/obj/item/pinpointer/adv/AltClick(mob/user)
	if(isliving(user))
		if(is_syndicate(user))
			if(!user.is_holding(src))
				to_chat(user, span_notice("You should be able to press the change mode button to interact with interface."))
				return
			var/mob/living/L = user
			to_chat(L, span_danger("Your [name] beeps as it reconfigures it's tracking algorithms."))
			playsound(src, 'sound/machines/boop.ogg', 50, 1)
			switch_mode_to(user)
		else
			setting = SETTING_DISK

/obj/item/pinpointer/adv/proc/switch_mode_to(mob/user)
	switch(alert("Please select the mode you want to put the pinpointer in.", "Pinpointer Mode Select", "Disk Recovery", "High Risk", "DNA RSS"))
		if("Disk Recovery")
			setting = SETTING_DISK
		if("High Risk")
			setting = SETTING_OBJECT
			var/list/item_names[0]
			var/list/item_paths[0]
			for(var/objective in GLOB.HIGHRISK)
				var/obj/item/I = objective
				var/name = initial(I.name)
				item_names += name
				item_paths[name] = objective
			var/targetitem = input("Select item to search for.", "Item Mode Select","") as null|anything in item_names
			if(!targetitem)
				return
			var/list/target_candidates = get_all_of_type(item_paths[targetitem], subtypes = TRUE)
			for(var/obj/item/candidate in target_candidates)
				if(!is_centcom_level((get_turf(candidate)).z))
					highrisk_rem = candidate
					playsound(src, get_sfx("terminal_type"), 25, 1)
					to_chat(user, "<span class='notice'>You set the pinpointer to locate [targetitem].</span>")
					return
			if(!highrisk_rem)
				to_chat(user, "<span class='warning'>Failed to locate [targetitem]!</span>")
				return

		if("DNA RSS")
			setting = SETTING_PERSON
			var/DNAstring = input("Input DNA string to search for." , "Please Enter String." , "")
			if(!DNAstring)
				return
			for(var/mob/living/carbon/C in GLOB.mob_list)
				if(!C.dna)
					continue
				if(C.dna.unique_enzymes == DNAstring)
					if(!is_centcom_level((get_turf(C)).z))
						remember_target = C
						playsound(src, get_sfx("terminal_type"), 25, 1)
						to_chat(user, "<span class='notice'>You set the pinpointer to locate somebody.</span>")
					else
						playsound(src, 'sound/machines/triple_beep.ogg', 50, 1)
						to_chat(user, "<span class='warning'>Malfunction detected.</span>")
