/datum/hud/living/flockdrone
	var/obj/screen/flockdrone_resources/resources

/datum/hud/living/flockdrone/New(mob/owner)
	. = ..()
	var/obj/screen/using

	action_intent = new /obj/screen/act_intent()
	action_intent.icon = ui_style
	action_intent.icon_state = mymob.a_intent
	action_intent.screen_loc = ui_acti
	static_inventory += action_intent

	using = new /obj/screen/mov_intent()
	using.icon = ui_style
	using.icon_state = (mymob.m_intent == MOVE_INTENT_RUN ? "running" : "walking")
	using.screen_loc = ui_movi
	static_inventory += using

	resources = new /obj/screen/ling/chems()
	infodisplay += resources

/obj/screen/flockdrone_resources
	name = "resources"
	icon_state = "power_display"
	screen_loc = ui_lingchemdisplay

/obj/screen/flockdrone_resources/proc/update_counter(value)
	maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#00ffff'>[round(value,1)]</font></div>"

/datum/hud/flocktrace
	var/obj/screen/flockdrone_resources/flocktrace/compute

/datum/hud/flocktrace/New(mob/owner)
	. = ..()
	compute = new /obj/screen/flockdrone_resources/flocktrace ()
	infodisplay += compute

/obj/screen/flockdrone_resources/flocktrace
	name = "compute"