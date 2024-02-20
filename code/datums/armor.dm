#define ARMORID "armor-[melee]-[bullet]-[laser]-[energy]-[bomb]-[bio]-[rad]-[fire]-[acid]-[magic]-[wound]-[electric]"

/proc/getArmor(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0, fire = 0, acid = 0, magic = 0, wound = 0, electric=0)
	. = locate(ARMORID)
	if (!.)
		. = new /datum/armor(melee, bullet, laser, energy, bomb, bio, rad, fire, acid, magic, wound, electric)

/datum/armor
	var/melee
	var/bullet
	var/laser
	var/energy
	var/bomb
	var/bio
	var/rad
	var/fire
	var/acid
	var/magic
	var/wound
	var/electric

/datum/armor/New(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0, fire = 0, acid = 0, magic = 0, wound = 0, electric=0)
	src.melee = melee
	src.bullet = bullet
	src.laser = laser
	src.energy = energy
	src.bomb = bomb
	src.bio = bio
	src.rad = rad
	src.fire = fire
	src.acid = acid
	src.magic = magic
	src.wound = wound
	src.electric = electric
	tag = ARMORID
	GenerateTag()

/datum/armor/proc/modifyRating(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0, fire = 0, acid = 0, magic = 0, wound = 0, electric=0)
	return getArmor(src.melee+melee, src.bullet+bullet, src.laser+laser, src.energy+energy, src.bomb+bomb, src.bio+bio, src.rad+rad, src.fire+fire, src.acid+acid, src.magic+magic, src.wound+wound, src.electric+electric)

/datum/armor/proc/modifyAllRatings(modifier = 0)
	return getArmor(melee+modifier, bullet+modifier, laser+modifier, energy+modifier, bomb+modifier, bio+modifier, rad+modifier, fire+modifier, acid+modifier, magic+modifier, wound+modifier, electric+modifier)

/datum/armor/proc/setRating(melee, bullet, laser, energy, bomb, bio, rad, fire, acid, magic, wound, electric)
  return getArmor(
		(isnull(melee) ? src.melee : melee),
		(isnull(bullet) ? src.bullet : bullet),
		(isnull(laser) ? src.laser : laser),
		(isnull(energy) ? src.energy : energy),
		(isnull(bomb) ? src.bomb : bomb),
		(isnull(bio) ? src.bio : bio),
		(isnull(rad) ? src.rad : rad),
		(isnull(fire) ? src.fire : fire),
		(isnull(acid) ? src.acid : acid),
		(isnull(magic) ? src.magic : magic),
		(isnull(wound) ? src.wound : wound),
		(isnull(electric) ? src.electric : electric),
	)

/datum/armor/proc/getRating(rating)
	return vars[rating]

/datum/armor/proc/getList()
	return list(MELEE = melee, BULLET = bullet, LASER = laser, ENERGY = energy, BOMB = bomb, BIO = bio, RAD = rad, FIRE = fire, ACID = acid, MAGIC = magic, WOUND = wound, ELECTRIC = electric)

/datum/armor/proc/attachArmor(datum/armor/AA)
	return getArmor(melee+AA.melee, bullet+AA.bullet, laser+AA.laser, energy+AA.energy, bomb+AA.bomb, bio+AA.bio, rad+AA.rad, fire+AA.fire, acid+AA.acid, magic+AA.magic, wound+AA.wound, electric+AA.electric)

/datum/armor/proc/detachArmor(datum/armor/AA)
	return getArmor(melee-AA.melee, bullet-AA.bullet, laser-AA.laser, energy-AA.energy, bomb-AA.bomb, bio-AA.bio, rad-AA.rad, fire-AA.fire, acid-AA.acid, magic-AA.magic, wound-AA.wound, electric-AA.electric)

/datum/armor/vv_edit_var(var_name, var_value)
	if (var_name == NAMEOF(src, tag))
		return FALSE
	. = ..()
	tag = ARMORID // update tag in case armor values were edited

/datum/armor/proc/show_protection_classes(additional_info = "")
	var/list/readout = list("<span class='notice'><u><b>PROTECTION CLASSES</u></b>")

	if(bomb || bullet || energy || laser || melee)
		readout += "\n<b>ARMOR (I-X)</b>"
		if(bomb)
			readout += "\nEXPLOSIVE [armor_to_protection_class(bomb)]"
		if(bullet)
			readout += "\nBULLET [armor_to_protection_class(bullet)]"
		if(energy)
			readout += "\nENERGY [armor_to_protection_class(energy)]"
		if(laser)
			readout += "\nLASER [armor_to_protection_class(laser)]"
		if(melee)
			readout += "\nMELEE [armor_to_protection_class(melee)]"

	if(bio || rad || electric)
		readout += "\n<b>ENVIRONMENT (I-X)</b>"
		if(bio)
			readout += "\nBIOHAZARD [armor_to_protection_class(bio)]"
		if(rad)
			readout += "\nRADIATION [armor_to_protection_class(rad)]"
		if(electric)
			readout += "\nELECTRICAL [armor_to_protection_class(electric)]"

	if(fire || acid)
		readout += "\n<b>DURABILITY (I-X)</b>"
		if(fire)
			readout += "\nFIRE [armor_to_protection_class(fire)]"
		if(acid)
			readout += "\nACID [armor_to_protection_class(acid)]"

	if(additional_info != "")
		readout += additional_info
	readout += "</span>"
	return readout.Join()

/**
  * Rounds armor_value down to the nearest 10, divides it by 10 and then converts it to Roman numerals.
  *
  * Arguments:
  * * armor_value - Number we're converting
  */
/datum/armor/proc/armor_to_protection_class(armor_value)
	if (armor_value < 0)
		. = "-"
	. += "\Roman[round(abs(armor_value), 10) / 10]"
	return .

#undef ARMORID
