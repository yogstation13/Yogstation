/obj/item/reagent_containers/syringe
	name = "syringe"
	desc = "A syringe that can hold up to 15 units."
	icon = 'icons/obj/syringe.dmi'
	item_state = "syringe_0"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	icon_state = "0"
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = list()
	volume = 15
	var/mode = SYRINGE_DRAW
	var/busy = FALSE		// needed for delayed drawing of blood
	var/proj_piercing = 0 //does it pierce through thick clothes when shot with syringe gun
	materials = list(/datum/material/iron=10, /datum/material/glass=20)
	reagent_flags = TRANSPARENT
	sharpness = SHARP_POINTY
	embedding = list("embedded_pain_chance" = 0, "embedded_pain_multiplier" = 0, "embedded_unsafe_removal_time" = 0.25 SECONDS, "embedded_unsafe_removal_pain_multiplier" = 0, "embed_chance" = 15, "embedded_fall_chance" = 5)

/obj/item/reagent_containers/syringe/Initialize()
	. = ..()
	if(list_reagents) //syringe starts in inject mode if its already got something inside
		mode = SYRINGE_INJECT
		update_icon()

/obj/item/reagent_containers/syringe/on_reagent_change(changetype)
	update_icon()

/obj/item/reagent_containers/syringe/pickup(mob/user)
	..()
	update_icon()

/obj/item/reagent_containers/syringe/dropped(mob/user)
	..()
	update_icon()

/obj/item/reagent_containers/syringe/attack_self(mob/user)
	mode = !mode
	update_icon()

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/reagent_containers/syringe/attack_hand()
	. = ..()
	update_icon()

/obj/item/reagent_containers/syringe/attack_paw(mob/user)
	return attack_hand(user)

/obj/item/reagent_containers/syringe/attackby(obj/item/I, mob/user, params)
	return

/obj/item/reagent_containers/syringe/afterattack(atom/target, mob/user , proximity)
	. = ..()
	if(busy)
		return
	if(!proximity)
		return
	if(!target.reagents)
		return

	var/mob/living/L
	if(isliving(target))
		L = target
		if(!L.can_inject(user, 1))
			return

	SEND_SIGNAL(target, COMSIG_LIVING_TRY_SYRINGE, user)

	switch(mode)
		if(SYRINGE_DRAW)

			if(reagents.total_volume >= reagents.maximum_volume)
				to_chat(user, span_notice("The syringe is full."))
				return

			if(L) //living mob
				var/drawn_amount = reagents.maximum_volume - reagents.total_volume
				if(target != user)
					target.visible_message(span_danger("[user] is trying to take a blood sample from [target]!"), \
									span_userdanger("[user] is trying to take a blood sample from [target]!"))
					busy = TRUE
					if(!do_mob(user, target, extra_checks=CALLBACK(L, /mob/living/proc/can_inject, user, TRUE)))
						busy = FALSE
						return
					if(reagents.total_volume >= reagents.maximum_volume)
						return
				busy = FALSE
				if(L.transfer_blood_to(src, drawn_amount))
					user.visible_message("[user] takes a blood sample from [L].")
				else
					to_chat(user, span_warning("You are unable to draw any blood from [L]!"))

			else //if not mob
				if(!target.reagents.total_volume)
					to_chat(user, span_warning("[target] is empty!"))
					return

				if(!target.is_drawable(user))
					to_chat(user, span_warning("You cannot directly remove reagents from [target]!"))
					return

				var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this, transfered_by = user) // transfer from, transfer to - who cares?

				to_chat(user, span_notice("You fill [src] with [trans] units of the solution. It now contains [reagents.total_volume] units."))
			if (reagents.total_volume >= reagents.maximum_volume)
				mode=!mode
				update_icon()

		if(SYRINGE_INJECT)
			// Always log attemped injections for admins
			var/contained = reagents.log_list()
			log_combat(user, target, "attempted to inject", src, addition="which had [contained]")

			if(!reagents.total_volume)
				to_chat(user, span_notice("[src] is empty."))
				return

			if(!L && !target.is_injectable(user)) //only checks on non-living mobs, due to how can_inject() handles
				to_chat(user, span_warning("You cannot directly fill [target]!"))
				return

			if(target.reagents.total_volume >= target.reagents.maximum_volume)
				to_chat(user, span_notice("[target] is full."))
				return

			if(L) //living mob
				if(!L.can_inject(user, TRUE))
					return
				if(L != user)
					L.visible_message(span_danger("[user] is trying to inject [L]!"), \
											span_userdanger("[user] is trying to inject [L]!"))
					if(!do_mob(user, L, extra_checks=CALLBACK(L, /mob/living/proc/can_inject, user, TRUE)))
						return
					if(!reagents.total_volume)
						return
					if(L.reagents.total_volume >= L.reagents.maximum_volume)
						return
					L.visible_message("<span class='danger'>[user] injects [L] with the syringe!", \
									span_userdanger("[user] injects [L] with the syringe!"))
