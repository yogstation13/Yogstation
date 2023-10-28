GLOBAL_DATUM_INIT(thrallnet, /datum/cameranet/darkspawn, new)

/datum/action/cooldown/spell/pointed/thrall_net
	name = "Thrall net"
	desc = "Call up your boys."
	panel = null
	button_icon = 'yogstation/icons/mob/actions/actions_darkspawn.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"
	buttontooltipstyle = "alien"
	button_icon_state = "sacrament"
	check_flags = AB_CHECK_HANDS_BLOCKED | AB_CHECK_CONSCIOUS | AB_CHECK_LYING
	cooldown_time = 1 MINUTES
	spell_requirements = SPELL_REQUIRES_DARKSPAWN
	cast_range = 2
	var/casting = FALSE
	var/cast_time = 2 SECONDS

/datum/action/cooldown/spell/pointed/thrall_net/can_cast_spell(feedback)
	if(casting)
		return FALSE
	. = ..()

/datum/action/cooldown/spell/pointed/thrall_net/before_cast(atom/cast_on)
	. = ..()
	if(cast_on.density)
		return . | SPELL_CANCEL_CAST
	if(casting)
		return . | SPELL_CANCEL_CAST
	if(. & SPELL_CANCEL_CAST)
		return .
	casting = TRUE
	playsound(get_turf(owner), 'yogstation/sound/magic/devour_will_begin.ogg', 50, TRUE)
	if(!do_after(owner, cast_time, cast_on))
		casting = FALSE
		return . | SPELL_CANCEL_CAST
	casting = FALSE
	
/datum/action/cooldown/spell/pointed/thrall_net/cast(atom/cast_on)
	. = ..()
	owner.visible_message(span_warning("[owner] pulled shadows together into an orb!"), span_velvet("You summon your orb"))
	playsound(get_turf(owner), 'yogstation/sound/magic/devour_will_end.ogg', 50, TRUE)
	new /obj/machinery/computer/camera_advanced/darkspawn(get_turf(cast_on))
	
/obj/machinery/computer/camera_advanced/darkspawn
	name = "dark orb"
	desc = "SEND DUDES"
	icon = 'icons/obj/computer.dmi'
	icon_state = "computer"
	special = TRUE
	use_power = NO_POWER_USE
	flags_1 = NODECONSTRUCT_1
	max_integrity = 200
	integrity_failure = 0
	light_power = -1
	light_color = COLOR_DARKSPAWN_PSI
	light_system = MOVABLE_LIGHT //it's not movable, but the new system looks nicer for this purpose
	networks = list(ROLE_DARKSPAWN)
	clicksound = "crawling_shadows_walk"

/obj/machinery/computer/camera_advanced/darkspawn/Initialize(mapload)
	. = ..()
	camnet = GLOB.thrallnet

/obj/machinery/computer/camera_advanced/darkspawn/can_use(mob/living/user)
	if(user && !is_darkspawn_or_veil(user))
		return FALSE
	return ..()

/obj/machinery/computer/camera_advanced/darkspawn/CreateEye()
	. = ..()
	eyeobj.nightvision = TRUE

/obj/machinery/computer/camera_advanced/darkspawn/emp_act(severity)
	return
