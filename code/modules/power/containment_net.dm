#define CNMODE_EMPTY 0
#define CNMODE_SUPERMATTER 1
#define CNMODE_SINGULARITY 2
#define CNMODE_TESLA 3

/// Engine Containment Net
/// Uses gravity to stabilize fragments of station engines
/// If the engine and procedure is not that dangerous, individual fragments will be worth less than others
/// The more fragments you have, the more frequently side effects will occur
/// Currently only used for bags of holding
/// You can transfer items between the nets if both nets are open
/// Dropping or setting down a net with any engine fragments in it will explode
/// Supermatter:
/// - Shard needs to be harvested using scalpel and tongs, then inserted into the open net
/// - This is very dangerous and will harm the supermatter, so you only need one shard
/// - Side effect: Pulses radiation occasionally
/// Singularity:
/// - Stand near the singularity and hold the net open
/// - Fragments will collect into the net automatically
/// - You will need 2 fragments
/// - Side effect: Semi-regular EMPs
/// Tesla:
/// - Stand near the singularity and hold the net open
/// - Energy balls will collect into the net automatically
/// - You will need 4 energy balls
/// - Side effect: Frequent harmful (but not explosive) energy arcs
/obj/item/containment_net
	name = "gravitational containment net"
	desc = "A flimsy piece of mesh, the inside lined with nubs. Used to capture and hold various engineering phenomena. Very self-destructive."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "net_0"
	var/open = FALSE
	var/mode = CNMODE_EMPTY
	var/incomplete_mode = CNMODE_EMPTY
	var/amount = 0
	var/required_amount = 10
	var/charge = 0

/obj/item/containment_net/examine(mob/user)
	. = ..()
	if(mode == CNMODE_EMPTY && open)
		. += span_info("It must be <b>opened</b> to capture exotic energy.")
	else if(incomplete_mode && loc == user)
		. += span_dangers("Don't let go of it.")

/obj/item/containment_net/attack_self(mob/user)
	. = ..()
	if(mode)
		to_chat(user, span_danger("You can't close \the [src], it's full!"))
		return
	open = !open
	to_chat(user, span_notice("You [open ? "open" : "close"] \the [src]."))
	if(open)
		START_PROCESSING(SSobj, src)
	else
		STOP_PROCESSING(SSobj, src)

/// Resets the state of the net and prepares it for re-use
/obj/item/containment_net/proc/reset_net()
	STOP_PROCESSING(SSobj, src)
	name = initial(name)
	icon_state = initial(icon_state)
	open = initial(open)
	mode = initial(mode)
	incomplete_mode = initial(incomplete_mode)
	amount = initial(amount)
	required_amount = initial(required_amount)
	charge = initial(charge)

/obj/item/containment_net/proc/warn_user(mob/user)
	if(istype(user))
		to_chat(user, span_userdanger("The net now contains dangerous material and will violently explode if dropped or set down!"))
	else
		visible_message(span_userdanger("The net now contains dangerous material and will violently explode if dropped or set down!"))

/obj/item/containment_net/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/hemostat/supermatter))
		var/obj/item/hemostat/supermatter/tongs = I
		if(!tongs.sliver)
			return ..()
		if(open)
			open = FALSE
			mode = CNMODE_SUPERMATTER
			amount = 1
			required_amount = 1
			name = "[initial(name)] with a supermatter shard inside"
			icon_state = "net_[amount-1]"
			to_chat(user, span_notice("You calmly collect \the [tongs.sliver] into \the [src]."))
			warn_user(user)
			QDEL_NULL(tongs.sliver)
			tongs.icon_state = "supermatter_tongs"
		else
			// die idiot
			to_chat(user, span_userdanger("As you reach the tongs towards the net, you think to yourself, \"Maybe I should open the net first\"."))
			return ..()
	else if(istype(I, /obj/item/containment_net))
		if(mode)
			to_chat(user, span_danger("\The [src] is already full!"))
			return ..()
		if(!open)
			to_chat(user, span_danger("\The [src] is not open!"))
			return ..()
		var/obj/item/containment_net/net = I
		if(!net.open)
			to_chat(user, span_danger("Your [net] is not open!"))
			return ..()
		if(incomplete_mode == net.incomplete_mode || !incomplete_mode)
			incomplete_mode = net.incomplete_mode

			required_amount -= amount

			var/transfer = min(net.amount, required_amount)

			to_chat(user, span_notice("You transfer [transfer] to \the [src]."))
			net.amount -= transfer // Transaction successful
			amount += transfer // Have a nice day

			if(amount == required_amount)
				mode = incomplete_mode

			if(net.amount == 0)
				net.reset_net()
	else
		return ..()

/obj/item/containment_net/dropped(mob/user, silent)
	. = ..()
	if(incomplete_mode)
		user.visible_message(span_notice("[user] drops \the [src], letting loose the captured energy."), span_userdanger("You drop \the [src]. Idiot."))
		log_bomber(user, "detonated", src, "by dropping it")
		explosion(get_turf(src), 0, 2, 0, 5)
		qdel(src)

/obj/item/containment_net/singularity_act()
	if(incomplete_mode)
		explosion(get_turf(src), 0, 2, 0, 5)
	return ..()

/obj/item/containment_net/Destroy()
	. = ..()
	STOP_PROCESSING(SSobj, src)

/obj/item/containment_net/process()
	if(mode)
		charge += amount
		if(charge >= 10)
			discharge()
	else
		try_capture()
		charge = 0

/obj/item/containment_net/proc/try_capture()
	switch(incomplete_mode)
		if(CNMODE_SINGULARITY)
			get_singularity()
		if(CNMODE_TESLA)
			get_tesla()
		if(CNMODE_EMPTY)
			if(!get_tesla())
				get_singularity()
	if(amount >= required_amount)
		mode = incomplete_mode

/obj/item/containment_net/proc/get_singularity()
	for(var/obj/singularity/S in oview(6, src))
		incomplete_mode = CNMODE_SINGULARITY
		required_amount = 2
		amount++
		S.energy -= 75
		visible_message(span_notice("\The [src] catches a singularity fragment."))
		icon_state = "net_[amount-1]"
		if(amount == 1)
			warn_user()
			name = "[initial(name)] of singularity fragments"
		return TRUE
	return FALSE

/obj/item/containment_net/proc/get_tesla()
	for(var/obj/singularity/energy_ball/E in oview(6, src))
		incomplete_mode = CNMODE_TESLA
		required_amount = 4
		amount++
		S.energy -= 50
		visible_message(span_notice("\The [src] catches an energy ball."))
		icon_state = "net_[amount-1]"
		if(amount == 1)
			warn_user()
			name = "[initial(name)] of energy balls"
		return TRUE
	return FALSE

/obj/item/containment_net/proc/discharge()
	switch(mode)
		if(CNMODE_SUPERMATTER)
			radiation_pulse(src, 80)
		if(CNMODE_SINGULARITY)
			var/r_range = rand(2,3)
			empulse(src, r_range, r_range * 2, TRUE)
		if(CNMODE_TESLA)
			tesla_zap(get_turf(src), rand(4,6), 15000, TESLA_OBJ_DAMAGE | TESLA_MOB_DAMAGE)

	charge = MODULUS(charge, 10)
