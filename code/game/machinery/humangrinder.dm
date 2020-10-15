/obj/machinery/humangrinder
	name = "Body Grinder 501"
	desc = "This big grinder can blend bodies into biomatter. Alt-click to open the door."
	icon = 'icons/obj/machines/cloning.dmi'
	icon_state = "human_grinder"
	density = TRUE
	idle_power_usage = NO_POWER_USE
	active_power_usage = 400
	occupant_typecache = /mob/living/carbon
	circuit = /obj/item/circuitboard/machine/humangrinder
	var/efficiency
	var/biomatter_count = 0
	var/locked = FALSE
	var/message_cooldown
	var/breakout_time = 1200
	var/unlock = TRUE

/obj/machinery/humangrinder/RefreshParts()
	efficiency = 0
	for(var/obj/item/stock_parts/scanning_module/X in component_parts)
		efficiency += X.rating
	for(var/obj/item/stock_parts/matter_bin/X in component_parts)
		efficiency += X.rating
	for(var/obj/item/stock_parts/micro_laser/X in component_parts)
		efficiency += X.rating

/obj/machinery/humangrinder/update_icon()
	//no power or maintenance
	if(stat & (NOPOWER|BROKEN))
		icon_state = initial(icon_state)+ (state_open ? "_open" : "") + "_unpowered"
		return

	if((stat & MAINT) || panel_open)
		icon_state = initial(icon_state)+ (state_open ? "_open" : "") + "_maint"
		return

	//running and someone in there
	if(occupant)
		icon_state = initial(icon_state)+ "_occupant"
		return

	//running
	icon_state = initial(icon_state)+ (state_open ? "_open" : "")

/obj/machinery/humangrinder/power_change()
	..()
	update_icon()

/obj/machinery/humangrinder/proc/toggle_open(mob/user)
	if(panel_open)
		to_chat(user, "<span class='notice'>Close the maintenance panel first.</span>")
		return

	if(state_open)
		close_machine()
		return

	else if(locked)
		to_chat(user, "<span class='notice'>The bolts are locked down, securing the door shut.</span>")
		return

	open_machine()

/obj/machinery/humangrinder/container_resist(mob/living/user)
	if(!locked)
		open_machine()
		return
	user.changeNext_move(CLICK_CD_BREAKOUT)
	user.last_special = world.time + CLICK_CD_BREAKOUT
	user.visible_message("<span class='notice'>You see [user] kicking against the door of [src]!</span>", \
		"<span class='notice'>You lean on the back of [src] and start pushing the door open... (this will take about [DisplayTimeText(breakout_time)].)</span>", \
		"<span class='italics'>You hear a metallic creaking from [src].</span>")
	if(do_after(user,(breakout_time), target = src))
		if(!user || user.stat != CONSCIOUS || user.loc != src || state_open || !locked)
			return
		locked = FALSE
		user.visible_message("<span class='warning'>[user] successfully broke out of [src]!</span>", \
			"<span class='notice'>You successfully break out of [src]!</span>")
		open_machine()

/obj/machinery/humangrinder/close_machine(mob/living/carbon/user)
	if(!state_open)
		return FALSE

	..(user)

	return TRUE

/obj/machinery/humangrinder/open_machine()
	if(state_open)
		return FALSE

	..()

	return TRUE

/obj/machinery/humangrinder/relaymove(mob/user as mob)
	if(user.stat || locked)
		if(message_cooldown <= world.time)
			message_cooldown = world.time + 50
			to_chat(user, "<span class='warning'>[src]'s door won't budge!</span>")
		return
	open_machine()

/obj/machinery/humangrinder/attackby(obj/item/I, mob/user, params)
	if(!occupant && default_deconstruction_screwdriver(user, icon_state, icon_state, I))//sent icon_state is irrelevant...
		update_icon()//..since we're updating the icon here, since the scanner can be unpowered when opened/closed
		return

	if(default_pry_open(I))
		return

	if(default_deconstruction_crowbar(I))
		return

	return ..()

/obj/machinery/humangrinder/MouseDrop_T(mob/target, mob/user)
	var/mob/living/L = user
	if(user.stat || (isliving(user) && (!(L.mobility_flags & MOBILITY_STAND) || !(L.mobility_flags & MOBILITY_UI))) || !Adjacent(user) || !user.Adjacent(target) || !iscarbon(target) || !user.IsAdvancedToolUser())
		return
	close_machine(target)

/obj/machinery/humangrinder/AltClick(mob/user)
	toggle_open(user)

/obj/machinery/humangrinder/ui_interact(mob/user)
	if(stat & BROKEN || panel_open)
		return
	. = ..()
	var/dat
	dat += "<div class='StatusDisplay'>You currently have [biomatter_count] biomatter</div><BR>"
	dat += "<a href='byond://?src=[REF(src)];task=grind'>Grind the body</a><BR>"
	dat += "<a href='byond://?src=[REF(src)];task=biomatter'>Empty Biomatter</a>"
	var/datum/browser/popup = new(user, "Clone Grinder", name, 350, 200)
	popup.set_content(dat)
	popup.set_title_image(user.browse_rsc_icon(icon, icon_state))
	popup.open()

/obj/machinery/humangrinder/Topic(href, href_list)
	var/mob/living/O = occupant
	if(..())
		return
	if("grind")
		if(occupant)
			if(O.stat == DEAD)
				grinding()
			else
				to_chat("<span class='warning'>The body isn't dead yet!</span>")
				playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		else
			to_chat("<span class='warning'>There is no dead body!</span>")
			playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
	if("biomatter")
		biomattering()
		playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)

/obj/machinery/humangrinder/proc/grinding()
	qdel(occupant)
	locked = TRUE
	sleep(200/efficiency)
	locked = FALSE
	biomatter_count += efficiency/4

/obj/machinery/humangrinder/proc/biomattering()
	if(biomatter_count >= 1)
		do
			biomatter_count -= 1
			new /obj/item/reagent_containers/food/snacks/biomatter(src)
			close_machine()
		while(biomatter_count >= 1)