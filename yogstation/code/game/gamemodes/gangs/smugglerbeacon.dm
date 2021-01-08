/*
	Gang stashbox
	Money can be inserted into it for the gang to use
	but money cannot be taken out directly
	To withdraw money, one has to use the gangtool
	Destroying the stashbox will drop a significant
	portion of the money inside, but not all of it
*/
/obj/item/stashbox
	name = "stashbox"
	desc = "A secure stash box criminals use to hide their money."
	icon = 'icons/obj/module.dmi'
	icon_state = "depositbox"
	w_class = WEIGHT_CLASS_NORMAL
	level = 1 // Makes the item hide under floor tiles
	var/datum/bank_account/registered_account

/obj/item/stashbox/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/holochip))
		insert_money(W, user)
		return
	else if(istype(W, /obj/item/stack/spacecash))
		insert_money(W, user, TRUE)
		return
	else if(istype(W, /obj/item/coin))
		insert_money(W, user, TRUE)
		return
	else
		return ..()

/obj/item/stashbox/hide(intact)
	if(intact)
		invisibility = INVISIBILITY_OBSERVER
		anchored = TRUE //otherwise you can start pulling, cover it, and drag around an invisible backpack.
		icon_state = "[initial(icon_state)]2"
		ADD_TRAIT(src, TRAIT_T_RAY_VISIBLE, TRAIT_GENERIC)
	else
		invisibility = initial(invisibility)
		anchored = FALSE
		icon_state = initial(icon_state)
		REMOVE_TRAIT(src, TRAIT_T_RAY_VISIBLE, TRAIT_GENERIC)

/obj/item/stashbox/proc/insert_money(obj/item/I, mob/user, physical_currency)
	var/cash_money = I.get_item_credit_value()
	if(!cash_money)
		to_chat(user, "<span class='warning'>[I] doesn't seem to be worth anything!</span>")
		return

	if(!registered_account) // Shouldn't happen but lets leave it in just in case
		to_chat(user, "<span class='warning'>[src] doesn't have a linked account to deposit [I] into!</span>")
		return

	registered_account.adjust_money(cash_money)
	if(physical_currency)
		to_chat(user, "<span class='notice'>You stuff [I] into [src]. It disappears in a small puff of bluespace smoke, adding [cash_money] credits to the linked account.</span>")
	else
		to_chat(user, "<span class='notice'>You insert [I] into [src], adding [cash_money] credits to the linked account.</span>")

	to_chat(user, "<span class='notice'>The linked account now reports a balance of $[registered_account.account_balance].</span>")
	qdel(I)

/obj/item/stashbox/Destroy()
	var/cached_funds = registered_account.account_balance // Funds before we reduce
	var/refund_penalty = rand(10, 20)// Percentage to reduce by
	var/refund = round(((refund_penalty) / 100) * (cached_funds))// Ammount to refund after it has been reduced
	registered_account.adjust_money(-refund)
	var/obj/item/holochip/holochip = new (src.drop_location(), refund)
	holochip.visible_message("A holochip falls out of [src].")
	..()

/*
	Smugglers Beacon
	Floor teleport structure
	When alt-clicked, will sell off the items on top of it
	Reusing piratepad code
*/
/obj/machinery/smugglerbeacon
	name = "smugglers beacon"
	icon = 'icons/obj/telescience.dmi'
	icon_state = "lpad-idle-o"
	var/idle_state = "lpad-idle-o"
	var/warmup_state = "lpad-idle"
	var/sending_state = "lpad-beam"
	var/warmup_time = 100
	var/sending = FALSE
	var/points = 0
	var/sending_timer
	var/datum/bank_account/registered_account

/obj/machinery/smugglerbeacon/AltClick(mob/user)
	start_sending()
	
/obj/machinery/smugglerbeacon/proc/start_sending()
	if(sending)
		return
	sending = TRUE

	visible_message("<span class='notice'>[src] starts charging up.</span>")
	icon_state = warmup_state
	sending_timer = addtimer(CALLBACK(src,.proc/send),warmup_time, TIMER_STOPPABLE)

/obj/machinery/smugglerbeacon/proc/stop_sending()
	if(!sending)
		return
	sending = FALSE
	icon_state = idle_state
	deltimer(sending_timer)
	registered_account.adjust_money(points)
	reset_points()

/obj/machinery/smugglerbeacon/proc/reset_points()
	points = 0

/obj/machinery/smugglerbeacon/proc/send()
	if(!sending)
		return

	var/datum/export_report/ex = new

	for(var/atom/movable/AM in get_turf(src))
		if(AM == src)
			continue
		export_item_and_contents(AM, EXPORT_GANG | EXPORT_CARGO | EXPORT_CONTRABAND | EXPORT_EMAG, apply_elastic = FALSE, delete_unsold = FALSE, external_report = ex)

	var/value = 0
	for(var/datum/export/E in ex.total_amount)
		var/export_text = E.total_printout(ex,notes = FALSE) //Don't want nanotrasen messages, makes no sense here.
		if(!export_text)
			continue

		value += ex.total_value[E]

	points += value

	visible_message("<span class='notice'>[src] activates!</span>")
	flick(sending_state,src)
	icon_state = idle_state
	stop_sending()

/datum/export/gang
	export_category = EXPORT_GANG

/datum/export/gang/gangtool
	cost = 250
	unit_name = "gangtool"
	export_types = list(/obj/item/gangtool)

/datum/export/gang/recruitment_pen
	cost = 500
	unit_name = "recruitment pen"
	export_types = list(/obj/item/pen/gang)