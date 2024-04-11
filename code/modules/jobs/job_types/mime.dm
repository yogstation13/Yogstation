/datum/job/mime
	title = "Mime"
	description = "..."
	orbit_icon = "comment-slash"
	department_head = list("Head of Personnel")
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the head of personnel"

	outfit = /datum/outfit/job/mime

	alt_titles = list("Mute Entertainer", "Silent Jokester", "Pantomimist")

	added_access = list()
	base_access = list(ACCESS_THEATRE, ACCESS_SERVHALL)
	paycheck = PAYCHECK_MINIMAL
	paycheck_department = ACCOUNT_SRV

	display_order = JOB_DISPLAY_ORDER_MIME
	minimal_character_age = 18 //Mime?? Might increase this a LOT depending on how mime lore turns out

	departments_list = list(
		/datum/job_department/service,
	)

	mail_goodies = list(
		/obj/item/reagent_containers/food/snacks/baguette = 15,
		/obj/item/reagent_containers/food/snacks/store/cheesewheel/brie = 10,
		/obj/item/reagent_containers/food/drinks/bottle/bottleofnothing = 10,
		/obj/item/book/mimery = 1,
	)

	minimal_lightup_areas = list(/area/crew_quarters/theatre)

	smells_like = "complete nothingness"

/datum/job/mime/after_spawn(mob/living/carbon/human/H, mob/M)
	. = ..()
	H.apply_pref_name(/datum/preference/name/mime, M.client)

/datum/outfit/job/mime
	name = "Mime"
	jobtype = /datum/job/mime

	pda_type = /obj/item/modular_computer/tablet/pda/preset/mime

	ears = /obj/item/radio/headset/headset_srv
	uniform = /obj/item/clothing/under/rank/mime
	uniform_skirt = /obj/item/clothing/under/rank/mime/skirt
	mask = /obj/item/clothing/mask/gas/mime
	gloves = /obj/item/clothing/gloves/color/white
	head = /obj/item/clothing/head/frenchberet
	suit = /obj/item/clothing/suit/suspenders
	backpack_contents = list(
	/obj/item/book/mimery=1,
	/obj/item/reagent_containers/food/drinks/bottle/bottleofnothing=1,
	/obj/item/stamp/mime = 1)
	box = /obj/item/storage/box/survival/hug/black
	backpack = /obj/item/storage/backpack/mime
	satchel = /obj/item/storage/backpack/mime

	chameleon_extras = /obj/item/stamp/mime


/datum/outfit/job/mime/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()

	if(visualsOnly)
		return

	H.grant_language(/datum/language/french, TRUE, TRUE, LANGUAGE_MIME)
	if(H.mind)
		var/datum/action/cooldown/spell/vow_of_silence/vow = new(H.mind)
		vow.Grant(H)
		H.mind.miming = 1

/obj/item/book/mimery
	name = "Guide to Dank Mimery"
	desc = "A primer on basic pantomime."
	icon_state ="bookmime"

/obj/item/book/mimery/attack_self(mob/user,)
	. = ..()
	if(.)
		return

	var/list/spell_icons = list(
		"Invisible Wall" = image(icon = 'icons/mob/actions/actions_mime.dmi', icon_state = "invisible_wall"),
		"Invisible Chair" = image(icon = 'icons/mob/actions/actions_mime.dmi', icon_state = "invisible_chair"),
		"Invisible Box" = image(icon = 'icons/mob/actions/actions_mime.dmi', icon_state = "invisible_box"),
		"Invisible Touch" = image(icon = 'icons/mob/actions/actions_mime.dmi', icon_state = "invisible_touch")
		)
	var/picked_spell = show_radial_menu(user, src, spell_icons, custom_check = CALLBACK(src, PROC_REF(check_menu), user), radius = 36, require_near = TRUE)
	var/datum/action/cooldown/spell/picked_spell_type
	switch(picked_spell)
		if("Invisible Wall")
			picked_spell_type = /datum/action/cooldown/spell/conjure/invisible_wall

		if("Invisible Chair")
			picked_spell_type = /datum/action/cooldown/spell/conjure/invisible_chair

		if("Invisible Box")
			picked_spell_type = /datum/action/cooldown/spell/conjure_item/invisible_box

		if("Invisible Touch")
			picked_spell_type = /datum/action/cooldown/spell/touch/invisible_touch

	if(ispath(picked_spell_type))
		// Gives the user a vow ability too, if they don't already have one
		var/datum/action/cooldown/spell/vow_of_silence/vow = locate() in user.actions
		if(!vow && user.mind)
			vow = new(user.mind)
			vow.Grant(user)

		picked_spell_type = new picked_spell_type(user.mind || user)
		picked_spell_type.Grant(user)

		to_chat(user, span_warning("The book disappears into thin air."))
		qdel(src)

	return TRUE

/**
 * Checks if we are allowed to interact with a radial menu
 *
 * Arguments:
 * * user The human mob interacting with the menu
 */
/obj/item/book/mimery/proc/check_menu(mob/living/carbon/human/user)
	if(!istype(user))
		return FALSE
	if(!user.is_holding(src))
		return FALSE
	if(user.incapacitated())
		return FALSE
	if(!user.mind)
		return FALSE
	return TRUE
