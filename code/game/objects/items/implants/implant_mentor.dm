/obj/item/implant/mentor
	name = "mentor implant"
	activated = 0

/obj/item/implant/mentor/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Mentor Implant<BR>
				<b>Life:</b> Activates upon death.<BR>
				"}
	return dat

/obj/item/implant/mentor/on_mob_death(mob/living/L, gibbed)
	activate("death")

/obj/item/implant/mentor/activate(cause)
	if(!cause || !imp_in)
		return FALSE
	var/message = "Someone told me to count.."
	switch(imp_in.ckey)
		if("theos")
			message = "should've played better"
		if("mqiib")
			message = "Fucking sinks..."
		if("jarod1200")
			message = "EMINENCE RECALL!!"
		if("reed0506")
			message = "imagine not taking double damage from lasers. this post was made by plant gang."
		if("fireclaw787")
			message = "Reality is often disappointing."
		if("takahiru")
			message = "shouldve thrown that toolbox..."
		if("mesalikepie")
			message = "Fucking catgirls.... Not again."
		if("lynxJynx")
			message = "We are detecting an eerie signal fleeing your sector... we believe you have released an eldritch horror from his mortal coil"
		if("princeKirze")
			message = "Snake? SNAKE? SNAAAAAAAAAAAAAAAKE!"
		if("tatax")
			message = "O"
		if("uselesstheremin")
			message = "born to shit, forced to wipe... that is the never-ending tragedy of our feeble lives."
		if("truz")
			message = "LAG"
		if("marmio64")
			message = "ofhwadsehekdifbwkwiwhwbei393ur8ifhei2iwi8u&×_8hhsjaudgjfifofoq8wuhdjdfidjejejjdjf"
		if("Georgeur")
			message = "I just got fucked.."
	priority_announce("[imp_in.ckey] has kicked the bucket, their last words were \n\ \n\ [message]", "MBrain Hive Mind", 'sound/misc/sadtrombone.ogg')

