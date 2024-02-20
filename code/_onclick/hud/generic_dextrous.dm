//Used for normal mobs that have hands.
/datum/hud/dextrous/New(mob/living/owner)
	..()
	var/atom/movable/screen/using

	using = new /atom/movable/screen/drop(src)
	using.icon = ui_style
	using.screen_loc = ui_drone_drop
	static_inventory += using

	pull_icon = new /atom/movable/screen/pull(src)
	pull_icon.icon = ui_style
	pull_icon.update_appearance(UPDATE_ICON)
	pull_icon.screen_loc = ui_drone_pull
	static_inventory += pull_icon

	build_hand_slots()

	using = new /atom/movable/screen/swap_hand(src)
	using.icon = ui_style
	using.icon_state = "swap_1_m"
	using.screen_loc = ui_swaphand_position(owner,1)
	static_inventory += using

	using = new /atom/movable/screen/swap_hand(src)
	using.icon = ui_style
	using.icon_state = "swap_2"
	using.screen_loc = ui_swaphand_position(owner,2)
	static_inventory += using

	if(mymob.possible_a_intents)
		if(mymob.possible_a_intents.len == 4)
			// All possible intents - full intent selector
			action_intent = new /atom/movable/screen/act_intent/segmented(src)
		else
			action_intent = new /atom/movable/screen/act_intent(src)
			action_intent.icon = ui_style
		action_intent.icon_state = mymob.a_intent
		static_inventory += action_intent


	zone_select = new /atom/movable/screen/zone_sel(src)
	zone_select.icon = ui_style
	zone_select.update_appearance(UPDATE_ICON)
	static_inventory += zone_select

	using = new /atom/movable/screen/area_creator(src)
	using.icon = ui_style
	static_inventory += using

	mymob.client.screen = list()

	for(var/atom/movable/screen/inventory/inv in (static_inventory + toggleable_inventory))
		if(inv.slot_id)
			inv_slots[TOBITSHIFT(inv.slot_id) + 1] = inv
			inv.update_appearance(UPDATE_ICON)

/datum/hud/dextrous/persistent_inventory_update()
	if(!mymob)
		return
	var/mob/living/D = mymob
	if(hud_version != HUD_STYLE_NOHUD)
		for(var/obj/item/I in D.held_items)
			I.screen_loc = ui_hand_position(D.get_held_index_of_item(I))
			D.client.screen += I
	else
		for(var/obj/item/I in D.held_items)
			I.screen_loc = null
			D.client.screen -= I


//Dextrous simple mobs can use hands!
/mob/living/simple_animal/create_mob_hud()
	if(dextrous)
		hud_type = dextrous_hud_type
	return ..()
