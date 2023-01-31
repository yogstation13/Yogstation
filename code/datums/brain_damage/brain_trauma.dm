//Brain Traumas are the new actual brain damage. Brain damage itself acts as a way to acquire traumas: every time brain damage is dealt, there's a chance of receiving a trauma.
//This chance gets higher the higher the mob's brainloss is. Removing traumas is a separate thing from removing brain damage: you can get restored to full brain operativity,
// but keep the quirks, until repaired by neurine, surgery, lobotomy or magic; depending on the resilience
// of the trauma.

/datum/brain_trauma
	var/name = "Brain Trauma"
	var/desc = "A trauma caused by brain damage, which causes issues to the patient."
	var/scan_desc = "generic brain trauma" //description when detected by a health scanner
	var/mob/living/carbon/owner //the poor bastard
	var/obj/item/organ/brain/brain //the poor bastard's brain
	var/gain_text = span_notice("You feel traumatized.")
	var/lose_text = span_notice("You no longer feel traumatized.")
	var/can_gain = TRUE
	var/random_gain = TRUE //can this be gained through random traumas?
	var/resilience = TRAUMA_RESILIENCE_BASIC //how hard is this to cure?
	var/clonable = TRUE // will this transfer if the brain is cloned?
	// Therapy
	var/random_cure_chance = 0 // This will be multiplied by a random amount; more resilient traumas should have less chance
	var/flash_therapy_cd_time = 5 MINUTES // Flashing the patient, most effective method
	COOLDOWN_DECLARE(flash_therapy_cd)
	var/laser_therapy_cd_time = 8 MINUTES // Shining a laser into the patient's eyes, second most effective
	COOLDOWN_DECLARE(laser_therapy_cd)
	var/pen_therapy_cd_time = 3 MINUTES // Shining a light (usually penlight) into the patient's eyes, third most effective
	COOLDOWN_DECLARE(pen_therapy_cd)
	var/hug_therapy_cd_time = 1 MINUTES // Hugging the patient, lowest chance method but easiest. Hugs!
	COOLDOWN_DECLARE(hug_therapy_cd)

/datum/brain_trauma/Destroy()
	if(brain && brain.traumas)
		brain.traumas -= src
	if(owner)
		on_lose()
	brain = null
	owner = null
	return ..()

/datum/brain_trauma/proc/on_clone()
	if(clonable)
		return new type

//Called on life ticks
/datum/brain_trauma/proc/on_life()
	return

//Called on death
/datum/brain_trauma/proc/on_death()
	return

//Called when given to a mob
/datum/brain_trauma/proc/on_gain()
	to_chat(owner, gain_text)
	RegisterSignal(owner, COMSIG_MOB_SAY, .proc/handle_speech)
	RegisterSignal(owner, COMSIG_MOVABLE_HEAR, .proc/handle_hearing)
	random_cure_chance *= rand(6, 15) / 10 // 0.6-1.5x

//Called when removed from a mob
/datum/brain_trauma/proc/on_lose(silent)
	if(!silent)
		to_chat(owner, lose_text)
	UnregisterSignal(owner, COMSIG_MOB_SAY)
	UnregisterSignal(owner, COMSIG_MOVABLE_HEAR)

//Called when hearing a spoken message
/datum/brain_trauma/proc/handle_hearing(datum/source, list/hearing_args)
	UnregisterSignal(owner, COMSIG_MOVABLE_HEAR)

//Called when speaking
/datum/brain_trauma/proc/handle_speech(datum/source, list/speech_args)
	UnregisterSignal(owner, COMSIG_MOB_SAY)


//Called when hugging. expand into generally interacting, where future coders could switch the intent?
/datum/brain_trauma/proc/on_hug(mob/living/hugger, mob/living/hugged)
	if(!COOLDOWN_FINISHED(src, hug_therapy_cd))
		return
	COOLDOWN_START(src, hug_therapy_cd, hug_therapy_cd_time)
	var/cure_chance = random_cure_chance / 6
	if(HAS_TRAIT(hugger.mind, TRAIT_PSYCH))
		cure_chance *= 3.5
	if(HAS_TRAIT(hugger, TRAIT_FRIENDLY))
		cure_chance *= 1.25
	if(prob(cure_chance))
		qdel(src) // Sometimes, all you need is a good hug..

/datum/brain_trauma/proc/on_flash(mob/living/flasher, mob/living/flashed)
	if(!COOLDOWN_FINISHED(src, flash_therapy_cd))
		return
	COOLDOWN_START(src, flash_therapy_cd, flash_therapy_cd_time)
	var/cure_chance = random_cure_chance / 10
	if(HAS_TRAIT(flasher.mind, TRAIT_PSYCH)) // Non-practitioners are bad at this
		cure_chance *= 10
	if(prob(cure_chance))
		qdel(src)

/datum/brain_trauma/proc/on_shine_laser(mob/living/laserer, mob/living/lasered)
	if(!COOLDOWN_FINISHED(src, laser_therapy_cd))
		return
	COOLDOWN_START(src, laser_therapy_cd, laser_therapy_cd_time)
	var/cure_chance = random_cure_chance / 11
	if(HAS_TRAIT(laserer.mind, TRAIT_PSYCH)) // Non-practitioners are bad at this
		cure_chance *= 10
	if(prob(cure_chance))
		qdel(src)

/datum/brain_trauma/proc/on_shine_light(mob/living/shiner, mob/living/shined, /obj/item/flashlight/the_light)
	if(!COOLDOWN_FINISHED(src, pen_therapy_cd))
		return
	COOLDOWN_START(src, pen_therapy_cd, pen_therapy_cd_time)
	var/cure_chance = random_cure_chance / 15
	if(istype(the_light, /obj/item/flashlight/pen)) // Use a proper penlight!
		cure_chance *= 1.5
	if(HAS_TRAIT(shiner.mind, TRAIT_PSYCH)) // Non-practitioners are bad at this
		cure_chance *= 10
	if(prob(cure_chance))
		qdel(src)