// yogs start - Adds viruslist stuff
				var/viruslist = ""
				for(var/datum/reagent/R in reagents.reagent_list)
					if(istype(R, /datum/reagent/blood))
						var/datum/reagent/blood/RR = R
						for(var/datum/disease/D in RR.data["viruses"])
							viruslist += " [D.name]"
							if(istype(D, /datum/disease/advance))
								var/datum/disease/advance/DD = D
								viruslist += " \[ symptoms: "
								for(var/datum/symptom/S in DD.symptoms)
									viruslist += "[S.name] "
								viruslist += "\]"

				if(viruslist)
					investigate_log("[user.real_name] ([user.ckey]) injected [L.real_name] ([L.ckey]) with [viruslist]", INVESTIGATE_VIROLOGY)
					log_game("[user.real_name] ([user.ckey]) injected [L.real_name] ([L.ckey]) with [viruslist]")
// yogs end
				if(L != user)
					log_combat(user, L, "injected", src, addition="which had [contained]")
				else
					L.log_message("injected themselves ([contained]) with [src.name]", LOG_ATTACK, color="orange")
			var/fraction = min(amount_per_transfer_from_this/reagents.total_volume, 1)
			reagents.reaction(L, INJECT, fraction)
			reagents.trans_to(target, amount_per_transfer_from_this, transfered_by = user)
			to_chat(user, span_notice("You inject [amount_per_transfer_from_this] units of the solution. The syringe now contains [reagents.total_volume] units."))
			if (reagents.total_volume <= 0 && mode==SYRINGE_INJECT)
				mode = SYRINGE_DRAW
				update_icon()


/obj/item/reagent_containers/syringe/update_icon()
	cut_overlays()
	var/rounded_vol
	if(reagents && reagents.total_volume)
		rounded_vol = clamp(round((reagents.total_volume / volume * 15),5), 1, 15)
		var/image/filling_overlay = mutable_appearance('icons/obj/reagentfillings.dmi', "syringe[rounded_vol]")
		filling_overlay.color = mix_color_from_reagents(reagents.reagent_list)
		add_overlay(filling_overlay)
	else
		rounded_vol = 0
	icon_state = "[rounded_vol]"
	item_state = "syringe_[rounded_vol]"
	if(ismob(loc))
		var/mob/M = loc
		var/injoverlay
		switch(mode)
			if (SYRINGE_DRAW)
				injoverlay = "draw"
			if (SYRINGE_INJECT)
				injoverlay = "inject"
		add_overlay(injoverlay)
		M.update_inv_hands()
	
/obj/item/reagent_containers/syringe/on_embed(mob/living/carbon/human/embedde, obj/item/bodypart/part)
	reagents.trans_to(embedde, amount_per_transfer_from_this)
	return TRUE
	
/obj/item/reagent_containers/syringe/embed_tick(embedde, part)
	reagents.trans_to(embedde, amount_per_transfer_from_this * 0.2)

/obj/item/reagent_containers/syringe/epinephrine
	name = "syringe (epinephrine)"
	desc = "Contains epinephrine - used to stabilize patients."
	list_reagents = list(/datum/reagent/medicine/epinephrine = 15)

/obj/item/reagent_containers/syringe/charcoal
	name = "syringe (charcoal)"
	desc = "Contains charcoal."
	list_reagents = list(/datum/reagent/medicine/charcoal = 15)

/obj/item/reagent_containers/syringe/perfluorodecalin
	name = "syringe (perfluorodecalin)"
	desc = "Contains perfluorodecalin."
	list_reagents = list(/datum/reagent/medicine/perfluorodecalin = 15)

