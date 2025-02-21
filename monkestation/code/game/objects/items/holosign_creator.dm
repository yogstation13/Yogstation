/obj/item/holosign_creator/emp_act(severity)
	. = ..()
	for(var/obj/structure/holosign/sign as anything in signs)
		if(prob(90 / severity))
			qdel(sign)

/obj/item/holosign_creator/medical
	max_signs = 6
