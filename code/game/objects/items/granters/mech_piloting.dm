//for upstart mech pilots to move faster
/obj/item/book/granter/mechpiloting
	name = "Mech Piloting for Dummies"
	desc = "A step-by-step guide on how to effectively pilot a mech, written in such a way that even a clown could understand."
	remarks = list(
		"Hmm, press forward to go forwards...", 
		"Avoid getting hit to reduce damage...", 
		"Welding to repair..?", 
		"Make sure to turn it on...", 
		"EMP bad...", 
		"I need to turn internals on?", 
		"What's a gun ham?"
	)

/obj/item/book/granter/mechpiloting/on_reading_finished(mob/user)
	. = ..()
	user.AddComponent(/datum/component/mech_pilot, 0.8)