/obj/item/reagent_containers/syringe/antiviral
	name = "syringe (spaceacillin)"
	desc = "Contains antiviral agents."
	list_reagents = list(/datum/reagent/medicine/spaceacillin = 15)

/obj/item/reagent_containers/syringe/bioterror
	name = "bioterror syringe"
	desc = "Contains several paralyzing reagents."
	list_reagents = list(/datum/reagent/consumable/ethanol/neurotoxin = 5, /datum/reagent/toxin/mutetoxin = 5, /datum/reagent/toxin/sodium_thiopental = 5)

/obj/item/reagent_containers/syringe/stimulants
	name = "Stimpack"
	desc = "Contains stimulants."
	amount_per_transfer_from_this = 50
	volume = 50
	list_reagents = list(/datum/reagent/medicine/stimulants = 50)

/obj/item/reagent_containers/syringe/calomel
	name = "syringe (calomel)"
	desc = "Contains calomel."
	list_reagents = list(/datum/reagent/medicine/calomel = 15)

/obj/item/reagent_containers/syringe/plasma
	name = "syringe (plasma)"
	desc = "Contains plasma."
	list_reagents = list(/datum/reagent/toxin/plasma = 15)

/obj/item/reagent_containers/syringe/lethal
	name = "lethal injection syringe"
	desc = "A syringe used for lethal injections. It can hold up to 50 units."
	amount_per_transfer_from_this = 50
	volume = 50

/obj/item/reagent_containers/syringe/lethal/choral
	list_reagents = list(/datum/reagent/toxin/chloralhydrate = 50)

/obj/item/reagent_containers/syringe/lethal/execution
	list_reagents = list(/datum/reagent/toxin/plasma = 15, /datum/reagent/toxin/formaldehyde = 15, /datum/reagent/toxin/cyanide = 10, /datum/reagent/toxin/acid/fluacid = 10)

/obj/item/reagent_containers/syringe/mulligan
	name = "Mulligan"
	desc = "A syringe used to completely change the users identity."
	amount_per_transfer_from_this = 1
	volume = 1
	list_reagents = list(/datum/reagent/mulligan = 1)

/obj/item/reagent_containers/syringe/gluttony
	name = "Gluttony's Blessing"
	desc = "A syringe recovered from a dread place. It probably isn't wise to use."
	amount_per_transfer_from_this = 1
	volume = 1
	list_reagents = list(/datum/reagent/gluttonytoxin = 1)

/obj/item/reagent_containers/syringe/ghost
	name = "Spectral Curse"
	desc = "A syringe recovered from a dreaded place. It probably isn't wise to use."
	amount_per_transfer_from_this = 1
	volume = 1
	list_reagents = list(/datum/reagent/ghosttoxin = 1)

/obj/item/reagent_containers/syringe/bluespace
	name = "bluespace syringe"
	desc = "An advanced syringe that can hold 60 units of chemicals."
	amount_per_transfer_from_this = 20
	volume = 60

/obj/item/reagent_containers/syringe/noreact
	name = "cryo syringe"
	desc = "An advanced syringe that stops reagents inside from reacting. It can hold up to 20 units."
	volume = 20
	reagent_flags = TRANSPARENT | NO_REACT

/obj/item/reagent_containers/syringe/piercing
	name = "piercing syringe"
	desc = "A diamond-tipped syringe that pierces armor when launched at high velocity. It can hold up to 10 units."
	volume = 10
	proj_piercing = 1
/obj/item/reagent_containers/syringe/crude
	name = "crude syringe"
	desc = "A crudely made syringe. The flimsy wooden construction makes it hold up minimal amounts of reagents."
	volume = 5

/obj/item/reagent_containers/syringe/spider_extract
	name = "spider extract syringe"
	desc = "Contains crikey juice - makes any gold core create the most deadly companions in the world."
	list_reagents = list(/datum/reagent/spider_extract = 1)

/obj/item/reagent_containers/syringe/dart
	name = "reagent dart"
	amount_per_transfer_from_this = 10
	embedding = list("embed_chance" = 15, "embedded_fall_chance" = 0)

/obj/item/reagent_containers/syringe/dart/temp
	item_flags = DROPDEL

/obj/item/reagent_containers/syringe/dart/temp/on_embed_removal(mob/living/carbon/human/embedde)
	qdel(src)
	