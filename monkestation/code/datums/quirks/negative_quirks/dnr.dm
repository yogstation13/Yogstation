/datum/quirk/dnr
	name = "Do Not Revive"
	desc = "You cannot be defibrillated upon death. Make your only shot count."
	value = -8
	gain_text = span_danger("You have one chance left.")
	lose_text = span_notice("Your connection to this mortal plane strengthens!")
	medical_record_text = "The connection between the patient's soul and body is incredibly weak, and attempts to resuscitate after death will fail. Ensure heightened care."
	mob_trait = TRAIT_DEFIB_BLACKLISTED
	icon = FA_ICON_HEART
