/obj/machinery/bomb_actualizer
	name = "Bomb Actualizer"
	desc = "An advanced machine capable of releasing the normally bluespace-inhibited destructive potential of a bomb assembly... or so the sticker says"
	circuit = /obj/item/circuitboard/machine/bomb_actualizer
	icon = 'icons/obj/machines/research.dmi'
	base_icon_state = "bomb_actualizer"
	icon_state = "bomb_actualizer"
	density = TRUE
	max_integrity = 600
	use_power = NO_POWER_USE
	resistance_flags = FIRE_PROOF | ACID_PROOF
	processing_flags = START_PROCESSING_MANUALLY
	subsystem_type = /datum/controller/subsystem/processing/fastprocess

	/**
	* Stages for countdown warnings and alerts.
	* 0 = no major alerts,
	* 1 = the timer has reached 60 seconds,
	* 2 = the timer has reached 10 seconds (it will reset to zero immediately after)
	*/
	var/stage = 0
	//location to call out on priority message
	var/alerthere = ""
	/// The TTV inserted in the machine.
	var/obj/item/transfer_valve/inserted_bomb
	//combined gasmix to determine the simulation to reality
	var/datum/gas_mixture/combined_gasmix
	//Timer till detonation in seconds
	var/default_time = 420 SECONDS
	//used to track current world time
	var/timer = null
	/// The countdown that'll show up to ghosts regarding the bomb's timer.
	var/obj/effect/countdown/bomb_actualizer/countdown
	//Can examine the Countdown
	var/examinable_countdown = TRUE
	//So the ttv transfers gas properly
	var/obj/item/tank/tank_to_target
	//For managing if the tank exploded so it doesnt explode twice
	var/active = FALSE
	var/exploded = FALSE
	//When to beep (every second)
	var/next_beep = null
	//sounds for scaryness
	var/beepsound = 'sound/items/timer.ogg'
	var/scarywarning = 'sound/misc/bloblarm.ogg'
	var/verybadsound = 'sound/machines/engine_alert1.ogg'
	var/youdied = 'sound/misc/guitarreverb.ogg'
	/// The countdown that'll show up to ghosts regarding the bomb's timer.
	///Our internal radio
	var/obj/item/radio/radio
	///The key our internal radio uses
	var/radio_key = /obj/item/encryptionkey/headset_sci
	///The common channel
	var/common_channel = null
	//Cooldown for pressing button
	var/COOLDOWN_BOMB_BUTTON

/obj/machinery/bomb_actualizer/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ATOM_INTERNAL_EXPLOSION, PROC_REF(modify_explosion))
	radio = new(src)
	radio.keyslot = new radio_key
	radio.set_listening(FALSE)
	radio.recalculateChannels()
	countdown = new(src)
	update_appearance()

//For when the machine is destroyed
/obj/machinery/bomb_actualizer/Destroy()
	inserted_bomb = null
	radio = null
	combined_gasmix = null
	QDEL_NULL(countdown)
	end_processing()
	return ..()

/obj/machinery/bomb_actualizer/attackby(obj/item/tool, mob/living/user, params)
	if(active && istype(tool, /obj/item/transfer_valve))
		to_chat(user, span_warning("You can't insert [tool] into [src] while [p_theyre()] currently active."))
		return
	if(istype(tool, /obj/item/transfer_valve))
		if(inserted_bomb)
			to_chat(user, span_warning("There is already a bomb in [src]."))
			return
		var/obj/item/transfer_valve/valve = tool
		if(!valve.ready())
			to_chat(user, span_warning("[valve] is incomplete."))
			return
		if(!user.transferItemToLoc(tool, src))
			to_chat(user, span_warning("[tool] is stuck to your hand."))
			return
		inserted_bomb = tool
		tank_to_target = inserted_bomb.tank_two
		to_chat(user, span_notice("You insert [tool] into [src]"))
		return
	update_appearance()
	return ..()

/obj/machinery/bomb_actualizer/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	if(!active)
		default_unfasten_wrench(user, tool)
		return TOOL_ACT_TOOLTYPE_SUCCESS
	return FALSE

/obj/machinery/bomb_actualizer/screwdriver_act(mob/living/user, obj/item/tool)
	if(!active)
		if(!default_deconstruction_screwdriver(user, "[base_icon_state]-off", "[base_icon_state]", tool))
			return FALSE
	update_appearance()
	return TRUE

/obj/machinery/bomb_actualizer/crowbar_act(mob/living/user, obj/item/tool)
	if(!default_deconstruction_crowbar(tool) && !active)
		return FALSE
	return TRUE

/**
 * Starts the Detonation Sequence
 */
