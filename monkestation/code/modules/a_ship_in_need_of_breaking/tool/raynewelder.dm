
/obj/item/weldingtool/electric/raynewelder
	name = "laser welding tool"
	desc = "A Rayne corp laser cutter and welder. This Laser welder has a built in safety to turn off outside Nanotrasens designated shipbreaking area."
	icon = 'monkestation/icons/obj/rayne_corp/rayne.dmi'
	icon_state = "raynewelder"
	inhand_icon_state = "raynewelder"
	lefthand_file = 'monkestation/icons/mob/inhands/equipment/engineering_lefthand.dmi'
	righthand_file = 'monkestation/icons/mob/inhands/equipment/engineering_righthand.dmi'
	light_power = 1
	light_color = LIGHT_COLOR_FLARE
	tool_behaviour = NONE
	toolspeed = 0.2
	power_use_amount = 20
	// We don't use fuel
	change_icons = FALSE
	max_fuel = 20

/obj/item/weldingtool/electric/raynewelde/attack_self(mob/user)
	if(!istype(get_area(src), /area/shipbreak))
		return

/obj/item/weldingtool/electric/raynewelder/process(seconds_per_tick)
	if(!istype(get_area(src), /area/shipbreak))
		src.say("Outside of Designated Area.")
		switched_off()
		return
	if(!powered)
		switched_off()
		return
	if(!(item_use_power(power_use_amount) & COMPONENT_POWER_SUCCESS))
		switched_off()
		return
