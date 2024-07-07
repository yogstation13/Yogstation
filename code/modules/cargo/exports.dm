/* How it works:
 The shuttle arrives at CentCom dock and calls sell(), which recursively loops through all the shuttle contents that are unanchored.

 Each object in the loop is checked for applies_to() of various export datums, except the invalid ones.
*/

/* The rule in figuring out item export cost:
 Export cost of goods in the shipping crate must be always equal or lower than:
  packcage cost - crate cost - manifest cost
 Crate cost is 500cr for a regular plasteel crate and 100cr for a large wooden one. Manifest cost is always 200cr.
 This is to avoid easy cargo points dupes.

Credit dupes that require a lot of manual work shouldn't be removed, unless they yield too much profit for too little work.
 For example, if some player buys metal and glass sheets and uses them to make and sell reinforced glass:

 100 glass + 50 metal -> 100 reinforced glass
 (1500cr -> 1600cr)

 then the player gets the profit from selling his own wasted time.
*/

#define NO_LIMIT INFINITY

// Simple holder datum to pass export results around
/datum/export_report
	var/list/exported_atoms = list()	//names of atoms sold/deleted by export
	var/list/total_amount = list()		//export instance => total count of sold objects of its type, only exists if any were sold
	var/list/total_value = list()		//export instance => total value of sold objects

// external_report works as "transaction" object, pass same one in if you're doing more than one export in single go
/proc/export_item_and_contents(atom/movable/AM, allowed_categories = EXPORT_CARGO, apply_limit = TRUE, delete_unsold = TRUE, dry_run=FALSE, datum/export_report/external_report)
	if(!GLOB.exports_list.len)
		setupExports()

	var/list/contents = AM.get_all_contents()

	var/datum/export_report/report = external_report
	if(!report) //If we don't have any longer transaction going on
		report = new

	// We go backwards, so it'll be innermost objects sold first
	for(var/i in reverse_range(contents))
		var/atom/movable/thing = i
		var/obj/item/thingy = thing
		var/sold = FALSE
		if(QDELETED(thing))
			continue
		if(!(istype(thingy) && thingy.item_flags & AUTOLATHED))
			for(var/datum/export/E in GLOB.exports_list)
				if(!E)
					continue
				if(E.applies_to(thing, allowed_categories, apply_limit))
					sold = E.sell_object(thing, report, dry_run, allowed_categories , apply_limit)
					report.exported_atoms += " [thing.name]"
					break
		if(!dry_run && (sold || delete_unsold))
			if(isliving(thing))
				thing.investigate_log("trafficked via cargo export",INVESTIGATE_CARGO)
				INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(handleTrafficking), thing)
			else
				qdel(thing)

	return report


// They're off to holding - handle the return timer and give some text about what's going on.
/proc/handleTrafficking(mob/living/M)
	//get rid of them for the time being
	var/turf/holding_turf = pick(GLOB.holdingfacility)
	M.forceMove(holding_turf)
	
	var/list/victim_belongings = list()

	if (iscarbon(M))
		for(var/obj/item/W in M)
			if (ishuman(M))
				var/mob/living/carbon/human/H = M
				if(W == H.w_uniform)
					continue //So all they're left with are shoes and uniform.
				if(W == H.shoes)
					continue
				if(H.implants && (W in H.implants))
					continue

			M.transferItemToLoc(W)
			victim_belongings.Add(W)

	// Ship 'em back - dead or alive, 4 minutes wait.
	// Even if they weren't the target, we're still treating them the same.
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(returnTrafficked), M, victim_belongings), (4 MINUTES))

	if (M.stat != DEAD)
		// Heal them up - gets them out of crit/soft crit. If omnizine is removed in the future, this needs to be replaced with a
		// method of healing them, consequence free, to a reasonable amount of health.
		M.reagents.add_reagent(/datum/reagent/medicine/omnizine, 20)

		M.flash_act()
		M.adjust_confusion(10 SECONDS)
		M.adjust_eye_blur(0.5 SECONDS)
		to_chat(M, span_warning("You feel strange..."))
		sleep(6 SECONDS)
		to_chat(M, span_warning("That pod did something to you..."))
		M.adjust_dizzy(3.5 SECONDS)
		sleep(6.5 SECONDS)
		to_chat(M, span_warning("Your head pounds... It feels like it's going to burst out your skull!"))
		M.flash_act()
		M.adjust_confusion(20 SECONDS)
		M.adjust_eye_blur(3)
		sleep(3 SECONDS)
		to_chat(M, span_warning("Your head pounds..."))
		sleep(10 SECONDS)
		M.flash_act()
		M.Unconscious(20 SECONDS)
		to_chat(M, "<span class='reallybig hypnophrase'>A million voices echo in your head... <i>\"Your mind held many valuable secrets - \
					we thank you for providing them. Your value is expended, and you will be ransomed back to your station. We always get paid, \
					so it's only a matter of time before we ship you back...\"</i></span>")

		var/ransom = 100 * rand(18, 45) //people are pretty cheap
		var/points_to_check
		var/datum/bank_account/D = SSeconomy.get_dep_account(ACCOUNT_CAR)
		if(D)
			points_to_check = D.account_balance
		if(points_to_check >= ransom)
			D.adjust_money(-ransom)
		else
			D.adjust_money(-points_to_check)
		priority_announce("One of your crew was captured by a rival organisation - we've needed to pay their ransom to bring them back. \
						As is policy we've taken a portion of the station's funds to offset the overall cost.", null, null, null, "Nanotrasen Asset Protection")

		M.adjust_eye_blur(1 SECONDS)
		M.adjust_dizzy(1.5 SECONDS)
		M.adjust_confusion(20 SECONDS)

