/obj/item/reagent_containers/blood
	name = "blood pack"
	desc = "Contains blood used for transfusion. Must be attached to an IV drip."
	icon = 'icons/obj/bloodpack.dmi'
	icon_state = "bloodpack"
	volume = 200
	var/datum/blood_type/blood_type = null
	var/unique_blood = null
	var/labelled = FALSE

#define BLOODBAG_GULP_SIZE 10

/obj/item/reagent_containers/blood/attack(mob/target, mob/user, def_zone)
	if(!reagents.total_volume)
		user.balloon_alert(user, "empty!")
		return ..()
	
	// needed because of how the calculation works on reagents/proc/reaction, 
	// might change in the future so change this!
	var/fraction = min(BLOODBAG_GULP_SIZE/reagents.total_volume, 1)

	if(target != user)
		if(!do_after(user, 5 SECONDS, target))
			return
		user.visible_message(
			span_notice("[user] forces [target] to drink from the [src]."),
			span_notice("You put the [src] up to [target]'s mouth."),
		)
		reagents.reaction(user, INGEST, fraction)
		reagents.trans_to(user, BLOODBAG_GULP_SIZE, transfered_by = user)
		playsound(user.loc, 'sound/items/drink.ogg', rand(10, 50), TRUE)
		return TRUE

	while(do_after(user, 1 SECONDS, src, timed_action_flags = IGNORE_USER_LOC_CHANGE))
		if(!reagents.total_volume)
			user.balloon_alert(user, "empty!")
			return ..()

		user.visible_message(
			span_notice("[user] puts the [src] up to their mouth."),
			span_notice("You take a sip from the [src]."),
		)
		if(is_vampire(user))
			var/datum/antagonist/vampire/V = user.mind.has_antag_datum(/datum/antagonist/vampire)
			V.usable_blood += BLOODBAG_GULP_SIZE / 4 //they should really be drinking from people, yknow, be antagonistic?

		reagents.reaction(user, INGEST, fraction)
		reagents.trans_to(user, BLOODBAG_GULP_SIZE, transfered_by = user)
		playsound(user.loc, 'sound/items/drink.ogg', rand(10, 50), TRUE)
	return TRUE

#undef BLOODBAG_GULP_SIZE

///Bloodbag of Bloodsucker blood (used by Vassals only)
/obj/item/reagent_containers/blood/o_minus/bloodsucker
	name = "blood pack"
	unique_blood = /datum/reagent/blood/bloodsucker

/obj/item/reagent_containers/blood/o_minus/bloodsucker/examine(mob/user)
	. = ..()
	if(user.mind.has_antag_datum(/datum/antagonist/ex_vassal) || user.mind.has_antag_datum(/datum/antagonist/vassal/revenge))
		. += span_notice("Seems to be just about the same color as your Master's...")


/obj/item/reagent_containers/blood/Initialize(mapload)
	. = ..()
	if(blood_type != null)
		if(!istype(blood_type, /datum/blood_type) && get_blood_type(blood_type))
			blood_type = get_blood_type(blood_type)
		reagents.add_reagent(unique_blood ? unique_blood : /datum/reagent/blood, 200, list("donor"=null,"viruses"=null,"blood_DNA"=null,"blood_type"=blood_type,"resistances"=null,"trace_chem"=null))
		update_appearance(UPDATE_ICON)

/obj/item/reagent_containers/blood/on_reagent_change(changetype)
	if(reagents)
		var/datum/reagent/blood/B = reagents.has_reagent(/datum/reagent/blood)
		if(B && B.data && B.data["blood_type"])
			blood_type = B.data["blood_type"]
		else if(reagents.has_reagent(/datum/reagent/consumable/liquidelectricity))
			blood_type = "E"
		else
			blood_type = null
	update_appearance(UPDATE_ICON | UPDATE_NAME)

/obj/item/reagent_containers/blood/update_name()
	. = ..()
	if(labelled)
		return
	name = "blood pack[blood_type ? " - [unique_blood ? blood_type : blood_type.name]" : ""]"

/obj/item/reagent_containers/blood/update_overlays()
	. = ..()

	var/v = min(round(reagents.total_volume / volume * 10), 10)
	if(v > 0)
		var/mutable_appearance/filling = mutable_appearance('icons/obj/reagentfillings.dmi', "bloodpack1")
		filling.icon_state = "bloodpack[v]"
		filling.color = mix_color_from_reagents(reagents.reagent_list)
		. += filling

/obj/item/reagent_containers/blood/random
	icon_state = "random_bloodpack"

/obj/item/reagent_containers/blood/random/Initialize(mapload)
	icon_state = "bloodpack"
	blood_type = pick("A+", "A-", "B+", "B-", "O+", "O-", "L")
	return ..()

/obj/item/reagent_containers/blood/APlus
	blood_type = "A+"

/obj/item/reagent_containers/blood/AMinus
	blood_type = "A-"

/obj/item/reagent_containers/blood/BPlus
	blood_type = "B+"

/obj/item/reagent_containers/blood/BMinus
	blood_type = "B-"

/obj/item/reagent_containers/blood/OPlus
	blood_type = "O+"

/obj/item/reagent_containers/blood/OMinus
	blood_type = "O-"

/obj/item/reagent_containers/blood/lizard
	blood_type = "L"

/obj/item/reagent_containers/blood/ethereal
	blood_type = "E"
	unique_blood = /datum/reagent/consumable/liquidelectricity

/obj/item/reagent_containers/blood/universal
	blood_type = "U"

/obj/item/reagent_containers/blood/gorilla
	blood_type = "G"

/obj/item/reagent_containers/blood/attackby(obj/item/I, mob/user, params)
	if (istype(I, /obj/item/pen) || istype(I, /obj/item/toy/crayon))
		if(!user.is_literate())
			to_chat(user, span_notice("You scribble illegibly on the label of [src]!"))
			return
		var/t = stripped_input(user, "What would you like to label the blood pack?", name, null, 53)
		if(!user.canUseTopic(src, BE_CLOSE))
			return
		if(user.get_active_held_item() != I)
			return
		if(t)
			labelled = TRUE
			name = "blood pack - [t]"
		else
			labelled = FALSE
			update_appearance(UPDATE_NAME)
	else
		return ..()
