/datum/bounty/item/syndicate

/datum/bounty/item/syndicate/claim(mob/user) //Syndicate bounties add TCs to your uplink
	if(can_claim())
		var/datum/mind/claimer = user.mind
		if(claimer.find_syndicate_uplink())
			var/datum/component/uplink/U = claimer.find_syndicate_uplink()
			U.telecrystals += reward
			claimed = TRUE //to prevent deleting the TCs if you claim it with no uplink

/datum/bounty/item/syndicate/reward_string()
	return "!&@#WE'LL GIVE YOU [reward] TELECRYSTALS IF YOU DO THIS FOR US!#@*$"

/datum/bounty/item/syndicate/saber
	name = "!&@#THE CAPTAIN'S SABRE!#@*$"
	description = "!&@#WE'RE TESTING OUT OUR ARMOR'S PROTECTIVE ABILITY, BUT WE NEED SOMETHING SHARP! PROVIDE IT TO US FOR A REWARD!#@*$"
	wanted_types = list(/obj/item/melee/sabre)
	reward = 5
/datum/bounty/item/syndicate/capsuit
	name = "!&@#THE CAPTAIN'S SWAT SUIT!#@*$"
	description = "!&@#OUR NEW BATCH OF ARMOR-PIERCING ROUNDS HAVE JUST COME OFF THE PRODUCTION LINE, AND WE NEED SOMETHING TO TEST THEM ON! HELP US OUT AND YOU'LL BE REWARDED!#@*$"
	wanted_types = list(/obj/item/clothing/suit/space/hardsuit/swat/captain)
	reward = 4

/datum/bounty/item/syndicate/aicore
	name = "!&@#AI CORE CONSOLE BOARD!#@*$"
	description = "!&@#WE'RE INTERESTED IN LEARNING MORE ABOUT NANOTRASEN AIS. SEND US AN AI DATA CORE BOARD TO BE REWARDED!#@*$"
	wanted_types = list(/obj/item/circuitboard/machine/ai_data_core)
	reward = 2
/datum/bounty/item/syndicate/aicontrol
	name = "!&@#AI CONTROL CONSOLE BOARD!#@*$"
	description = "!&@#A CONSOLE TO REMOTELY DISABLE AI UNITS WOULD BE QUITE HELPFUL FOR US, SO GET US ONE!#@*$"
	wanted_types = list(/obj/item/circuitboard/machine/ai_data_core)
	reward = 6
/datum/bounty/item/syndicate/rdsuit
	name = "!&@#PROTOTYPE HARDSUIT!#@*$"
	description = "!&@#WE'RE INTERESTED IN DEVELOPING ARMOR THAT CAN RESIST EXPLOSIVES BETTER. THE PROTOTYPE HARDSUIT WOULD BE HELPFUL FOR THIS GOAL!#@*$"
	wanted_types = list(/obj/item/circuitboard/machine/ai_data_core)
	reward = 3
/datum/bounty/item/syndicate/boh
	name = "!&@#BAG OF HOLDING!#@*$"
	description = "!&@#EXPERIMENTAL BLUESPACE TECHNOLOGY LIKE A BAG OF HOLDING WOULD BE APPRECIATED BY THE LAB BOYS. THEY'RE WILLING TO PAY HANDSOMELY, TOO#@*$"
	wanted_types = list(/obj/item/storage/backpack/holding,/obj/item/storage/backpack/holding/rd)
	reward = 7
/datum/bounty/item/syndicate/aeg
	name = "!&@#ADVANCED ENERGY GUN!#@*$"
	description = "!&@#WE'RE LOOKING FOR FLAWS IN NANOTRASEN WEAPONS TECHNOLOGY TO EXPLOIT. SEND US SOME EXAMPLES OF THEIR TECHNOLOGY, AND WE'LL REWARD YOU#@*$"
	wanted_types = list(/obj/item/gun/energy/e_gun/nuclear)
	required_count = 3
	reward = 4
/datum/bounty/item/syndicate/aiupload
	name = "!&@#AI UPLOAD CONSOLE BOARD!#@*$"
	description = "!&@#WE'RE PROBING NANOTRASEN AIS FOR SECURITY FLAWS. A CONSOLE LIKE THIS COULD ACCOMPLISH OUR GOAL#@*$"
	wanted_types = list(/obj/item/circuitboard/computer/aiupload)
	reward = 5
/datum/bounty/item/syndicate/borgupload
	name = "!&@#CYBORG UPLOAD CONSOLE BOARD!#@*$"
	description = "!&@#WE'RE PROBING NANOTRASEN CYBORGS FOR SECURITY FLAWS. A CONSOLE LIKE THIS COULD ACCOMPLISH OUR GOAL#@*$"
	wanted_types = list(/obj/item/circuitboard/computer/borgupload)
	reward = 3
/datum/bounty/item/syndicate/gygaxboards
	name = "!&@#GYGAX EXOSUIT BOARDS!#@*$"
	description = "!&@#AFTER A RECENT OPERATION, SEVERAL OF OUR DARK GYGAX UNITS HAVE BEEN LEFT INOPERABLE. SEND SOME REPLACEMENT BOARDS TO US FOR A REWARD#@*$"
	wanted_types = list(/obj/item/circuitboard/mecha/gygax/peripherals,/obj/item/circuitboard/mecha/gygax/targeting,/obj/item/circuitboard/mecha/gygax/main)
	reward = 5
	required_count = 3
/datum/bounty/item/syndicate/phazon
	name = "!&@#PHAZON EXOSUIT!#@*$"
	description = "!&@#WE'D LOVE TO GET OUR HANDS ON ONE OF THESE. IT MAY BE HARD TO SOURCE, BUT WE WILL REWARD YOU GENEROUSLY IF YOU SUCCEED.#@*$"
	wanted_types = list(/obj/mecha/combat/phazon)
	reward = 12 //you need an anomaly core and robotics for this one broski, it's gotta be worth a lot