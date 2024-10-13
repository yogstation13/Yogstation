/*/datum/symptom/dnaspread //commented out due to causing enough problems to turn random people into monkies apon curing.
	name = "Retrotransposis"
	desc = "This symptom transplants the genetic code of the intial vector into new hosts."
	badness = EFFECT_DANGER_HARMFUL
	stage = 4
	var/datum/dna/saved_dna
	var/original_name
	var/activated = 0
	///old info
	var/datum/dna/old_dna
	var/old_name

/datum/symptom/dnaspread/activate(mob/living/carbon/mob)
	if(!activated)
		to_chat(mob, span_warning("You don't feel like yourself.."))
		old_dna = new
		C.dna.copy_dna(old_dna)
		old_name = C.real_name

	if(!iscarbon(mob))
		return
	var/mob/living/carbon/C = mob
	if(!saved_dna)
		saved_dna = new
		original_name = C.real_name
		C.dna.copy_dna(saved_dna)
	C.regenerate_icons()
	saved_dna.copy_dna(C.dna)
	C.real_name = original_name
	activated = TRUE

/datum/symptom/dnaspread/deactivate(mob/living/carbon/mob)
	activated = FALSE
	if(!old_dna)
		return
	old_dna.copy_dna(C.dna)
	C.real_name = old_name

/datum/symptom/dnaspread/Copy(datum/disease/advanced/disease)
	var/datum/symptom/dnaspread/new_e = ..(disease)
	new_e.original_name = original_name
	new_e.saved_dna = saved_dna
	return new_e
*/
