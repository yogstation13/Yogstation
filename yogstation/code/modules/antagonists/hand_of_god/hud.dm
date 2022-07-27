/datum/atom_hud/antag/hog
	var/color = null

/datum/atom_hud/antag/hog/add_to_hud(atom/A)
	if(!A)
		return
	var/image/holder = A.hud_list[ANTAG_HUD]
	if(holder)
		holder.color = color
	..()

/datum/atom_hud/antag/hog/remove_from_hud(atom/A)
	if(!A)
		return
	var/image/holder = A.hud_list[ANTAG_HUD]
	if(holder)
		holder.color = null
	..()

/datum/atom_hud/antag/hog/join_hud(mob/M)
	if(!istype(M))
		CRASH("join_hud(): [M] ([M.type]) is not a mob!")
	var/image/holder = M.hud_list[ANTAG_HUD]
	if(holder)
		holder.color = color
	..()

/datum/atom_hud/antag/hog/leave_hud(mob/M)
	if(!istype(M))
		CRASH("leave_hud(): [M] ([M.type]) is not a mob!")
	var/image/holder = M.hud_list[ANTAG_HUD]
	if(holder)
		holder.color = null
	..()


//////////////////////////////////////////////////////////////////////

/datum/antagonist/hog/proc/update_hud()
	var/datum/hud/human/hud = owner.current.hud_used
	hud.mana_display.update_counter(energy, "#F0F8FF")
	hud.cult_energy_display.update_counter(cult.energy, "#E6E6FA")
	if(cult.cult_objective)
		hud.objective_status_display.update_counter(cult.cult_objective.progress_text())
	else
		hud.objective_status_display.update_counter("You didn't get assigned an objective yet.")

/datum/antagonist/hog/proc/remove_hud()
	var/datum/hud/human/hud = owner.current.hud_used
	hud.mana_display.invisibility = INVISIBILITY_ABSTRACT
	hud.cult_energy_display.invisibility = INVISIBILITY_ABSTRACT
	hud.objective_status_display.invisibility = INVISIBILITY_ABSTRACT

/datum/antagonist/hog/god/update_hud()
	var/datum/hud/human/hud = owner.current.hud_used
	hud.cult_energy_display.update_counter(cult.energy, "#E6E6FA")
	if(cult.cult_objective)
		hud.objective_status_display.update_counter(cult.cult_objective.progress_text())
	else
		hud.objective_status_display.update_counter("Your cult didn't get assigned an objective yet.")


/obj/screen/hand_of_god/energy/update_counter(value, valuecolor)
	..()
	maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='[valuecolor]'>[round(value,1)]</font></div>"

/obj/screen/hand_of_god/cult_energy/update_counter(value, valuecolor)
	..()
	maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='[valuecolor]'>[round(value,1)]</font></div>"

/obj/screen/hand_of_god/objective_stat/MouseEntered(location, control, params)
	. = ..()
	openToolTip(usr, src, params, title = name, content = desc)

/obj/screen/hand_of_god/objective_stat/MouseExited(location, control, params)
	closeToolTip(usr)

/obj/screen/hand_of_god/objective_stat/update_counter(text)
	..()
	desc = text