// We're returning the victim
/proc/returnTrafficked(mob/living/M, list/victim_belongings)

	var/turf/pod_rand_loc = get_safe_random_station_turf()
	if (pod_rand_loc)

		var/obj/structure/closet/supplypod/return_pod = new()
		return_pod.bluespace = TRUE
		return_pod.explosionSize = list(0,0,0,0)
		return_pod.style = STYLE_SYNDICATE

		do_sparks(8, FALSE, M)
		M.visible_message(span_notice("[M] vanishes..."))

		for(var/obj/item/W in M)
			if (ishuman(M))
				var/mob/living/carbon/human/H = M
				if(W == H.w_uniform)
					continue //So all they're left with are shoes and uniform.
				if(W == H.shoes)
					continue
				if(H.implants && (W in H.implants))
					continue
			M.dropItemToGround(W)

		for(var/obj/item/W in victim_belongings)
			W.forceMove(return_pod)

		M.forceMove(return_pod)

		M.flash_act()
		M.adjust_eye_blur(30)
		M.adjust_dizzy(35 SECONDS)
		M.adjust_confusion(20 SECONDS)

		new /obj/effect/DPtarget(pod_rand_loc, return_pod)
	else
		to_chat(M, "<span class='reallybig hypnophrase'>A million voices echo in your head... <i>\"Seems where you got sent here from won't \
					be able to handle our pod... You will die here instead.\"</i></span>")
		if (iscarbon(M))
			var/mob/living/carbon/C = M
			if (C.can_heartattack())
				C.set_heartattack(TRUE)

/datum/export
	var/unit_name = ""				// Unit name. Only used in "Received [total_amount] [name]s [message]." message
	var/message = ""
	var/cost = 100					// Cost of item, in cargo credits. Must not alow for infinite price dupes, see above.
	var/export_limit = NO_LIMIT		//how many times this export can be sold.
	var/list/export_types = list()	// Type of the exported object. If none, the export datum is considered base type.
	var/include_subtypes = TRUE		// Set to FALSE to make the datum apply only to a strict type.
	var/list/exclude_types = list()	// Types excluded from export

	//All these need to be present in export call parameter for this to apply.
	var/export_category = EXPORT_CARGO

/datum/export/New()
	..()
	export_types = typecacheof(export_types)
	exclude_types = typecacheof(exclude_types)

/datum/export/Destroy()
	SSprocessing.processing -= src
	return ..()

// Checks the cost. 0 cost items are skipped in export.
/datum/export/proc/get_cost(obj/O, allowed_categories = NONE, apply_limit = TRUE)
	var/amount = get_amount(O)
	if(apply_limit && export_limit != NO_LIMIT)
		return clamp(amount, 0, export_limit) * cost
	else
		return round(cost * amount)

// Checks the amount of exportable in object. Credits in the bill, sheets in the stack, etc.
// Usually acts as a multiplier for a cost, so item that has 0 amount will be skipped in export.
/datum/export/proc/get_amount(obj/O)
	return 1

// Checks if the item is fit for export datum.
/datum/export/proc/applies_to(obj/O, allowed_categories = NONE, apply_elastic = TRUE)
	if((allowed_categories & export_category) != export_category)
		return FALSE
	if(!include_subtypes && !(O.type in export_types))
		return FALSE
	if(include_subtypes && (!is_type_in_typecache(O, export_types) || is_type_in_typecache(O, exclude_types)))
		return FALSE
	if(!get_cost(O, allowed_categories , apply_elastic))
		return FALSE
	if(O.flags_1 & HOLOGRAM_1)
		return FALSE
	return TRUE

// Called only once, when the object is actually sold by the datum.
// Adds item's cost and amount to the current export cycle.
// get_cost, get_amount and applies_to do not neccesary mean a successful sale.
/datum/export/proc/sell_object(obj/O, datum/export_report/report, dry_run = TRUE, allowed_categories = EXPORT_CARGO , apply_limit = TRUE)
	var/the_cost = get_cost(O, allowed_categories , apply_limit)
	var/amount = get_amount(O)

	if(amount <=0 || the_cost <=0  || export_limit <=0)
		return FALSE

	report.total_value[src] += the_cost

	if(istype(src, /datum/export/material))
		report.total_amount[src] += amount*MINERAL_MATERIAL_AMOUNT
	else
		report.total_amount[src] += amount

	if(!dry_run)
		if(apply_limit && export_limit != NO_LIMIT)
			export_limit-= amount
		SSblackbox.record_feedback("nested tally", "export_sold_cost", 1, list("[O.type]", "[the_cost]"))
	return TRUE

// Total printout for the cargo console.
// Called before the end of current export cycle.
// It must always return something if the datum adds or removes any credts.
/datum/export/proc/total_printout(datum/export_report/ex, notes = TRUE)
	if(!ex.total_amount[src] || !ex.total_value[src])
		return ""

	var/total_value = ex.total_value[src]
	var/total_amount = ex.total_amount[src]

	var/msg = "[total_value] credits: Received [total_amount] "
	if(total_value > 0)
		msg = "+" + msg

	if(unit_name)
		msg += unit_name
		if(total_amount > 1)
			msg += "s"
		if(message)
			msg += " "

	if(message)
		msg += message

	msg += "."

	if(export_limit <= 0)
		msg += " No further units are required."
	return msg

GLOBAL_LIST_EMPTY(exports_list)

/proc/setupExports()
	for(var/subtype in subtypesof(/datum/export))
		var/datum/export/E = new subtype
		if(E.export_types && E.export_types.len) // Exports without a type are invalid/base types
			GLOB.exports_list += E
