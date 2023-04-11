#define SOUND_BEEP_1 add_queue('sound/voice/nerdsuit/beep_1.ogg',20)
#define SOUND_BEEP_2 add_queue('sound/voice/nerdsuit/beep_2.ogg',20)
#define SOUND_BEEP_3 add_queue('sound/voice/nerdsuit/beep_3.ogg',20)

/obj/item/clothing/suit/armor/nerd
	name = "\improper D.O.T.A. suit"
	desc = "The Defenseless Operator Traversal Assistance suit is a highly experimental NanoTrasen designed protective full body harness designed to prolong the lifespan (and thus productivity) of an employee via surplus medical technology found in the abandoned part of maintenance no one seems to want to talk about. Unfortunately the research department couldn't design a helmet before the third quarter so this is definitely not spaceproof. One size fits most."
	mob_overlay_icon = 'yogstation/icons/mob/clothing/suit/suit.dmi'
	icon = 'yogstation/icons/obj/clothing/suits.dmi'
	icon_state = "nerd"
	item_state = "nerd"
	blood_overlay_type = "suit"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	armor = list(MELEE = 25, BULLET = 25, LASER = 25, ENERGY = 25, BOMB = 0, BIO = 100, RAD = 100, FIRE = 50, ACID = 50)
	allowed = list(/obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman, /obj/item/gun/energy/kinetic_accelerator, /obj/item/tank/internals/ipc_coolant, /obj/item/crowbar)

	var/list/funny_signals = list(
		COMSIG_MOB_SAY = .proc/handle_speech,
		COMSIG_MOB_DEATH = .proc/handle_death,
		COMSIG_LIVING_IGNITED = .proc/handle_ignite,
		COMSIG_LIVING_ELECTROCUTE_ACT = .proc/handle_shock,
		COMSIG_CARBON_GAIN_WOUND = .proc/handle_wound_add,
		COMSIG_MOB_APPLY_DAMAGE = .proc/handle_damage
	)

	var/static/list/wound_to_sound = list(
		/datum/wound/blunt/severe = 'sound/voice/nerdsuit/minor_fracture.ogg',
		/datum/wound/blunt/critical = 'sound/voice/nerdsuit/major_fracture.ogg',
		/datum/wound/loss = 'sound/voice/nerdsuit/major_lacerations.ogg',
		/datum/wound/slash/severe = 'sound/voice/nerdsuit/minor_lacerations.ogg',
		/datum/wound/slash/critical = 'sound/voice/nerdsuit/major_lacerations.ogg',
	)

	var/list/sound_queue = list()

	var/morphine_delay = 30 SECONDS
	var/emag_doses_left = 5

	var/mob/living/carbon/owner

	var/emagged = FALSE

	body_parts_covered = CHEST|GROIN|ARMS|LEGS|FEET
	flags_inv = HIDESHOES|HIDEJUMPSUIT|HIDEGLOVES

	var/obj/item/geiger_counter/GC

	COOLDOWN_DECLARE(next_damage_notify)
	COOLDOWN_DECLARE(next_morphine)

/obj/item/clothing/suit/armor/nerd/Initialize()
	. = ..()
	GC = new(src)
	GC.scanning = TRUE
	update_icon()

/obj/item/clothing/suit/armor/nerd/Destroy()
	QDEL_NULL(GC)
	. = ..()

/obj/item/clothing/suit/armor/nerd/proc/process_sound_queue()

	var/list/sound_data = sound_queue[1]
	var/sound_file = sound_data[1]
	var/sound_delay = sound_data[2]

	playsound(src, sound_file, 50)

	sound_queue.Cut(1,2)

	if(!length(sound_queue))
		return

	addtimer(CALLBACK(src, .proc/process_sound_queue), sound_delay)

/obj/item/clothing/suit/armor/nerd/emag_act(mob/user)

	if(owner)
		to_chat(owner, span_warning("You need to take off \the [src.name] before emagging it."))
		return FALSE //Take it off!

	if(emagged == FALSE)
		emagged = TRUE
		do_sparks(8, FALSE, get_turf(src))
		return TRUE
	return FALSE

/obj/item/clothing/suit/armor/nerd/proc/add_queue(var/desired_file,var/desired_delay,var/purge_queue=FALSE)

	var/was_empty_sound_queue = !length(sound_queue)

	if(purge_queue)
		sound_queue.Cut()

	sound_queue += list(list(desired_file,desired_delay)) //BYOND is fucking weird so you have to do this bullshit if you want to add a list to a list.

	if(was_empty_sound_queue)
		addtimer(CALLBACK(src, .proc/process_sound_queue), 1 SECONDS)

	return TRUE

