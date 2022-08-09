/datum/antagonist/paramount
	name = "Paramount"
	roundend_category = "paramounts"
	antagpanel_category = "Paramount"
	job_rank = ROLE_PARAMOUNT
	antag_moodlet = /datum/mood_event/focused

/datum/antagonist/paramount/on_gain()
	var/mob/living/carbon/human/H = owner?.current
	if(!istype(H))
		return

	H.set_psi_rank(PSI_REDACTION, 3,     defer_update = TRUE)
	H.set_psi_rank(PSI_COERCION, 3,      defer_update = TRUE)
	H.set_psi_rank(PSI_PSYCHOKINESIS, 3, defer_update = TRUE)
	H.set_psi_rank(PSI_ENERGISTICS, 3,   defer_update = TRUE)
	H.psi.update(TRUE)

	H.equipOutfit(/datum/outfit/paramount)
	addObjectives()
	. = ..()
/* Somehow trying to add this broke every single vent in the game so ???
	hud_add()

/datum/antagonist/paramount/on_removal()
	. = ..()
	hud_remove()

/datum/antagonist/paramount/proc/hud_add()
	var/datum/atom_hud/antag/hud = GLOB.huds[ANTAG_HUD_PARAMOUNT]
	hud.join_hud(owner.current)
	set_antag_hud(owner.current, "paramount")

/datum/antagonist/paramount/proc/hud_remove()
	var/datum/atom_hud/antag/hud = GLOB.huds[ANTAG_HUD_PARAMOUNT]
	hud.leave_hud(owner.current)
	set_antag_hud(owner.current, null)
*/
/datum/antagonist/paramount/proc/addObjectives()
	switch(rand(1,100))
		if(1 to 30)
			var/datum/objective/assassinate/kill_objective = new
			kill_objective.owner = owner
			kill_objective.find_target()
			objectives += kill_objective

			if (!(locate(/datum/objective/escape) in objectives))
				var/datum/objective/escape/escape_objective = new
				escape_objective.owner = owner
				objectives += escape_objective

		if(31 to 60)
			var/datum/objective/steal/steal_objective = new
			steal_objective.owner = owner
			steal_objective.find_target()
			objectives += steal_objective

			if (!(locate(/datum/objective/escape) in objectives))
				var/datum/objective/escape/escape_objective = new
				escape_objective.owner = owner
				objectives += escape_objective

		if(61 to 85)
			var/datum/objective/assassinate/kill_objective = new
			kill_objective.owner = owner
			kill_objective.find_target()
			objectives += kill_objective

			var/datum/objective/steal/steal_objective = new
			steal_objective.owner = owner
			steal_objective.find_target()
			objectives += steal_objective

			if (!(locate(/datum/objective/survive) in objectives))
				var/datum/objective/survive/survive_objective = new
				survive_objective.owner = owner
				objectives += survive_objective

		else
			if (!(locate(/datum/objective/hijack) in objectives))
				var/datum/objective/hijack/hijack_objective = new
				hijack_objective.owner = owner
				objectives += hijack_objective

/datum/antagonist/paramount/greet()
	to_chat(owner, span_boldannounce("You are the Paramount!"))
	to_chat(owner, "You were once one of the finest minds of your culture, now driven to madness by the whispers of the howling dark and blessed with psychic faculties that defy understanding.")
	to_chat(owner, "Using your C-E rig and your twisted knowledge of psionics, advance your agenda in human space by doing the following tasks:")
	owner.announce_objectives()
	to_chat(owner,"<B>Remember:</B> do not forget to prepare your psi amp.")

/datum/outfit/paramount
	name = "Paramount"
	uniform = /obj/item/clothing/under/color/lightpurple
	suit = /obj/item/clothing/suit/wizrobe/fake
	glasses = /obj/item/clothing/glasses/regular
	head = /obj/item/clothing/head/helmet/space/psi_amp/paramount
	shoes = /obj/item/clothing/shoes/sneakers/black
	ears = /obj/item/radio/headset
