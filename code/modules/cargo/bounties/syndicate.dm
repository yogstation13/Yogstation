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
	name = "!&@#AI CORE BOARD CONSOLE!#@*$"
	description = "!&@#WE'RE INTERESTED IN LEARNING MORE ABOUT NANOTRASEN AIS. SEND US AN AI DATA CORE BOARD TO BE REWARDED!#@*$"
	wanted_types = list(/obj/item/circuitboard/machine/ai_data_core)
	reward = 2
/datum/bounty/item/syndicate/aicontrol
	name = "!&@#AI CONTROL BOARD CONSOLE!#@*$"
	description = "!&@#A CONSOLE TO REMOTELY DISABLE AI UNITS WOULD BE QUITE HELPFUL FOR US, SO GET US ONE!#@*$"
	wanted_types = list(/obj/item/circuitboard/machine/ai_data_core)
	reward = 6
/datum/bounty/item/syndicate/rdsuit
	name = "!&@#PROTOTYPE HARDSUIT!#@*$"
	description = "!&@#WE'RE INTERESTED IN DEVELOPING ARMOR THAT CAN RESIST EXPLOSIVES BETTER. THE PROTOTYPE HARDSUIT WOULD BE HELPFUL FOR THIS GOAL!#@*$"
	wanted_types = list(/obj/item/circuitboard/machine/ai_data_core)
	reward = 3
