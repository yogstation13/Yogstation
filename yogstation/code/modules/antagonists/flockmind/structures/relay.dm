/obj/structure/destructible/flock/the_relay
	name = "titanic polyhedron"
	desc = "The sight of the towering geodesic sphere fills you with dread. A thousand voices whisper to you."
	flock_id = "Signal Relay Broadcast Amplifier"
	flock_desc = "Your goal and purpose. Defend it until it can broadcast The Signal."
	icon = 'goon/icons/obj/the_relay.dmi'
	icon_state = "structure-relay"
	max_integrity = 600
	var/conversion_radius = 1
	var/last_time_sound_played = 0
	var/sound_length = 27 SECONDS
	var/charge_time_length = 6 MINUTES
	var/final_charge_time_length = 18 SECONDS
	var/finished = FALSE
	var/col_r = 0.1
	var/col_g = 0.7
	var/col_b = 0.6
	var/brightness = 0.5
	var/shuttle_departure_delayed = FALSE

/obj/structure/destructible/flock/the_relay/Initialize()
	. = ..()
	SSshuttle.registerHostileEnvironment(src)
	var/datum/team/flock/flock = GLOB.flock
	flock.relay_builded = TRUE
	to_chat(flock.overmind, span_alert("You pull together the collective force of your Flock to transmit the Signal. If the Relay is destroyed, you're dead!"))
	ping_flock("RELAY CONSTRUCTED! DEFEND THE RELAY!!", ghosts = TRUE)
	sleep(10 SECONDS)
	priority_announce("Overwhelming anomalous power signatures detected at [get_area(src)]. This is an existential threat to the station. All personnel must contain this event.", \
	"Anomaly Alert", 'sound/misc/announce.ogg')
	set_security_level(SEC_LEVEL_GAMMA)
	START_PROCESSING(SSobj, src)

/obj/structure/destructible/flock/the_relay/Destroy()
	. = ..()
	STOP_PROCESSING(SSobj, src)
	SSshuttle.clearHostileEnvironment(src)
	var/datum/team/flock/flock = GLOB.flock
	if(!flock.winner)
		flock.die()

/obj/structure/destructible/flock/the_relay/ex_act()
	return

/obj/structure/destructible/flock/the_relay/process()
	if(conversion_radius <= 20)
		convert_turfs()
		conversion_radius++
	if(world.time > last_time_sound_played + sound_length)
		play_sound()
	if(world.time >= charge_time_length/2) // halfway point, start doing more
		if(icon_state == "structure-relay")
			icon_state = "structure-relay-glow"

		for(var/mob/M in GLOB.player_list)
			if(prob(20))
				playsound(M, pick(list('sound/effects/radio_sweep1.ogg','sound/effects/radio_sweep2.ogg','sound/effects/radio_sweep3.ogg','sound/effects/radio_sweep4.ogg','sound/effects/radio_sweep5.ogg'), 50, 1))
				if(prob(50))
					to_chat(M, span_italics("the signal will set you free"))
	if(world.time >= charge_time_length)
		unleash_the_signal()

/obj/structure/destructible/flock/the_relay/proc/play_sound()
	last_time_sound_played = world.time
	for(var/mob/M in GLOB.player_list)
		playsound(M, 'sound/ambience/Flock_Reactor.ogg', 50, 1)
		to_chat(M, span_bold("You hear something unworldly coming from the <i>[dir2text(get_dir(M, src))]</i>!"))

/obj/structure/destructible/flock/the_relay/proc/convert_turfs()
	var/list/turfs = orange(src, conversion_radius)
	for(var/turf/T as anything in turfs)
		if(!T || !istype(T))
			continue
		if(!isflockturf(T))
			T.flock_act(null)

/obj/structure/destructible/flock/the_relay/proc/unleash_the_signal()
	finished = TRUE
	STOP_PROCESSING(SSobj, src)
	desc = "Your life is flashing before your eyes. Looks like this is the end."
	SSvis_overlays.add_vis_overlay(src, icon, "structure-relay-sparks", FLOAT_LAYER, FLOAT_PLANE, dir)
	var/datum/team/flock/flock = GLOB.flock
	flock.winner = TRUE
	ping_flock("!!! TRANSMITTING SIGNAL !!!", ghosts = TRUE)
	visible_message(span_bold("[src] begins sparking wildly! The air is charged with static!"))
	for(var/mob/M in GLOB.player_list)
		playsound(M, 'sound/misc/flockmind/flock_broadcast_charge.ogg', 60, 1)
	sleep(final_charge_time_length)
	for(var/mob/M in GLOB.player_list)
		playsound(M, 'sound/misc/flockmind/flock_broadcast_kaboom.ogg', 60, 1)
		M.overlay_fullscreen("flash", /obj/screen/fullscreen/flash/static)
		M.clear_fullscreen("flash", 30)
	set_security_level(SEC_LEVEL_DELTA)
	SSshuttle.emergencyCallTime = 1800
	SSshuttle.emergency.request(null, 0.3)
	SSshuttle.emergencyNoRecall = TRUE
	flock.winner = TRUE
	explosion(src, 1, 3, 8, 8)
	sleep(2 SECONDS)
	destroy_radios()
	qdel(src)

/obj/structure/destructible/flock/the_relay/proc/destroy_radios()
	for(var/obj/item/radio/R in GLOB.radios)  //Yeah it is a global list created only to be used here, cry about it
		if(!istype(R))
			continue
		playsound(R.loc, pick(list('sound/effects/radio_sweep1.ogg','sound/effects/radio_sweep2.ogg','sound/effects/radio_sweep3.ogg','sound/effects/radio_sweep4.ogg','sound/effects/radio_sweep5.ogg'), 70, 1))
		var/mob/living/wearer = R.loc
		if(wearer && istype(wearer))
			to_chat(wearer, span_userdanger("A final scream of horrific static bursts from your radio, destroying it!"))
			if(wearer.soundbang_act(1, 20, rand(1, 5)))
				wearer.Paralyze(150)
			R.on = FALSE
			R.emp_act(EMP_HEAVY) 
			R.channels = list()
			R.secure_radio_connections = null
			R.keyslot.channels = null
			R.translate_binary = FALSE
			R.keyslot.translate_binary = FALSE
			R.independent = FALSE
			R.keyslot.independent = FALSE
			R.syndie = FALSE
			R.keyslot.syndie = FALSE
			R.canhear_range = 0