//Signal handling.
/obj/item/clothing/suit/armor/nerd/equipped(mob/M, slot)
	. = ..()
	if(slot == SLOT_WEAR_SUIT && iscarbon(M))
		for(var/k in funny_signals)
			RegisterSignal(M, k, funny_signals[k])
		add_queue('sound/voice/nerdsuit/bell.ogg',2 SECONDS,purge_queue=TRUE)
		owner = M
		if(prob(1))
			add_queue('sound/voice/nerdsuit/emag.ogg',27 SECONDS)
		else
			add_queue('sound/voice/nerdsuit/welcome.ogg',8 SECONDS)
	else
		for(var/k in funny_signals)
			UnregisterSignal(M, k)

/obj/item/clothing/suit/armor/nerd/dropped(mob/M)
	. = ..()
	for(var/k in funny_signals)
		UnregisterSignal(M, k)

//Death
/obj/item/clothing/suit/armor/nerd/proc/handle_death(gibbed)

	SIGNAL_HANDLER

	add_queue('sound/voice/nerdsuit/death.ogg',5 SECONDS,purge_queue=TRUE)

//Mute
/obj/item/clothing/suit/armor/nerd/proc/handle_speech(datum/source, mob/speech_args)

	SIGNAL_HANDLER

	if(!emagged)
		var/list/cancel_messages = list(
			"You find it difficult to talk with the suit crushing your voicebox...",
			"Your voicebox feels crushed with this suit on, making vocalization impossible...",
			"You try to talk, but the suit restricts your throat..."
		)

		speech_args[SPEECH_MESSAGE] = ""

		to_chat(source, span_warning(pick(cancel_messages)))

//Fire
/obj/item/clothing/suit/armor/nerd/proc/handle_ignite(mob/living)

	SIGNAL_HANDLER

	SOUND_BEEP_3
	add_queue('sound/voice/nerdsuit/heat.ogg',3 SECONDS)

//Shock
/obj/item/clothing/suit/armor/nerd/proc/handle_shock(mob/living)

	SIGNAL_HANDLER

	SOUND_BEEP_3
	add_queue('sound/voice/nerdsuit/shock.ogg',3 SECONDS)

//Wounds
/obj/item/clothing/suit/armor/nerd/proc/handle_wound_add(mob/living/carbon/C, datum/wound/W, obj/item/bodypart/L)

	SIGNAL_HANDLER

	var/found_sound = wound_to_sound[W.type]
	if(found_sound)
		SOUND_BEEP_3
		add_queue(found_sound,4 SECONDS)

	if(W.severity >= WOUND_SEVERITY_MODERATE)
		SOUND_BEEP_3
		add_queue('sound/voice/nerdsuit/seek_medical.ogg',2 SECONDS)
		administer_morphine()

/obj/item/clothing/suit/armor/nerd/proc/administer_morphine()

	SIGNAL_HANDLER

	if(!owner.reagents)
		return

	if(!COOLDOWN_FINISHED(src,next_morphine))
		return

	if(emagged && emag_doses_left > 0)
		owner.reagents.add_reagent(/datum/reagent/medicine/stimulants, 5)
		SOUND_BEEP_3
		add_queue('sound/voice/nerdsuit/stimulants.ogg',2 SECONDS)
		emag_doses_left--
		if(emag_doses_left <= 0)
			to_chat(owner, span_warning("\The [src.name] seems to have run out of stimulants..."))
	else
		owner.reagents.add_reagent(/datum/reagent/medicine/morphine, 3)
		SOUND_BEEP_3
		add_queue('sound/voice/nerdsuit/morphine.ogg',2 SECONDS)

	COOLDOWN_START(src,next_morphine,morphine_delay)

	return TRUE

//General Damage
/obj/item/clothing/suit/armor/nerd/proc/handle_damage(mob/living/carbon/C, damage, damagetype, def_zone)

	SIGNAL_HANDLER

	if(!COOLDOWN_FINISHED(src,next_damage_notify))
		return

	if(damage < 5 || owner.maxHealth <= 0)
		return

	var/health_percent = owner.health/owner.maxHealth

	if(health_percent > 0.50 && !prob(damage*4))
		return

	if(health_percent <= 0.25)
		SOUND_BEEP_3
		add_queue('sound/voice/nerdsuit/vital_signs_death.ogg',3 SECONDS)
		COOLDOWN_START(src,next_damage_notify,5 SECONDS)
		administer_morphine()
	else if(health_percent <= 0.50)
		SOUND_BEEP_3
		add_queue('sound/voice/nerdsuit/vital_signs_critical.ogg',3 SECONDS)
		COOLDOWN_START(src,next_damage_notify,5 SECONDS)
	else if(health_percent <= 0.75)
		SOUND_BEEP_2
		add_queue('sound/voice/nerdsuit/vital_signs_dropping.ogg',2 SECONDS)
		COOLDOWN_START(src,next_damage_notify,5 SECONDS)

#undef SOUND_BEEP_1
#undef SOUND_BEEP_2
#undef SOUND_BEEP_3
