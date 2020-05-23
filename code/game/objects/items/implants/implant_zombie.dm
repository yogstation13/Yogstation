/obj/item/implant/zombie
	name = "zombie implant"
	desc = "Fake your death and trick those NT shills"
	icon_state = "zombie"
	uses = 1
	//allow_reagents = 1

/obj/item/implant/zombie/New()
	..()
	create_reagents(50)
	src.reagents.add_reagent(/datum/reagent/toxin/capilletum, 35)

/obj/item/implant/zombie/activate()
	var/mob/living/carbon/H = imp_in
	H << "You hear a soft whirr as your implant discharges it's toxins into you."
	reagents.trans_to(H, reagents.total_volume)
	if(uses == 2)
		uses--
	else
		H << "You feel something slip away from you."
		qdel(src)

/obj/item/implant/zombie/get_data()
	var/dat = {"
<b>Implant Specifications:</b><BR>
<b>Name:</b> Syndicate Zombie Simulator<BR>
<b>Life:</b> Single use<BR>
<b>Important Notes:</b> <font color='red'>Illegal</font><BR>
<HR>
<b>Implant Details:</b> <BR>
<b>Function:</b> Releases a specially formulated chemical that makes you appear
dead to the casual observer.<BR>
<b>Special Features:</b><BR>
<b>Integrity:</b> After the implant has injected it's contents into the bearer, it
will automatically begin to break down into bio-safe substances and disappear completely.<HR>"}
	return dat
