/// A component for surgery beds and those that act like them, handles patient information, success chance, and available surgeries
/datum/component/surgery_bed
	/// Modifier to the success chance of surgeries that are preformed on this, 1 is 100%
	var/success_chance = 1
	/// If this obj can pull surgeries from nearby operating computers
	var/op_computer_linkable = FALSE
	/// Extra surgeries that can be preformed on this object, even if its not researched
	var/list/extra_surgeries
	/// Linked computer for getting surgeries
	var/obj/machinery/computer/operating/computer

/datum/component/surgery_bed/Initialize(success_chance = 1, op_computer_linkable = FALSE, extra_surgeries = FALSE)
	src.success_chance = success_chance
	src.op_computer_linkable = op_computer_linkable
	src.extra_surgeries = extra_surgeries
	get_computer()

/datum/component/surgery_bed/Destroy()
	if(computer)
		computer.linked_beds -= src
	..()

/datum/component/surgery_bed/proc/link_computer(new_computer)
	if(!op_computer_linkable || istype(computer, /obj/machinery/computer/operating))
		return FALSE
	computer = new_computer
	computer.linked_beds |= src
	return computer

/datum/component/surgery_bed/proc/get_computer()
	if(!op_computer_linkable || !isobj(parent))
		return
	var/obj/bed = parent
	for(var/direction in GLOB.alldirs)
		var/obj/machinery/computer/operating/computer = locate(/obj/machinery/computer/operating) in get_step(bed, direction)
		if(!computer)
			continue
		if(link_computer(computer))
			return computer

/datum/component/surgery_bed/proc/get_patient()
	var/obj/op_table = parent
	var/mob/living/L = locate(/mob/living) in op_table.loc
	if(L && L.resting)
		return L

/datum/component/surgery_bed/proc/check_eligible_patient()
	var/mob/living/carbon/human/patient = get_patient()
	if(!patient)
		return FALSE
	if(ishuman(patient) ||  ismonkey(patient))
		return patient
	return FALSE

/datum/component/surgery_bed/proc/get_surgeries()
	var/list/surgeries = list()
	if(op_computer_linkable && computer && !(computer.stat & (NOPOWER|BROKEN)))
		surgeries |= computer.advanced_surgeries
	if(extra_surgeries)
		surgeries |= extra_surgeries
	return surgeries