/obj/machinery/bomb_actualizer/proc/start_detonation()
	if(!TIMER_COOLDOWN_CHECK(src, COOLDOWN_BOMB_BUTTON))

		if(active)
			say("ERROR: The countdown has aready begun!!!")
			TIMER_COOLDOWN_START(src, COOLDOWN_BOMB_BUTTON, 3 SECONDS)
			return

		else if(!istype(inserted_bomb))
			say("ERROR: No Bomb Inserted")
			TIMER_COOLDOWN_START(src, COOLDOWN_BOMB_BUTTON, 3 SECONDS)
			return

		else if(istype(get_area(src), /area/space))
			say("ERROR: Does not work in space!")
			TIMER_COOLDOWN_START(src, COOLDOWN_BOMB_BUTTON, 3 SECONDS)
			return

		else if(src.anchored == FALSE)
			say("ERROR: Needs to be anchored!")
			TIMER_COOLDOWN_START(src, COOLDOWN_BOMB_BUTTON, 3 SECONDS)
			return

		else if(!on_reebe(src))
			say("Beginning detonation sequence. Countdown starting.")
			alerthere = get_area(src)
			countdown.start()
			active = TRUE
			next_beep = world.time + 1 SECONDS
			timer = world.time + (default_time)
			begin_processing()
			priority_announce("DANGER - Tampering of bluespace ordinance dampeners detected, Resulting explosion may be catastrophic to station integrity. \
						Remove the tampering device within 7 Minutes or evacuate the localized areas. \
						Location: [alerthere].", "Doppler Array Detection - DANGER", 'sound/misc/notice3.ogg')
			TIMER_COOLDOWN_START(src, COOLDOWN_BOMB_BUTTON, 3 SECONDS)
			return
		say("UNKNOWN ERROR: Nice try nerd. ")
		TIMER_COOLDOWN_START(src, COOLDOWN_BOMB_BUTTON, 3 SECONDS)
	return

//Process for handling the bombs timer
/obj/machinery/bomb_actualizer/process()
	var/volume = 40
	if(!active)
		end_processing()
		timer = null
		next_beep = null
		countdown.stop()
		stage = 0
		return
	if(!isnull(next_beep) && (next_beep <= world.time))

		playsound(loc, beepsound, volume, FALSE)
		next_beep = world.time +10
	if(seconds_remaining() <= 60)
		if(stage == 0)
			radio.talk_into(src, "WARNING: DETONATION IN ONE MINUTE.", common_channel)
			playsound(loc, scarywarning, volume, FALSE)
			stage++
	if(seconds_remaining() <= 10)
		if(stage == 1)
			radio.talk_into(src, "FAILSAFE DISENGAGED, DETONATION IMMINENT", common_channel)
			playsound(loc, verybadsound, 80, FALSE)
			stage++

	if(active && (timer <= world.time))
		playsound(loc, youdied, 100, FALSE, 45)
		active = FALSE
		stage = 0
		update_appearance()
		inserted_bomb.toggle_valve(tank_to_target)


/obj/machinery/bomb_actualizer/proc/seconds_remaining()
	if(active)
		. = max(0, round(timer - world.time) / 10)

	else
		. = 420



	/**
	* catches the parameters of the TTV's explosion as it happens internally,
	* cancels the explosion and then re-triggers it to happen with modified perameters (such as maxcap = false)
	* while REDUCING the theoretical size by actualizer multiplier
	* (actualizer_multiplier 0.25 would mean the 200 size theoretical bomb is only 12 + (200*0.25) in size )
	*/
/obj/machinery/bomb_actualizer/proc/modify_explosion(atom/source, list/arguments)
	SIGNAL_HANDLER
	if(!exploded)
		var/heavy = arguments[EXARG_KEY_DEV_RANGE]
		var/medium = arguments[EXARG_KEY_HEAVY_RANGE]
		var/light = arguments[EXARG_KEY_LIGHT_RANGE]
		var/flame = 0
		var/flash = 0
		var/turf/location = get_turf(src)
		var/actualizer_multiplier = 0.5
		var/capped_heavy
		var/capped_medium
		var/capped_light

		if(heavy > 12)
			capped_heavy = (GLOB.MAX_EX_DEVESTATION_RANGE + (heavy * actualizer_multiplier))

		if(medium > 12)
			capped_medium = (GLOB.MAX_EX_HEAVY_RANGE + (medium * actualizer_multiplier))

		if(light > 12)
			capped_light = (GLOB.MAX_EX_LIGHT_RANGE + (light * actualizer_multiplier))

		if(capped_light > 200)
			capped_light = 200

		if(capped_medium > 120)
			capped_medium = 120

		if(capped_heavy > 60)
			capped_heavy = 60

		SSexplosions.explode(location, capped_heavy, capped_medium, capped_light, flame, flash, TRUE, TRUE, FALSE, FALSE)
		exploded = TRUE
		return COMSIG_CANCEL_EXPLOSION
	return COMSIG_ATOM_EXPLODE

/obj/machinery/bomb_actualizer/examine(mob/user)
	. = ..()
	. += "Big bomb."
	if(examinable_countdown)
		. += span_notice("A digital display on it reads \"[seconds_remaining()]\".")
		if(active)
			balloon_alert(user, "[seconds_remaining()]")
	else
		. += span_notice({"The digital display on it is inactive."})

/obj/machinery/bomb_actualizer/ui_interact(mob/user, datum/tgui/ui)
	.=..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BombActualizer", name)
		ui.open()

/obj/machinery/bomb_actualizer/ui_act(action, params)
	. = ..()
	if (.)
		return
	if(action == "start_timer" && !active)
		start_detonation()

