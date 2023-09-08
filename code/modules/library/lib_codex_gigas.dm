#define PRE_TITLE 1
#define TITLE 2
#define SYLLABLE 3
#define MULTIPLE_SYLLABLE 4
#define SUFFIX 5

/obj/item/book/codex_gigas
	name = "\improper Codex Gigas"
	desc = "A book documenting the nature of devils."
	icon_state ="demonomicon"
	lefthand_file = 'icons/mob/inhands/misc/books_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/books_righthand.dmi'
	throw_speed = 1
	throw_range = 10
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	author = "Forces beyond your comprehension"
	unique = TRUE
	title = "the Codex Gigas"

	///List of all minds that were already discovered as agents, so you can't find the same person twice.
	var/list/datum/mind/found_minds = list()

	///A crewmember's record paper inserted into the document.
	///Necessary to discover Infernal Agents and reverse engineering who the Devil is.
	var/obj/item/paper/record/inserted_record

	///The mind of a person we're looking into.
	///Necessary to discover Infernal Agents and reverse engineer who the Devil is.
	var/datum/mind/stored_mind

/obj/item/book/codex_gigas/Destroy()
	. = ..()
	QDEL_NULL(inserted_record)
	found_minds = null
	stored_mind = null

/obj/item/book/codex_gigas/examine(mob/user)
	. = ..()
	if(HAS_TRAIT(user, TRAIT_DEVIL_CONTRACT_IMMUNE))
		if(inserted_record)
			. += span_notice("It has a record in it, you can Alt Click it to remove it.")
		else
			. += span_notice("You can insert someone's personal records to store them inside.")
		. += span_notice("You can also use this on a person to keep track of them for comparing.")
		. += span_notice("Once you have both, of the same person, you may compare them to see if they are an Infernal Affairs Agent.")

/obj/item/book/codex_gigas/attackby(obj/item/tool, mob/user, params)
	if(istype(tool, /obj/item/paper/record))
		if(inserted_record)
			user.balloon_alert(user, "record already inside!")
			return
		tool.forceMove(src)
		inserted_record = tool
		user.balloon_alert(user, "record inserted")
		return
	return ..()

/obj/item/book/codex_gigas/AltClick(mob/user)
	. = ..()
	if(inserted_record)
		user.balloon_alert(user, "record removed")
		user.put_in_hands(inserted_record)
		inserted_record = null

/obj/item/book/codex_gigas/afterattack(mob/living/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag)
		return
	if(!user.can_read(src) || (target == user) || !ismob(target))
		return
	if(!HAS_TRAIT(user, TRAIT_DEVIL_CONTRACT_IMMUNE))
		return
	user.balloon_alert(user, "taking notes...")
	if(!do_after(user, 10 SECONDS, target))
		user.balloon_alert(user, "interrupted!")
		return
	stored_mind = target.mind

/obj/item/book/codex_gigas/attack_self(mob/living/user)
	if(!HAS_TRAIT(user, TRAIT_DEVIL_CONTRACT_IMMUNE))
		to_chat(user, span_alert("The book is an unreadable mess..."))
		return
	if(!inserted_record)
		user.balloon_alert(user, "no records inserted!")
		return
	var/datum/mind/stored_record_mind = inserted_record.record_of_ref?.resolve()
	if(!stored_record_mind)
		user.balloon_alert(user, "no records inserted!")
		return
	if(!stored_mind)
		user.balloon_alert(user, "no person to compare!")
		return
	if(stored_mind in found_minds)
		user.balloon_alert(user, "person already scanned")
		return
	user.balloon_alert(user, "comparing notes...")
	if(!do_after(user, 10 SECONDS, src))
		user.balloon_alert(user, "unable to compare notes")
		return
	if(stored_record_mind != stored_mind)
		user.balloon_alert(user, "notes differ from person!")
		return
	var/datum/antagonist/infernal_affairs/infernal_datum = stored_mind.has_antag_datum(/datum/antagonist/infernal_affairs)
	if(!infernal_datum)
		to_chat(user, span_alert("They are unrelated to your research, thus your search continues..."))
		return
	found_minds += stored_mind
	to_chat(user, span_alert("Infernal Affairs agent found! [infernal_datum.owner.current] has sold their soul off to the Devil! \
		The Devil, aware that you know this, likely has already done something about it..."))
	infernal_datum.remove_uplink()
	to_chat(infernal_datum.owner.current, span_alert("You've been discovered! Your uplink has been revoked for your crimes against the Devil!"))
