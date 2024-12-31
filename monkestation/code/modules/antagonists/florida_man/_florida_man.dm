/datum/antagonist/florida_man
	name = "Space Florida Man"
	roundend_category = "Florida Men"
	antagpanel_category = "Florida Man"
	job_rank = ROLE_FLORIDA_MAN
	hud_icon = 'monkestation/icons/mob/huds/antag_hud.dmi'
	antag_hud_name = "usa"
	objectives = list()
	show_to_ghosts = TRUE
	preview_outfit = /datum/outfit/florida_man_one
	var/datum/action/cooldown/spell/florida_doorbuster/doorbuster
	var/datum/action/cooldown/spell/florida_cuff_break/cuff_break
	var/datum/action/cooldown/spell/florida_regeneration/regen
	var/datum/martial_art/wrestling/wrassling
	var/static/list/florida_traits = list(
		TRAIT_CLUMSY,
		TRAIT_DUMB,
		TRAIT_STABLELIVER,
		TRAIT_STABLEHEART,
		TRAIT_TOXIMMUNE,
		TRAIT_JAILBIRD,
		TRAIT_IGNORESLOWDOWN,
		TRAIT_VENTCRAWLER_NUDE,
		TRAIT_ABATES_SHOCK,
		TRAIT_ANALGESIA,
		TRAIT_NO_PAIN_EFFECTS,
		TRAIT_NO_SHOCK_BUILDUP,
	)

/datum/antagonist/florida_man/on_gain()
	forge_objectives()
	return ..()

/datum/antagonist/florida_man/on_removal()
	wrassling?.remove(owner.current)
	QDEL_NULL(wrassling)
	QDEL_NULL(doorbuster)
	QDEL_NULL(cuff_break)
	QDEL_NULL(regen)
	return ..()

/datum/antagonist/florida_man/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/carbon/human/floridan = mob_override || owner.current
	if(!ishuman(floridan))
		return
	floridan.add_traits(florida_traits, type)
	floridan.physiology?.stun_mod *= 0.25
	if(QDELETED(doorbuster))
		doorbuster = new
	if(QDELETED(cuff_break))
		cuff_break = new
	if(QDELETED(regen))
		regen = new
	doorbuster.Grant(floridan)
	cuff_break.Grant(floridan)
	regen.Grant(floridan)

	if(QDELETED(wrassling))
		wrassling = new
	wrassling.teach(floridan)

/datum/antagonist/florida_man/remove_innate_effects(mob/living/mob_override)
	. = ..()
	QDEL_NULL(doorbuster)
	QDEL_NULL(cuff_break)
	QDEL_NULL(regen)
	var/mob/living/carbon/human/floridan = mob_override || owner.current
	wrassling?.remove(floridan)
	if(ishuman(floridan))
		floridan.remove_traits(florida_traits, type)
		floridan.physiology?.stun_mod /= 0.25

/datum/antagonist/florida_man/forge_objectives()
	var/datum/objective/meth = new /datum/objective
	var/list/selected_objective = pick(GLOB.florida_man_base_objectives)

	meth.owner = owner
	if(prob(25))
		meth.explanation_text = "[selected_objective[1]] [pick(GLOB.florida_man_objective_nouns)] [selected_objective[2]], [pick(GLOB.florida_man_objective_suffix)]"
	else
		meth.explanation_text = "[selected_objective[1]] [pick(GLOB.florida_man_objective_nouns)] [selected_objective[2]]."
	objectives += meth

/datum/antagonist/florida_man/greet()
	var/mob/living/carbon/floridan = owner.current
	randomize_human(floridan)

	owner.current.playsound_local(get_turf(owner.current), 'monkestation/sound/ambience/antag/floridaman.ogg',100,0, use_reverb = FALSE)
	to_chat(owner, span_boldannounce("You are THE Florida Man!\nYou're not quite sure how you got out here in space, but you don't generally bother thinking about things.\n\nYou love methamphetamine!\nYou love wrestling lizards!\nYou love getting drunk!\nYou love sticking it to THE MAN!\nYou don't act with any coherent plan or objective.\nYou don't outright want to destroy the station or murder people, as you have no home to return to.\n\nGo forth, son of Space Florida, and sow chaos!"))
	owner.announce_objectives()
	random_unique_name(PLURAL, floridan)
	if(prob(1)) // 1% chance to be Tony Brony...because meme references to streams are good!
		floridan.fully_replace_character_name(newname = "Tony Brony")

/datum/antagonist/florida_man/antag_token(datum/mind/hosts_mind, mob/spender)
	if(isobserver(spender))
		var/mob/living/carbon/human/new_mob = spender.change_mob_type(/mob/living/carbon/human, delete_old_mob = TRUE)
		new_mob.equipOutfit(/datum/outfit/florida_man_three)
		new_mob.mind.add_antag_datum(/datum/antagonist/florida_man)
	else
		hosts_mind.add_antag_datum(/datum/antagonist/florida_man)
