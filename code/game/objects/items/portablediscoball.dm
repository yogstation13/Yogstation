/obj/item/discoballdeployer
	name = "Portable Disco Ball"
	desc = "Press the button to start the PARTY!!"
	icon = 'icons/obj/device.dmi'
	icon_state = "ethdisco"

/obj/item/discoballdeployer/attack_self(mob/living/carbon/user)
	.=..()
	to_chat(user, span_notice("You deploy the Disco Ball."))
	new /obj/structure/discoball(user.loc)
	qdel(src)

/obj/structure/discoball
	name = "Portable Disco Ball"
	desc = "A small portable disco ball for a small party."
	icon = 'icons/obj/device.dmi'
	icon_state = "ethdisco_head_0"
	anchored = TRUE
	density = TRUE
	var/TurnedOn = FALSE
	var/current_color
	var/TimerID
	var/range = 7
	var/power = 3

/obj/structure/discoball/Initialize()
	. = ..()
	update_icon()

/obj/structure/discoball/attack_hand(mob/living/carbon/human/user)
	. = ..()
	if(TurnedOn)
		TurnOff()
		to_chat(user, span_notice("You turn the disco ball off!"))
	else
		TurnOn()
		to_chat(user, span_notice("You turn the disco ball on!"))

/obj/structure/discoball/AltClick(mob/living/carbon/human/user)
	. = ..()
	if(anchored)
		to_chat(user, span_notice("You unlock the disco ball."))
		anchored = FALSE
	else
		to_chat(user, span_notice("You lock the disco ball."))
		anchored = TRUE

/obj/structure/discoball/proc/TurnOn()
	TurnedOn = TRUE //Same
	DiscoFever()

/obj/structure/discoball/proc/TurnOff()
	TurnedOn = FALSE
	set_light(0)
	remove_atom_colour(TEMPORARY_COLOUR_PRIORITY)
	update_icon()
	if(TimerID)
		deltimer(TimerID)

/obj/structure/discoball/proc/DiscoFever()
	remove_atom_colour(TEMPORARY_COLOUR_PRIORITY)
	current_color = random_color()
	set_light(range, power, current_color)
	add_atom_colour("#[current_color]", FIXED_COLOUR_PRIORITY)
	update_icon()
	TimerID = addtimer(CALLBACK(src, .proc/DiscoFever), 5, TIMER_STOPPABLE)  //Call ourselves every 0.5 seconds to change colors

/obj/structure/discoball/update_icon()
	cut_overlays()
	icon_state = "ethdisco_head_[TurnedOn]"
	var/mutable_appearance/base_overlay = mutable_appearance(icon, "ethdisco_base")
	base_overlay.appearance_flags = RESET_COLOR
	add_overlay(base_overlay)
