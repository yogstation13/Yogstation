/datum/symptom/mommi_shrink
	name = "Dysplasia Syndrome"
	desc = "Rapidly restructures the body of the infected, causing them to shrink in size."
	badness = EFFECT_DANGER_FLAVOR
	stage = 2
	var/activated = 0

/datum/symptom/mommi_shrink/activate(mob/living/mob)
	if(activated)
		return
	to_chat(mob, "<span class = 'warning'>You feel small...</span>")
	mob.transform.Scale(0.5, 0.5)
	mob.update_transform()
	mob.pass_flags |= PASSTABLE

	activated = 1

/datum/symptom/mommi_shrink/deactivate(mob/living/mob)
	to_chat(mob, "<span class = 'warning'>You feel like an adult again.</span>")
	mob.transform.Scale(2, 2)
	mob.update_transform()
	mob.pass_flags &= ~PASSTABLE
	activated = 0
