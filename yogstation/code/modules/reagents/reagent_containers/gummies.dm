/obj/item/reagent_containers/gummy
	name = "gummy bear"
	desc = "A sweet chewable gummy bear! Probably contains medicine."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "gummy"
	item_state = "gummy"
	possible_transfer_amounts = list()
	volume = 30
	grind_results = list()
	color = null
	var/apply_type = INGEST
	var/apply_method = "chew"
	var/rename_with_volume = FALSE
	var/self_delay = 1 SECONDS
	var/dissolvable = TRUE

/obj/item/reagent_containers/gummy/Initialize()
	. = ..()
	if(prob(1))
		name = "chubby gummi bear" //le player reference
		desc = "A sweet chewable gummy bear! This one isn't such a little guy!"

/obj/item/reagent_containers/gummy/on_reagent_change(changetype)
	. = ..()
	if(color == null) //only change the color IF there is no color already
		if(!reagents)
			color = "#a8a8a8"
			message_admins("[src] at [(src.loc)] was created with no reagents inside it! Please report this to a coder!")
			log_game("[src] at [src.loc] was created with no reagents inside it! Please report this to a coder!")
		if(color == null && reagents)
			color = mix_color_from_reagents(reagents.reagent_list)

/obj/item/reagent_containers/gummy/attack_self(mob/user)
	return

/obj/item/reagent_containers/gummy/attack(mob/M, mob/user, def_zone)
	if(!canconsume(M, user))
		return FALSE

	if(M == user)
		M.visible_message(span_notice("[user] attempts to [apply_method] [src]."))
		if(self_delay)
			if(!do_mob(user, M, self_delay))
				return FALSE
		to_chat(M, span_notice("You [apply_method] [src]."))

	else
		M.visible_message(span_danger("[user] attempts to force [M] to [apply_method] [src]."), \
							span_userdanger("[user] attempts to force [M] to [apply_method] [src]."))
		if(!do_mob(user, M))
			return FALSE
		M.visible_message(span_danger("[user] forces [M] to [apply_method] [src]."), \
							span_userdanger("[user] forces [M] to [apply_method] [src]."))

	if(reagents.total_volume)
		reagents.reaction(M, apply_type)
		reagents.trans_to(M, reagents.total_volume, transfered_by = user)
	qdel(src)
	return TRUE


/obj/item/reagent_containers/gummy/afterattack(obj/target, mob/user , proximity)
	. = ..()
	if(!proximity)
		return
	if(!dissolvable || !target.is_refillable())
		return
	if(target.is_drainable() && !target.reagents.total_volume)
		to_chat(user, span_warning("[target] is empty! There's nothing to dissolve [src] in."))
		return

	if(target.reagents.holder_full())
		to_chat(user, span_warning("[target] is full."))
		return

	user.visible_message(span_warning("[user] slips something into [target]!"), span_notice("You dissolve [src] in [target]."), null, 2)
	reagents.trans_to(target, reagents.total_volume, transfered_by = user)
	qdel(src)

/obj/item/reagent_containers/gummy/sleepy
	desc = "A sweet chewable gummy bear! This one tingles to hold a little."
	list_reagents = list(/datum/reagent/toxin/sodium_thiopental = 10, /datum/reagent/consumable/berryjuice = 3, /datum/reagent/consumable/sugar = 2)
	color = "#863333"

/obj/item/reagent_containers/gummy/drugs
	list_reagents = list(/datum/reagent/drug/space_drugs = 10, /datum/reagent/consumable/orangejuice = 3, /datum/reagent/consumable/sugar = 2)
	color = "#E78108"

/obj/item/reagent_containers/gummy/meth
	desc =  "A sweet chewable gummy bear! Could this one be lemon flavor?"
	list_reagents = list(/datum/reagent/drug/methamphetamine = 2, /datum/reagent/consumable/banana = 13)
	color = "#ffdf4e"

/obj/item/reagent_containers/gummy/nitro
	list_reagents = list(/datum/reagent/nitrous_oxide = 10, /datum/reagent/consumable/applejuice = 3, /datum/reagent/consumable/sugar = 2)
	color = "#20a000"

/obj/item/reagent_containers/gummy/mime
	desc =  "A sweet chewable gummy bear! Smells of sweetness and...nothing?"
	list_reagents = list(/datum/reagent/consumable/nothing = 13, /datum/reagent/consumable/sugar = 2)
	color = "#313131"

/obj/item/reagent_containers/gummy/vitamin
	desc = "You shouldn't see this! tell a coder if you do!"
	list_reagents = list(/datum/reagent/consumable/nutriment/vitamin = 15)
	color = null

/obj/item/reagent_containers/gummy/vitamin/berry
	desc = "A sweet chewable gummy bear!"
	list_reagents = list(/datum/reagent/consumable/nutriment/vitamin = 4, /datum/reagent/consumable/berryjuice = 6, /datum/reagent/consumable/sugar = 5)
	color = "#770b0b"

