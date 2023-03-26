//Chameleon causes the owner to slowly become transparent when not moving.
/datum/mutation/human/chameleon
	name = "Chameleon"
	desc = "A genome that causes the holder's skin to become transparent over time."
	quality = POSITIVE
	difficulty = 16
	text_gain_indication = span_notice("You feel one with your surroundings.")
	text_lose_indication = span_notice("You feel oddly exposed.")
	time_coeff = 5
	instability = 20
	conflicts = list(/datum/mutation/human/glow, /datum/mutation/human/glow/anti)
	var/efficiency = 25

/datum/mutation/human/chameleon/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	owner.alpha = CHAMELEON_MUTATION_DEFAULT_TRANSPARENCY
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, .proc/on_move)

/datum/mutation/human/chameleon/on_life()
	if(owner.InCritical())
		owner.alpha = CHAMELEON_MUTATION_DEFAULT_TRANSPARENCY
	else
		owner.alpha = clamp(max(0, owner.alpha - efficiency), CHAMELEON_MUTATION_MINIMUM_TRANSPARENCY,CHAMELEON_MUTATION_DEFAULT_TRANSPARENCY)

/datum/mutation/human/chameleon/proc/on_move()
	owner.alpha = CHAMELEON_MUTATION_DEFAULT_TRANSPARENCY

/datum/mutation/human/chameleon/on_attack_hand(atom/target, proximity)
	if(proximity) //stops tk from breaking chameleon
		owner.alpha = CHAMELEON_MUTATION_DEFAULT_TRANSPARENCY
		return

/datum/mutation/human/chameleon/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	owner.alpha = 255
	UnregisterSignal(owner, COMSIG_MOVABLE_MOVED)

/datum/mutation/human/chameleon/super // Changeling chameleon
	conflicts = list(/datum/mutation/human/chameleon)
	allow_transfer = FALSE
	mutadone_proof = TRUE
	locked = TRUE
	efficiency = 50

/datum/mutation/human/chameleon/on_move() // Do not completely reveal us when we move
	owner.alpha = clamp(owner.alpha + efficiency, CHAMELEON_MUTATION_MINIMUM_TRANSPARENCY,CHAMELEON_MUTATION_DEFAULT_TRANSPARENCY)
