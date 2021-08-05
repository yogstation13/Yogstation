/datum/modular_hardsuit
	var/inserted_modules
	var/obj/item/clothing/suit/space/hardsuit/suit

/datum/modular_hardsuit/New(new_suit)
	if(!new_suit || !istype(new_suit(/obj/item/clothing/suit/space/hardsuit)))
		qdel(src)
		stack_trace("Modular hardsuit datum initialized with no suit attached!")
		return
	suit = new_suit
	inserted_modules = list()
	if(suit.initial_modules.length)
		initialize_builtin_modules()


/datum/modular_hardsuit/proc/initialize_builtin_modules()
	for(var/obj/item/hardsuit_upgrade/module as anything in suit.initial_modules)
		module = new()
		module.forceMove(suit)
		module.passive_effect(suit)
		inserted_modules += module

/datum/modular_hardsuit/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ModularHardsuit")
		ui.open()


/datum/modular_hardsuit/ui_data(mob/user)
	. = list()


/datum/modular_hardsuit/ui_act(action, params)
	if(..())
		return

/datum/modular_hardsuit/ui_state(mob/user)
	return GLOB.not_incapacitated_state

/datum/action/innate/hardsuit_ui
	name = "Access Internal Controls"
	icon_icon = 'icons/obj/clothing/suits.dmi'
	button_icon_state = "hardsuit-engineering"
	var/obj/item/clothing/suit/space/hardsuit/suit

/datum/action/innate/hardsuit_ui/Activate()
	if(!suit)
		return
	suit.mod_suit.ui_interact(owner)




