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

	var/choice = input("Select a tool to emulate.","Power") as null|anything in possible_tools
	if(!choice)
		return

	if(!owner || loc != owner)
		return

	tool_behaviour = choice
	name = "psychokinetic [tool_behaviour]"
	to_chat(owner, "<span class='notice'>You begin emulating \a [tool_behaviour].</span>")
	owner.playsound_local(soundin = 'sound/effects/psi/power_fabrication.ogg')
