/datum/quirk/jailbird
	name = "Jailbird"
	desc = "You're a ex-criminal! You start the round set to parole for a random crime."
	value = 0
	quirk_flags = QUIRK_HUMAN_ONLY | QUIRK_HIDE_FROM_SCAN
	icon = FA_ICON_CROW

/datum/quirk/jailbird/add_to_holder(mob/living/new_holder, quirk_transfer, client/client_source)
	// Don't bother adding to ghost players
	if(istype(new_holder, /mob/living/carbon/human/ghost))
		qdel(src)
		return FALSE
	return ..()

/datum/quirk/jailbird/add_unique(client/client_source)
	var/mob/living/carbon/human/jailbird = quirk_holder
	var/quirk_crime	= pick(world.file2list("monkestation/strings/random_crimes.txt"))
	to_chat(jailbird, span_boldnotice("You are on parole for the crime of: [quirk_crime]!"))
	addtimer(CALLBACK(src, PROC_REF(apply_arrest), quirk_crime), 10 SECONDS)

/datum/quirk/jailbird/proc/apply_arrest(crime_name)
	var/mob/living/carbon/human/jailbird = quirk_holder
	jailbird.mind.memories += "You have the law on your back because of your crime of: [crime_name]!"
	var/crime = "[pick(world.file2list("monkestation/strings/random_police.txt"))] [(rand(9)+1)] [pick("days", "weeks", "months", "years")] ago"
	var/perpname = jailbird.real_name
	var/datum/record/crew/jailbird_record = find_record(perpname)
	// remove quirk if we don't even have a record
	if(QDELETED(jailbird_record))
		qdel(src)
		return
	var/datum/crime/new_crime = new(name = crime_name, details = crime, author = "Nanotrasen Bounty Department")
	jailbird_record.crimes += new_crime
	jailbird_record.wanted_status = WANTED_PAROLE
	jailbird.sec_hud_set_security_status()
