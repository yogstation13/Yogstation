/obj/screen/psi/hub
	name = "Psi"
	icon_state = "psi_suppressed"
	screen_loc = "EAST-1:28,CENTER-4:7"
	hidden = FALSE
	maptext_x = 6
	maptext_y = -8
	var/image/on_cooldown
	var/mutable_appearance/heat_bar
	var/mutable_appearance/heat_bar_filling
	var/list/components

/obj/screen/psi/hub/New(var/mob/living/_owner)
	on_cooldown = image(icon, "cooldown")
	heat_bar = mutable_appearance(icon, "heat_bar")
	heat_bar.pixel_y += 28
	heat_bar_filling = mutable_appearance(icon, "")
	heat_bar_filling.pixel_y += 28
	components = list(
		new /obj/screen/psi/armour(_owner),
		new /obj/screen/psi/autoredaction(_owner),
		new /obj/screen/psi/zorch_harm(_owner),
		new /obj/screen/psi/limiter(_owner),
		new /obj/screen/psi/toggle_psi_menu(_owner, src)
		)
	..()
	START_PROCESSING(SSprocessing, src)

/obj/screen/psi/hub/update_icon()
	if(!owner.psi)
		return
	cut_overlays()
	icon_state = owner.psi.suppressed ? "psi_suppressed" : "psi_active"
	if(world.time < owner.psi.next_power_use)
		add_overlay(on_cooldown)
	heat_bar_filling.icon_state = "heat_[round(owner.psi.heat / 5, 5)]"
	switch(owner.psi.heat)
		if(400 to 500)
			heat_bar_filling.color = "#FF0033"
		if(300 to 400)
			heat_bar_filling.color = "#FF9933"
		if(100 to 300)
			heat_bar_filling.color = "#00FF33"
		if(0 to 100)
			heat_bar_filling.color = "#6699FF"
	add_overlay(heat_bar)
	add_overlay(heat_bar_filling)
	var/offset = 1
	for(var/thing in components)
		var/obj/screen/psi/component = thing
		component.update_icon()
		if(!component.invisibility)
			component.screen_loc = "EAST-[++offset]:28,CENTER-4:7"

/obj/screen/psi/hub/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	owner = null
	for(var/thing in components)
		qdel(thing)
	components.Cut()
	. = ..()

/obj/screen/psi/hub/process()
	if(!istype(owner))
		qdel(src)
		return
	if(!owner.psi)
		return
	maptext = "[round((owner.psi.stamina/owner.psi.max_stamina)*100)]%"
	update_icon()

/obj/screen/psi/hub/MouseEntered(location, control, params)
	. = ..()
	openToolTip(usr, src, params, title = "[owner.mind.name]'s Psi Complexus", content = "<b>Stamina:</b> [(owner.psi.stamina/owner.psi.max_stamina)*100]%\n<b>Heat:</b> [owner.psi.heat]\n<b>Stuned:</b> [owner.psi.stun ? "True" : "False"]\n")

/obj/screen/psi/hub/MouseExited(location, control, params)
	. = ..()
	closeToolTip(usr)

/obj/screen/psi/hub/Click(var/location, var/control, var/params)
	var/list/click_params = params2list(params)
	if(click_params["shift"])
		owner.show_psi_assay(owner)
		return

	if(owner.psi.suppressed && owner.psi.stun)
		to_chat(owner, "<span class='warning'>You are dazed and reeling, and cannot muster enough focus to do that!</span>")
		return

	owner.psi.suppressed = !owner.psi.suppressed
	to_chat(owner, "<span class='notice'>You are <b>[owner.psi.suppressed ? "now suppressing" : "no longer suppressing"]</b> your psi-power.</span>")
	if(owner.psi.suppressed)
		owner.psi.cancel()
		owner.psi.hide_auras()
	else
		owner.playsound_local(soundin = 'sound/effects/psi/power_unlock.ogg')
		owner.psi.show_auras()
	update_icon() 
