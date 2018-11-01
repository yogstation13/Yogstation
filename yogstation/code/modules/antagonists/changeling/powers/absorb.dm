/obj/effect/proc_holder/changeling/absorbDNA
	var/absorbtimer

/obj/effect/proc_holder/changeling/absorbDNA/sting_action(mob/user)
	var/datum/antagonist/changeling/changeling = user.mind.has_antag_datum(/datum/antagonist/changeling)
	absorbtimer = (16 - changeling.trueabsorbs) * 10 //the more people you eat, the faster you can absorb
	if(absorbtimer < 50)
		absorbtimer = 50 //lowest you can get it is 5 seconds
	.=..()