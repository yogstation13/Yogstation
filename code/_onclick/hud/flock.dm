/datum/hud/living/flock

/datum/hud/living/flock/New(mob/owner)
	. = ..()
    
	action_intent = new /obj/screen/act_intent()
	action_intent.icon = ui_style
	action_intent.icon_state = mymob.a_intent
	action_intent.screen_loc = ui_acti
	static_inventory += action_intent