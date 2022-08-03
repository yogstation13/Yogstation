/obj/structure/destructible/flock/the_relay
	name = "titanic polyhedron"
	desc = "The sight of the towering geodesic sphere fills you with dread. A thousand voices whisper to you."
	flock_id = "Signal Relay Broadcast Amplifier"
	flock_desc = "Your goal and purpose. Defend it until it can broadcast The Signal."
	max_integrity = 600
	var/conversion_radius = 1
	var/last_time_sound_played_in_seconds = 0
	var/sound_length_in_seconds = 27
	var/charge_time_length = 6 MINUTES
	var/final_charge_time_length = 18
	var/finished = FALSE
	var/col_r = 0.1
	var/col_g = 0.7
	var/col_b = 0.6
	var/datum/light/light
	var/brightness = 0.5
	var/shuttle_departure_delayed = FALSE

/obj/structure/destructible/flock/the_relay/Initialize()
	. = ..()
    SSshuttle.registerHostileEnvironment(src)
    var/datum/team/flock/flock = GLOB.flock
    to_chat(flock.overmind, span_alert("You pull together the collective force of your Flock to transmit the Signal. If the Relay is destroyed, you're dead!"))
    ping_flock("RELAY CONSTRUCTED! DEFEND THE RELAY!!", ghosts = TRUE)
    sleep(10 SECONDS)
	priority_announce("Overwhelming anomalous power signatures detected at [get_area(src)]. This is an existential threat to the station. All personnel must contain this event.", \
	"Anomaly Alert", 'sound/magic/clockwork/ark_activation.ogg')
    set_security_level(SEC_LEVEL_GAMMA)