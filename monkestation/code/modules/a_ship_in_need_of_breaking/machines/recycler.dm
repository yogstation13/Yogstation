/obj/machinery/shipbreaker
	name = "ship recycler"
	desc = "An expensive crushing machine used to recycle ship parts somewhat efficiently."
	icon = 'icons/obj/recycling.dmi'
	icon_state = "grinder-o0"
	layer = ABOVE_ALL_MOB_LAYER // Overhead
	plane = ABOVE_GAME_PLANE
	density = TRUE
	circuit = /obj/item/circuitboard/machine/shipbreaker
	var/icon_name = "grinder-o"
	var/bloody = FALSE
	var/eat_dir = WEST
	var/item_recycle_sound = 'sound/items/welder.ogg'
	var/reclaimed = 0

/obj/machinery/shipbreaker/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/shipbreaker/LateInitialize()
	. = ..()
	update_appearance(UPDATE_ICON)
	req_one_access = SSid_access.get_region_access_list(list(REGION_ALL_STATION, REGION_CENTCOM))
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	var/list/allowed_materials = list(
		/datum/material/iron,
		/datum/material/glass,
		/datum/material/silver,
		/datum/material/plasma,
		/datum/material/gold,
		/datum/material/diamond,
		/datum/material/plastic,
		/datum/material/uranium,
		/datum/material/bananium,
		/datum/material/titanium,
		/datum/material/bluespace
	)
	AddComponent(/datum/component/material_container, allowed_materials, INFINITY, MATCONTAINER_NO_INSERT|BREAKDOWN_FLAGS_RECYCLER)

/obj/machinery/shipbreaker/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(scraprecycle), AM)

/obj/machinery/shipbreaker/proc/scraprecycle(atom/movable/morsel, sound=TRUE)
	if(machine_stat & (BROKEN|NOPOWER))
		return
	if(iseffect(morsel))
		return
	if(!isturf(morsel.loc))
		return //I don't know how you called Crossed() but stop it.
	if(morsel.resistance_flags & INDESTRUCTIBLE)
		return
	if(!istype(morsel, /obj/item/stack/scrap)) //we only eat shipbreaker scrap for now
		playsound(src, 'sound/machines/buzz-sigh.ogg')
		return
	var/obj/item/stack/scrap/morselstack = morsel
	if(morselstack.amount > 0)
		var/recycle_reward = morselstack.amount * morselstack.point_value
		reclaimed += recycle_reward
		playsound(src, item_recycle_sound, (50 + morselstack.amount), TRUE, morselstack.amount)
		use_power(active_power_usage)
		var/datum/bank_account/dept_budget = SSeconomy.get_dep_account(ACCOUNT_ENG)
		var/payee_key = morselstack.fingerprintslast

		dept_budget?.adjust_money(recycle_reward, "Shipbreaker Scrap Processed.")
		if(payee_key != null)
			var/mob/living/carbon/human/payee_mob = get_mob_by_key(payee_key)
			if(payee_mob.account_id != null)
				var/datum/bank_account/account = SSeconomy.bank_accounts_by_id["[payee_mob.account_id]"]
				account.adjust_money(recycle_reward*0.2, "Shipbreaker Scrap Processed. Payout:[recycle_reward*0.2]")
		if(morsel?.custom_materials)
			var/datum/component/material_container/materials = GetComponent(/datum/component/material_container)
			var/material_amount = materials.get_item_material_amount(morselstack, BREAKDOWN_FLAGS_RECYCLER)
			if(material_amount)
				materials.insert_item(morselstack, material_amount, multiplier = 1, breakdown_flags=BREAKDOWN_FLAGS_RECYCLER)
				materials.retrieve_all()
	playsound(src, 'sound/machines/ping.ogg', 50, FALSE)
	qdel(morsel)

/obj/machinery/shipbreaker/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(!anchored)
		return
	//if(border_dir == eat_dir)
	return TRUE

/obj/machinery/shipbreaker/examine(mob/user)
	. = ..()
	. += span_notice("<b>[reclaimed]</b> credits worth of materials salvaged.")

/obj/machinery/shipbreaker/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool)
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/machinery/shipbreaker/attackby(obj/item/I, mob/user, params)
	if(default_deconstruction_screwdriver(user, "grinder-oOpen", "grinder-o0", I))
		return

	if(default_pry_open(I, close_after_pry = TRUE))
		return

	if(default_deconstruction_crowbar(I))
		return
	return ..()
