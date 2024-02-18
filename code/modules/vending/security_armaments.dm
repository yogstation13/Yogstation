// An armaments dispenser that gives security officers their roundstart weapon
/obj/machinery/armaments_dispenser
	name = "armaments dispenser"
	desc = "A standard issue security armaments dispenser."
	icon = 'yogstation/icons/obj/vending.dmi'
	icon_state = "armament" // BAIOMU REPLACE THIS WITH YOUR SPRITE
	layer = 2.9
	density = TRUE
	var/list/inventory = list()
	var/list/allowed_types = list(/obj/item/ammo_box/magazine/recharge/ntusp)
	
	contents = newlist(/obj/item/gun/energy/disabler, 
					   /obj/item/gun/ballistic/automatic/pistol/ntusp)


/obj/machinery/armaments_dispenser/Initialize(mapload)
	. = ..()
	inventory = contents.Copy()
	for(var/obj/item/wep in inventory)
		allowed_types += wep.type
	
/obj/machinery/armaments_dispenser/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/security_armaments),
	)

/obj/machinery/armaments_dispenser/ui_act(action, params)
	if(..())
		return TRUE

	var/allowed = FALSE
	var/can_claim = FALSE
	var/obj/item/card/id/C = usr?.get_idcard()
	// Security officers and wardens
	if(istype(C) && (ACCESS_SECURITY in C.access) && (ACCESS_WEAPONS in C.access) && !(ACCESS_HOS in C.access))
		allowed = TRUE
	// Hasn't claimed a weapon yet
	if(C?.registered_account && !C.registered_account.sec_weapon_claimed)
		can_claim = TRUE

	if(!allowed)
		return FALSE
	
	if(!can_claim)
		return FALSE

	switch(action)
		if("dispense_weapon")
			if(params["weapon"] && ispath(text2path(params["weapon"])))
				var/wep = text2path(params["weapon"])
				if(!(wep in allowed_types))
					message_admins("[ADMIN_LOOKUPFLW(usr)] just attempted to purchase a [wep] from the armaments dispenser.")
					log_admin("[ADMIN_LOOKUP(usr)] attempted to purchase a [wep] from the armaments dispenser.")
					return FALSE
				new wep(loc)
				if(params["magazine"] && ispath(text2path(params["magazine"])))
					var/mag = text2path(params["magazine"])
					if(!(mag in allowed_types))
						message_admins("[ADMIN_LOOKUPFLW(usr)] just attempted to purchase a [mag] from the armaments dispenser.")
						log_admin("[ADMIN_LOOKUP(usr)] attempted to purchase a [mag] from the armaments dispenser.")
						return FALSE
					new mag(loc)
			else
				return FALSE
			if(prob(0.1)) //Easteregg of the exploit that allowed you to buy an actual real ratvar mob
				playsound(src, 'sound/magic/clockwork/ark_activation.ogg', 50, 0)
				visible_message(message = "<span class='big_brass'>Ratvar has risen! ...from the vendor?</span>")
				new /obj/item/toy/plush/plushvar(loc)
			C.registered_account.sec_weapon_claimed = TRUE
			return TRUE
	return FALSE

/obj/machinery/armaments_dispenser/ui_interact(mob/user, datum/tgui/ui)
	if(stat & (BROKEN | NOPOWER | MAINT))
		if(ui)
			ui.close()
		return 0

	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "ArmamentsDispenser")
		ui.open()

/obj/machinery/armaments_dispenser/ui_static_data(mob/user)
	var/list/data = ..()
	var/list/items = list()
	for(var/obj/item/wep in inventory)
		var/obj/item/gun/weapon = wep
		weapon.update_appearance(UPDATE_ICON)
		var/icon/gun_icon = getFlatIcon(wep)
		
		var/list/details = list()
		details["name"] = weapon.name
		details["description"] = weapon.desc
		details["path"] = weapon.type
		
		var/md5 = md5(fcopy_rsc(gun_icon))
		
		if(!SSassets.cache["photo_[md5]_icon.png"])
			SSassets.transport.register_asset("photo_[md5]_icon.png", gun_icon)

		SSassets.transport.send_assets(user, list("photo_[md5]_icon.png" = gun_icon))
		details["gun_icon"] = SSassets.transport.get_asset_url("photo_[md5]_icon.png")
		if(istype(weapon, /obj/item/gun/ballistic))
			var/obj/item/gun/ballistic/gun = wep
			var/icon/mag_icon = getFlatIcon(gun.magazine)
			md5 = md5(fcopy_rsc(mag_icon))
			
			if(!SSassets.cache["photo_[md5]_icon.png"])
				SSassets.transport.register_asset("photo_[md5]_icon.png", mag_icon)
			SSassets.transport.send_assets(user, list("photo_[md5]_icon.png" = mag_icon))
			details["mag_icon"] = SSassets.transport.get_asset_url("photo_[md5]_icon.png")
			details["mag_path"] = gun.mag_type
		items += list(details)
	
	data["inventory"] = items
	return data

/obj/machinery/armaments_dispenser/ui_data(mob/user)
	var/list/data = ..()
	
	var/allowed = FALSE
	var/can_claim = FALSE
	var/obj/item/card/id/C = user?.get_idcard()
	// Security officers and wardens
	if(istype(C) && (ACCESS_SECURITY in C.access) && (ACCESS_WEAPONS in C.access) && !(ACCESS_HOS in C.access))
		allowed = TRUE
	// Hasn't claimed a weapon yet
	if(C?.registered_account && !C.registered_account.sec_weapon_claimed)
		can_claim = TRUE

	data["allowed"] = allowed
	data["can_claim"] = can_claim
	
	return data
