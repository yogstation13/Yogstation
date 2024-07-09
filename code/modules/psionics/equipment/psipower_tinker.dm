/obj/item/psychic_power/tinker
	name = "psychokinetic crowbar"
	icon_state = "tinker"
	force = 0
	tool_behaviour = TOOL_CROWBAR
	usesound = 'sound/weapons/etherealhit.ogg'
	var/list/possible_tools

/obj/item/psychic_power/tinker/attack_self()

	if(!owner || loc != owner)
		return

	var/list/choice_list = LAZYCOPY(possible_tools)
	for(var/I as anything in choice_list)
		choice_list[I] = image(icon, null, I)
	var/choice = show_radial_menu(owner, owner, choice_list)

	if(!choice)
		return

	if(!owner || loc != owner)
		return

	tool_behaviour = choice
	name = "psychokinetic [tool_behaviour]"
	icon_state = "[tool_behaviour]"
	update_icon()
	to_chat(owner, "<span class='notice'>You begin emulating \a [tool_behaviour].</span>")
	owner.playsound_local(soundin = 'sound/effects/psi/power_fabrication.ogg')
