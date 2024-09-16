//Meant to store information for dynamicly adding stuff to TGUI
//How to do: Make a child of info_tab. Every child of that child is a section of the TGUI info tab
//Then use subtypesof() on the original child to get all the information of its children
/datum/info_tab
	var/section = null
	var/section_text = null

/datum/info_tab/icecream_vat

/datum/info_tab/icecream_vat/vat_instructions
	section = "Vat Instructions"
	section_text = "The ice cream vat allows you to select and dispense both ice cream scoops and cones, along with scooping ice cream scoops onto cones. The selected scoop will be scooped into cones, while the selected cone is what is dispensed by alt-clicking the vat. To scoop a cone, select a scoop type and then right-click the vat with an empty cone. Beware: after a cone gets four scoops, adding more has a chance of destroying it."

/datum/info_tab/icecream_vat/restocking
	section = "Restocking"
	section_text = "The ice cream vat can be restocked with new ice cream scoops and cones by left-clicking on the vat with said item. The vat can also be restocked by left-clicking on the vat with an ice cream carton or a cone box. Doing so will transfer its contents into the vat."

/datum/info_tab/icecream_vat/storage_capacity
	section = "Storage Capacity"
	section_text = "The ice cream vat has a storage capacity of 80 scoops and cones combined. This can be increased by upgrading its matter bin."

/datum/info_tab/icecream_vat/new_scoops
	section = "Creating New Scoops"
	section_text = "Scoops are made by mixing 10u of any ice cream reagent with 2u of ice. To make ice cream reagents, you will need to start with plain ice cream, which is made by mixing 5u of cream, 3u of sugar, 2u of salt, and then cooling the mixture to 272 Kelvin. To make the reagents of flavored ice cream, just mix 10u of plain ice cream with 2u of a valid flavor reagent such as vanilla."

/datum/info_tab/icecream_vat/new_cones
	section = "Creating New Cones"
	section_text = "Cones are made in the crafting menu in the misc. food tab. They require a raw pastry base and 2u of their flavor reagent. Once you have made the raw cone, process it with a food processor to turn it into a finished cone."
