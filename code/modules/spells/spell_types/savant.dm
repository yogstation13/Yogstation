/obj/effect/proc_holder/spell/targeted/savantSuit
	name = "Construct Suit"
	desc = "Build yourself a suit to replace your old one!"

	still_recharging_msg = "<span class='notice'>Wait a moment before attempting to build another one.</span>"
	charge_max = 300
	clothes_req = FALSE
	invocation = "none"
	invocation_type = "none"
	range = -1
	cooldown_min = 100
	include_user = TRUE
	var/metalNumber = 10

/obj/effect/proc_holder/spell/targeted/savantSuit/Click()
	for (var/obj/item/stack/sheet/metal/M in range(1, usr))
		if(M.amount > metalNumber)
			M.amount -= metalNumber

	return TRUE
