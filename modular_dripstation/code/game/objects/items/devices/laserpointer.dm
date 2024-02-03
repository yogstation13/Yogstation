/obj/item/laser_pointer/RefreshParts()
	///The rate at which the laser regenerates charge. Clamped between 20 seconds and basically instantly just in case of weirdness. Knock off 5 seconds per diode rating
	recharge_rate = clamp((20 SECONDS - (5 SECONDS * diode.rating)), 1, 20 SECONDS)