/obj/item/reagent_containers/gummy/vitamin/orange
	desc = "A sweet chewable gummy bear!"
	list_reagents = list(/datum/reagent/consumable/nutriment/vitamin = 4, /datum/reagent/consumable/orangejuice = 6, /datum/reagent/consumable/sugar = 5)
	color = "#E78108"

/obj/item/reagent_containers/gummy/vitamin/lime
	desc = "A sweet chewable gummy bear!"
	list_reagents = list(/datum/reagent/consumable/nutriment/vitamin = 4, /datum/reagent/consumable/limejuice = 6, /datum/reagent/consumable/sugar = 5)
	color = "#22ff00"

/obj/item/reagent_containers/gummy/vitamin/lemon
	desc = "A sweet chewable gummy bear! Is it lemon, or banana?..."
	list_reagents = list(/datum/reagent/consumable/nutriment/vitamin = 4, /datum/reagent/consumable/lemonjuice = 6, /datum/reagent/consumable/sugar = 5)
	color = "#ECFF56"

/obj/item/reagent_containers/gummy/vitamin/banana
	desc = "A sweet chewable gummy bear! Is it lemon, or banana?..."
	list_reagents = list(/datum/reagent/consumable/nutriment/vitamin = 4, /datum/reagent/consumable/banana = 11)
	color = "#fdff98"

/obj/item/reagent_containers/gummy/vitamin/apple
	desc = "A sweet chewable gummy bear!"
	list_reagents = list(/datum/reagent/consumable/nutriment/vitamin = 4, /datum/reagent/consumable/applejuice = 6, /datum/reagent/consumable/sugar = 5)
	color = "#20a000"

/obj/item/reagent_containers/gummy/vitamin/honey
	desc = "A sweet chewable gummy bear! This one smells strongly of Honey!"
	list_reagents = list(/datum/reagent/consumable/nutriment/vitamin = 4, /datum/reagent/consumable/honey = 5, /datum/reagent/water = 6)
	color = "#d3a308"

/obj/item/reagent_containers/gummy/vitamin/grape
	desc = "A sweet chewable gummy bear!"
	list_reagents = list(/datum/reagent/consumable/nutriment/vitamin = 4, /datum/reagent/consumable/grapejuice = 6, /datum/reagent/consumable/sugar = 5)
	color = "#700070"

/obj/item/reagent_containers/gummy/vitamin/watermelon
	desc = "A sweet chewable gummy bear!"
	list_reagents = list(/datum/reagent/consumable/nutriment/vitamin = 4, /datum/reagent/consumable/watermelonjuice = 6, /datum/reagent/consumable/sugar = 5)
	color = "#ff3561"

/obj/item/reagent_containers/gummy/vitamin/peach
	desc = "A sweet chewable gummy bear!"
	list_reagents = list(/datum/reagent/consumable/nutriment/vitamin = 4, /datum/reagent/consumable/peachjuice = 6, /datum/reagent/consumable/sugar = 5)
	color = "#E78108"

/obj/item/reagent_containers/gummy/vitamin/pineapple
	desc = "A sweet chewable gummy bear!"
	list_reagents = list(/datum/reagent/consumable/nutriment/vitamin = 4, /datum/reagent/consumable/pineapplejuice = 6, /datum/reagent/consumable/sugar = 5)
	color = "#F7D435"

/obj/item/reagent_containers/gummy/melatonin
	desc = "A sweet chewable gummy bear!"
	list_reagents = list(/datum/reagent/consumable/sugar = 1, /datum/reagent/consumable/berryjuice = 1, /datum/reagent/toxin/staminatoxin = 13)
	color = "#770b0b"

/obj/item/reagent_containers/gummy/omnizine
	desc = "A sweet chewable gummy bear! Smells like children's medicine"
	list_reagents = list(/datum/reagent/medicine/omnizine = 5, /datum/reagent/consumable/grapejuice = 5, /datum/reagent/consumable/sugar = 5)
	color = "#700070"

/obj/item/reagent_containers/gummy/floorbear
	name = "floorbear"
	desc = "A sweet chewable gummy bear! Looks like it's been on the ground...for a long time..."
	var/static/list/names2 = list("maintenance bear","floorbear","mystery bear","suspicious bear","strange bear")
	var/static/list/descs2 = list("Your feeling is telling you no, but...","Drugs are expensive, you can't afford not to eat any gummy bear that you find."\
	, "Surely, there's no way this could go bad.")
	color = null

/obj/item/reagent_containers/gummy/floorbear/Initialize()
	list_reagents = list(get_random_reagent_id() = 30)
	. = ..()
	name = pick(names2)
	if(prob(20))
		desc = pick(descs2)

/obj/item/reagent_containers/gummy/mindbreaker
	desc = "A sweet chewable gummy bear! Your fingers feel numb just touching it..."
	list_reagents = list(/datum/reagent/toxin/mindbreaker = 10, /datum/reagent/consumable/pwr_game = 1, /datum/reagent/consumable/sugar = 4)
	color = "#ff00aa"
