// Begin psi armour toggle.
/obj/screen/psi/armour
	name = "Psi-Armour"
	icon_state = "psiarmour_off"

/obj/screen/psi/armour/update_icon()
	..()
	if(invisibility == 0)
		icon_state = owner.psi.use_psi_armour ? "psiarmour_on" : "psiarmour_off"

/obj/screen/psi/armour/Click()
	if(!owner.psi)
		return
	owner.psi.use_psi_armour = !owner.psi.use_psi_armour
	to_chat(owner, span_notice("You will [owner.psi.use_psi_armour ? "no longer" : "now"] use your psionics to deflect or block incoming attacks."))
	update_icon()

// End psi armour toggle.

// Begin autoredaction toggle.
/obj/screen/psi/autoredaction
	name = "Autoredaction"
	icon_state = "healing_off"

/obj/screen/psi/autoredaction/update_icon()
	..()
	if(invisibility == 0)
		icon_state = owner.psi.use_autoredaction ? "healing_on" : "healing_off"

/obj/screen/psi/autoredaction/Click()
	if(!owner.psi)
		return
	owner.psi.use_autoredaction = !owner.psi.use_autoredaction
	to_chat(owner, span_notice("You will [owner.psi.use_autoredaction ? "now" : "no longer"] use your psionics to regenerate."))
	update_icon()

// End autoredaction toggle.

// Begin zorch harm toggle.
/obj/screen/psi/zorch_harm
	name = "Zorch Mode"
	icon_state = "zorch_disable"

/obj/screen/psi/zorch_harm/update_icon()
	..()
	if(invisibility == 0)
		icon_state = owner.psi.zorch_harm ? "zorch_harm" : "zorch_disable"

/obj/screen/psi/zorch_harm/Click()
	if(!owner.psi)
		return
	owner.psi.zorch_harm = !owner.psi.zorch_harm
	to_chat(owner, span_notice("You will now fire [owner.psi.zorch_harm ? "lethal" : "non-lethal"] lasers with your psionics."))
	update_icon()

// End zorch harm toggle.

// Begin limiter toggle.
/obj/screen/psi/limiter
	name = "Psi-Limiter"
	icon_state = "limiter_100"

/obj/screen/psi/limiter/update_icon()
	..()
	if(invisibility == 0)
		switch(owner.psi.limiter)
			if(100)
				icon_state = "limiter_100"
			if(300)
				icon_state = "limiter_300"
			if(INFINITY)
				icon_state = "limiter_500"

/obj/screen/psi/limiter/Click()
	if(!owner.psi)
		return
	switch(owner.psi.limiter)
		if(100)
			owner.psi.limiter = 300
		if(300)
			owner.psi.limiter = INFINITY
		if(INFINITY)
			owner.psi.limiter = 100
	if(owner.psi.limiter == INFINITY)
		to_chat(owner, span_warning("You release your self imposed shackles!"))
	else
		to_chat(owner, span_notice("Your mental limiters will stop you at [owner.psi.limiter] heat."))
	update_icon()

// End limiter toggle.

// Menu toggle.
/obj/screen/psi/toggle_psi_menu
	name = "Show/Hide Psi UI"
	icon_state = "arrow_left"
	var/obj/screen/psi/hub/controller

/obj/screen/psi/toggle_psi_menu/New(var/mob/living/_owner, var/obj/screen/psi/hub/_controller)
	controller = _controller
	..(_owner)

/obj/screen/psi/toggle_psi_menu/Click()
	var/set_hidden = !hidden
	for(var/thing in controller.components)
		var/obj/screen/psi/psi = thing
		psi.hidden = set_hidden
	controller.update_icon()

/obj/screen/psi/toggle_psi_menu/update_icon()
	if(hidden)
		icon_state = "arrow_left"
	else
		icon_state = "arrow_right"
// End menu toggle. 
