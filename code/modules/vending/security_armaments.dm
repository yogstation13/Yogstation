// An armaments dispenser that gives security officers their roundstart weapon
/obj/machinery/armaments_dispenser
	name = "armaments dispenser"
	desc = "A standard issue security armaments dispenser."
	icon = 'icons/obj/vending.dmi'
	icon_state = "armament" // BAIOMU REPLACE THIS WITH YOUR SPRITE
	layer = 2.9
	density = TRUE

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
	if(!C?.registered_account?.sec_weapon_claimed)
		can_claim = TRUE

	if(!allowed)
		return FALSE
	
	if(!can_claim)
		return FALSE

	switch(action)
		if("dispense_weapon")
			switch(params["weapon"])
				if("disabler")
					new /obj/item/gun/energy/disabler(loc)
				if("usp") // One NT-USP and a spare magazine
					new /obj/item/gun/ballistic/automatic/pistol/ntusp(loc)
					new /obj/item/ammo_box/magazine/recharge/ntusp(loc)
				else
					return FALSE
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

/obj/machinery/armaments_dispenser/ui_data(mob/user)
	var/list/data = ..()
	
	var/allowed = FALSE
	var/can_claim = FALSE
	var/obj/item/card/id/C = user?.get_idcard()
	// Security officers and wardens
	if(istype(C) && (ACCESS_SECURITY in C.access) && (ACCESS_WEAPONS in C.access) && !(ACCESS_HOS in C.access))
		allowed = TRUE
	// Hasn't claimed a weapon yet
	if(!C?.registered_account?.sec_weapon_claimed)
		can_claim = TRUE

	data["allowed"] = allowed
	data["can_claim"] = can_claim
	
	return data
