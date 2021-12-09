GLOBAL_LIST_EMPTY(data_cores)
GLOBAL_VAR_INIT(primary_data_core, null)


/obj/machinery/ai/data_core
	name = "AI Data Core"
	desc = "A complicated computer system capable of emulating the neural functions of a human at near-instantanous speeds."
	icon = 'icons/obj/machines/telecomms.dmi'
	icon_state = "hub"
	
	var/primary = FALSE

/obj/machinery/ai/data_core/Initialize()
	..()
	GLOB.data_cores += src
	if(primary && !GLOB.primary_data_core)
		GLOB.primary_data_core = src
	update_icon()

/obj/machinery/ai/data_core/Destroy()
	GLOB.data_cores -= src
	if(GLOB.primary_data_core == src)
		GLOB.primary_data_core = null

	for(var/mob/living/silicon/ai/AI in contents)
		AI.relocate()
	..()

/obj/machinery/ai/data_core/examine(mob/user)
	. = ..()
	if(!isobserver(user))
		return
	. += "<b>Networked AI Laws:</b>"
	for(var/mob/living/silicon/ai/AI in GLOB.ai_list)
		var/active_status = !AI.mind ? "(<span class='warning'>OFFLINE</span>)" : ""
		. += "<b>[AI] [active_status] has the following laws:"
		for(var/law in AI.laws.get_law_list(include_zeroth = TRUE))
			. += law


/obj/machinery/ai/data_core/proc/can_transfer_ai()
	if(stat & (BROKEN|NOPOWER|EMPED))
		return FALSE
	return TRUE
	
/obj/machinery/ai/data_core/proc/transfer_AI(mob/living/silicon/ai/AI)
	AI.forceMove(src)
	AI.eyeobj.forceMove(get_turf(src))

/obj/machinery/ai/data_core/update_icon()
	cut_overlays()
	
	if(!(stat & (BROKEN|NOPOWER|EMPED)))
		var/mutable_appearance/on_overlay = mutable_appearance(icon, "[initial(icon_state)]_on")
		add_overlay(on_overlay)


/obj/machinery/ai/data_core/primary
	name = "primary AI Data Core"
	desc = "A complicated computer system capable of emulating the neural functions of a human at near-instantanous speeds. This one has a scrawny and faded note saying: 'Primary AI Data Core'"
	primary = TRUE
