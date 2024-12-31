/datum/quirk/stable_ass
	name = "Stable Rear"
	desc = "Your rear is far more robust than average, falling off less often than usual."
	value = 2
	medical_record_text = "Patient's buttocks have above-average resilience."
	icon = FA_ICON_FACE_SAD_CRY
	//All effects are handled directly in butts.dm

/datum/quirk/loud_ass
	name = "Loud Ass"
	desc = "For some ungodly reason, your ass is twice as loud as normal."
	value = 2
	medical_record_text = "Patient's buttocks have a tendency to loudly clap as they walk."
	icon = FA_ICON_VOLUME_HIGH
	//All effects are handled directly in butts.dm

/datum/quirk/dummy_thick
	name = "Dummy Thicc"
	desc = "Hm...Colonel, I'm trying to sneak around, but I'm dummy thicc and the clap of my ass cheeks keep alerting the guards..."
	value = 3	//Why are we still here? Just to suffer?
	medical_record_text = "Patient is dummy thicc."
	icon = FA_ICON_VOLUME_UP

/datum/quirk/dummy_thick/add()
	RegisterSignal(quirk_holder, COMSIG_MOVABLE_MOVED, PROC_REF(on_mob_move))
	var/obj/item/organ/internal/butt/booty = quirk_holder.get_organ_by_type(/obj/item/organ/internal/butt)
	var/matrix/thick = new
	thick.Scale(1.5)
	animate(booty, transform = thick, time = 0.1 SECONDS)

/datum/quirk/dummy_thick/remove()
	UnregisterSignal(quirk_holder, COMSIG_MOVABLE_MOVED)
	var/obj/item/organ/internal/butt/booty = quirk_holder.get_organ_by_type(/obj/item/organ/internal/butt)
	if(booty)
		var/matrix/thick = new
		thick.Scale(1 / 1.5)
		animate(booty, transform = thick, time = 0.1 SECONDS)

/datum/quirk/dummy_thick/proc/on_mob_move()
	SIGNAL_HANDLER
	if(prob(33))
		playsound(quirk_holder, "monkestation/sound/misc/clap_short.ogg", vol = 70, vary = TRUE, extrarange = 5, ignore_walls = TRUE)
