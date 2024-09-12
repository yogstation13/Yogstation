/obj/machinery/artifact_zapper
	name = "artifact zapper"
	desc = "A directed tesla coil, zaps the object that it is facing. VERY power-consuming. Can attempt to turn artifacts into wands if hit with a multi-tool."
	icon = 'icons/obj/machines/artifact_machines.dmi'
	icon_state = "zapper"
	base_icon_state = "zapper"
	density = TRUE
	use_power = IDLE_POWER_USE
	circuit = /obj/item/circuitboard/machine/artifactzapper
	///max shock level
	var/max_shock = 100
	///chosen level
	var/chosen_level = 100
	var/pulse_cooldown_time = 4 SECONDS

	var/into_wand_mode = FALSE
	COOLDOWN_DECLARE(pulse_cooldown)

/obj/machinery/artifact_zapper/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/simple_rotation, ROTATION_REQUIRE_WRENCH)
	RefreshParts()

/obj/machinery/artifact_zapper/RefreshParts()
	. = ..()
	var/shock = 0
	for(var/datum/stock_part/capacitor/capac in component_parts)
		shock += round(1250 * capac.tier)
	max_shock = shock

	for(var/datum/stock_part/scanning_module/scan in component_parts)
		pulse_cooldown_time = 4 SECONDS / scan.tier

/obj/machinery/artifact_zapper/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ArtifactZapper", name)
		ui.open()

/obj/machinery/artifact_zapper/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("strength")
			chosen_level = clamp(params["target"], 0, max_shock)
			. = TRUE
			active_power_usage = chosen_level * 5
			return
		if("shock")
			shock()
			return
	update_appearance()

/obj/machinery/artifact_zapper/proc/shock()
	if(!COOLDOWN_FINISHED(src,pulse_cooldown))
		return
	var/turf/target_turf = get_step(src,dir)
	var/datum/component/artifact/component
	for(var/obj/object in target_turf)
		component = object.GetComponent(/datum/component/artifact)
		if(component)
			break
	if(!component)
		return

	Beam(component.parent, icon_state="lightning[rand(1,12)]", time = pulse_cooldown_time)
	playsound(get_turf(src), 'sound/magic/lightningshock.ogg', 60, TRUE, extrarange = 2)
	use_power(chosen_level)
	if(!into_wand_mode)
		component.process_stimuli(STIMULUS_SHOCK, chosen_level)
	else
		if(prob(round(chosen_level/100)))
			var/obj/item/artifact_summon_wand/wand = new(target_turf)
			visible_message("[component.holder] is shocked into [wand]!")
		else
			visible_message("[component.holder] is shocked into oblivion!")
		qdel(component.holder)
	COOLDOWN_START(src,pulse_cooldown, pulse_cooldown_time)


/obj/machinery/artifact_zapper/ui_data(mob/user)
	. = ..()
	.["pulsing"] = !COOLDOWN_FINISHED(src,pulse_cooldown)
	.["current_strength"] = chosen_level
	.["max_strength"] = max_shock
	return .

/obj/machinery/artifact_zapper/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	obj_flags |= EMAGGED
	to_chat(user,span_notice("You short out the safety sensors on the [src]."))
	playsound(src, SFX_SPARKS, 75, TRUE, SILENCED_SOUND_EXTRARANGE)


/obj/machinery/artifact_zapper/multitool_act(mob/living/user, obj/item/tool)
	if(!COOLDOWN_FINISHED(src,pulse_cooldown))
		return TOOL_ACT_SIGNAL_BLOCKING
	into_wand_mode = !into_wand_mode
	visible_message(span_info("[src] switches to [into_wand_mode ? "attempting to break down artifacts." : "just zapping artifacts." ]"))
	return TOOL_ACT_MELEE_CHAIN_BLOCKING
/obj/machinery/artifact_zapper/screwdriver_act(mob/living/user, obj/item/tool)
	if(!COOLDOWN_FINISHED(src,pulse_cooldown))
		return TOOL_ACT_SIGNAL_BLOCKING
	. = default_deconstruction_screwdriver(user, base_icon_state, base_icon_state, tool)

/obj/machinery/artifact_zapper/crowbar_act(mob/living/user, obj/item/tool)
	return !COOLDOWN_FINISHED(src,pulse_cooldown) ? TOOL_ACT_SIGNAL_BLOCKING : default_deconstruction_crowbar(tool)

/obj/machinery/artifact_zapper/wrench_act_secondary(mob/living/user, obj/item/tool)
	return !COOLDOWN_FINISHED(src,pulse_cooldown) ? TOOL_ACT_SIGNAL_BLOCKING : default_unfasten_wrench(user, tool)
