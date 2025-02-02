
/datum/action/cooldown/spell/build_hive
	name = "Build Hive Home"
	desc = "You construct a once home for you and your bee people."
	button_icon = 'icons/obj/hydroponics/equipment.dmi'
	button_icon_state = "beebox"

	cooldown_time = 5 MINUTES
	spell_requirements = NONE
//MONKESTATION EDIT : Reducing the cooldown from 25 to 10 minutes.
// The time was extremely long before, almost twice as the time to **make** a hive. This is healthier, equating to double of the time of the beehive.

	var/obj/structure/beebox/hive/created_hive

/datum/action/cooldown/spell/build_hive/can_cast_spell(feedback = TRUE)
	. = ..()
	if(created_hive)
		return FALSE

/datum/action/cooldown/spell/build_hive/cast(mob/living/carbon/human/user = usr)
	. = ..()
	if(is_species(user, /datum/species/apid))
		var/datum/species/apid/apid = user.dna.species
		if(apid.stored_honey < 70)
			to_chat(user, span_notice("Not enough stored honey"))
			addtimer(CALLBACK(src, PROC_REF(reset_spell_cooldown)), 2 SECONDS)
			return

	if(!do_after(user, 10 SECONDS, get_turf(user)))
		addtimer(CALLBACK(src, PROC_REF(reset_spell_cooldown)), 2 SECONDS)
		return

	if(is_species(user, /datum/species/apid))
		var/datum/species/apid/apid = user.dna.species
		if(apid.stored_honey < 70)
			addtimer(CALLBACK(src, PROC_REF(reset_spell_cooldown)), 2 SECONDS)
			return

		apid.adjust_honeycount(-70)
		created_hive = new(get_turf(user), user.real_name)
		apid.owned_hive = created_hive
		created_hive.current_stat = apid.current_stat
		//MONKESTATION EDIT : Changed the total requirement from 15 minutes to a reasonable 7.
		//The amount of time investment this required only incentivized an isolated style of gameplay, this should be healthier and incentivize the use of beehives earlier for interactions with crewmembers.

	RegisterSignals(created_hive, list(COMSIG_QDELETING, COMSIG_PREQDELETED), PROC_REF(remove_hive))

/datum/action/cooldown/spell/build_hive/proc/remove_hive()
	UnregisterSignal(created_hive, list(COMSIG_QDELETING, COMSIG_PREQDELETED))
	created_hive = null
	var/mob/living/carbon/human/user = owner
	if(is_species(user, /datum/species/apid))
		var/datum/species/apid/apid = user.dna.species
		apid.owned_hive = null
