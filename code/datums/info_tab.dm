//Meant to store information for dynamicly adding stuff to TGUI
//How to do: Make a child of info_tab. Every child of that child is a section of the TGUI info tab
//Then use subtypesof() on the original child to get all the information of its children
/datum/info_tab
	var/section = null
	var/section_text = null

/datum/info_tab/ice_cream_vat

/datum/info_tab/ice_cream_vat/vat_instructions
	section = "Vat Instructions"
	section_text = "With the ice cream vat, you can select and dispense ice cream scoops and cones, and scoop ice cream scoops onto cones. The selected scoop will be what is scooped into cones, while the selected cone is what is dispensed by alt-clicking the vat. To scoop ice cream into a cone, select a scoop type that the vat has and then left-click the vat with an empty cone. Cones can only have one scoop of ice cream."

/datum/info_tab/ice_cream_vat/restocking
	section = "Restocking"
	section_text = "The ice cream vat can be restocked with new ice cream scoops and cones by using them on the vat. The vat can also be restocked by using an ice cream carton with scoops inside it on the vat. Doing so will transfer the scoops into the vat. To get more ice cream, you can either make more scoops or buy them from cargo. To get more cones, you will have to make their raw form from the crafting menu and the process them with a food processor."

/datum/info_tab/ice_cream_vat/storage_capacity
	section = "Storage Capacity"
	section_text = "The ice cream vat has a storage capacity of 120 items: scoops and cones combined."

/datum/info_tab/ice_cream_vat/new_scoops
	section = "Creating New Scoops"
	section_text = "To Create new scoops, you will need to get 10u of any given ice cream flavor and then mix it with 2u of ice. Doing so will give you one scoop of ice cream. To make ice cream reagents, you will need to start with plain ice cream. Plain ice cream is made by mixing 5u of cream, 3u of sugar, 2u of salt, and then cooling it to 272 Kelvin. To make the reagents of flavored ice cream, mix 10u of plain ice cream with 2u of the desired flavor. For vanilla, this is vanilla powder. For chocolate, it is coco powder. For strawberry, it is berry juice. For blue, it is singulo. For lemon sorbet, it is lemon juice. For caramel, it is caramel. For banana, it is banana juice. For orange creamsicle, it is orange juice. For peach, it is peach juice. For meat lovers, it is liquid gibs. Cherry chocolate is the exception, as it requires 10u of chocolate ice cream rather than plain ice cream. Its flavor reagent is cherry jelly. Flavored ice cream reagents do not need to be cooled down to be made like plain ice cream does, but only return 10u rather than 12u of reagents."

/datum/info_tab/ice_cream_vat/new_cones
	section = "Creating New Cones"
	section_text = "Cones are made in the crafting menu in the misc. food tab. They require a raw pastry base and 2u of their flavor reagent. For cake cones, this is sugar. For chocolate cones, this is coco powder. Once you have made the raw cone, process it with a food processor to turn it into a finished cone."
