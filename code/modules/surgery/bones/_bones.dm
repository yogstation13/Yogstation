#define NO_FRACTURE 0
#define HAIRLINE_FRACTURE 1
#define FRACTURE 2
#define COMPOUND_FRACTURE 3
///1 bodypart health = X bone health
#define BODYPART_TO_BONE_RATIO 1
///How much damages does a splint remove per Life()?
#define SPLINT_HEALING_POWER 2
///At what damage does our fractures heal?
#define FRACTURE_HEALING_CUTOFF 10
///How much damage to apply when we move, multiplied by severity
#define MOVING_DAMAGE 0.2


/datum/bones
	name = "bone??"

	var/obj/item/bodypart/bodypart
	var/damage = 0

	var/damage_severity = NO_FRACTURE
	//What's our max damage? Set by our bodypart on initialize
	var/baseline_health = 10

	var/splinted = FALSE

/datum/bone/Destroy()
	bodypart.bone = null

/datum/bone/proc/apply_damage(amount)
	damage += amount
	damage = clamp(damage, baseline_health, 0)
	handle_damage()

/datum/bone/proc/handle_damage()
	if(damage_severity = COMPOUND_FRACTURE)
		return
	//Compound at 80%
	if(damage >= 0.8*baseline_health && damage_severity < COMPOUND_FRACTURE)
		damage_severity = COMPOUND_FRACTURE
		to_chat(bodypart.owner, "<span class='danger'>You feel something breaking in your [bodypart], and then a sudden rush of pain!</span>")
		playsound(src, "sound/effects/footstep/bang.ogg", 70, 1)
		bodypart.update_disabled()
		return

	//Fracture at 60%
	if(damage >= 0.6*baseline_health && damage_severity < FRACTURE)
		to_chat(bodypart.owner, "<span class='danger'>You feel an immense pain in your [bodypart]!</span>")
		damage_severity = FRACTURE
		return

	//Hairline at 40%
	if(damage >= 0.4*baseline_health && damage_severity < HAIRLINE_FRACTURE)
		to_chat(bodypart.owner, "<span class='danger'>Something feels cracked in your [bodypart]!</span>")
		damage_severity = HAIRLINE_FRACTURE
		return


//Return true if we do or heal damage TO THE BODYPART
/datum/bone/proc/process()
	. = FALSE
	if(splinted)
		damage = max(damage - SPLINT_HEALING_POWER, 0)
		if(damage <= 0)
			to_chat(bodypart.owner, "<span class='warning'>Your [bodypart] feels better! The splint seems to have fallen off.</span>")
			splinted = FALSE

	if(damage_severity != COMPOUND_FRACTURE && damage_severity != NO_FRACTURE)
		if(damage <= FRACTURE_HEALING_CUTOFF)
			damage_severity = NO_FRACTURE
			to_chat(bodypart.owner, "<span class='notice'>Your [bodypart] feels better.</span>")

	if(damage_severity != NO_FRACTURE)
		switch(damage_severity)
			if(HAIRLINE_FRACTURE)


			if(FRACTURE)
				if(prob(5))
					bodypart.receive_damage(5)
					bodypart.owner.emote("scream")
					to_chat(bodypart.owner, "<span class='warning'>You scream in pain! Your [bodypart] hurts so bad!</span>")

					if(bodypart.held_index)
						bodypart.owner.dropItemToGround(bodypart.owner.get_item_for_held_index(bodypart.held_index))

			if(COMPOUND_FRACTURE)
				if(prob(5))
					bodypart.receive_damage(10)
					bodypart.owner.Dizzy(30)
					bodypart.owner.emote("scream")
					to_chat(bodypart.owner, "<span class='danger'>Your [bodypart] hurts so bad that you'd rather die!</span>")
				if(prob(15))
					bodypart.owner.bleed(5)

/datum/bone/proc/HandleMove()
	if(damage_severity == NO_FRACTURE)
		return
	if(prob(5))
		to_chat(bodypart.owner, "<span class='warning'>Moving your [bodypart] really hurts!</span>")
	apply_damage(MOVING_DAMAGE * damage_severity)