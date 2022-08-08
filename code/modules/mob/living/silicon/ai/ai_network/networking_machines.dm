/obj/machinery/ai/networking
	name = "networking machine"
	desc = "A solar panel. Generates electricity when in contact with sunlight."
	icon = 'goon/icons/obj/power.dmi'
	icon_state = "sp_base"
	density = TRUE
	use_power = NO_POWER_USE
	idle_power_usage = 0
	active_power_usage = 0
	max_integrity = 150
	integrity_failure = 0.33

	var/label

	var/mutable_appearance/panelstructure
	var/mutable_appearance/paneloverlay

	var/obj/machinery/ai/networking/partner
	var/rotation_to_partner

/obj/machinery/ai/networking/Initialize(mapload)
	. = ..()
	label = num2hex(rand(1,65535), -1)
	panelstructure = mutable_appearance(icon, "solar_panel", FLY_LAYER)
	paneloverlay = mutable_appearance(icon, "solar_panel-o", FLY_LAYER)
	paneloverlay.color = "#599ffa"
	update_icon(TRUE)

/obj/machinery/ai/networking/Destroy(mapload)
	disconnect()
	. = ..()


/obj/machinery/ai/networking/update_icon(forced = FALSE)
	..()
	if(!rotation_to_partner && !forced)
		return
	cut_overlays()
	var/matrix/turner = matrix()
	turner.Turn(rotation_to_partner)
	panelstructure.transform = turner
	paneloverlay.transform = turner
	add_overlay(list(paneloverlay, panelstructure))

/obj/machinery/ai/networking/proc/disconnect()
	if(partner)
		partner.network.update_remotes()
		network.update_remotes()
		partner.partner = null
		partner = null
		

/obj/machinery/ai/networking/proc/connect_to_partner(obj/machinery/ai/networking/target)
	partner = target
	rotation_to_partner = Get_Angle(src, partner)
	target.partner = src
	target.rotation_to_partner = GetAngle(target, src)
	target.update_icon()

	partner.network.update_remotes()
	network.update_remotes()

	update_icon()
	

/obj/machinery/ai/networking/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AiNetworking", name)
		ui.open()

/obj/machinery/ai/networking/ui_data(mob/living/carbon/human/user)
	var/list/data = list()

	return data

/obj/machinery/ai/networking/ui_act(action, params)
	if(..())
		return

	switch(action)
		if("log_out")
			if(one_time_password_used)
				return
			authenticated = FALSE
			. = TRUE


