/obj/item/holotool_module
    name = "holotool module"
    desc = "Contact a coder!"
    icon = 'icons/obj/module.dmi'
    icon_state = "cyborg_upgrade"
    w_class = WEIGHT_CLASS_SMALL
    var/datum/holotool_mode/preset_mode
    var/datum/holotool_mode/mode
    var/speed = 1.25
    var/toolage_use = 1

/obj/item/holotool_module/Initialize()
    . = ..()
    mode = new preset_mode()
    mode.speed = speed

/obj/item/holotool_module/examine()
    . += "This card takes up [toolage_use] capacity."

/obj/item/holotool_module/off
    preset_mode = /datum/holotool_mode/off

/obj/item/holotool_module/screwdriver
    preset_mode = /datum/holotool_mode/screwdriver
    name = "basic screwdriver holotool card"
    desc = "A card that lets your holotool take on a screwdriver form. Perfect for screwing around."

/obj/item/holotool_module/screwdriver/advanced
    name = "advanced screwdriver holotool card"
    speed = 1
    toolage_use = 2

/obj/item/holotool_module/screwdriver/elite
    name = "elite screwdriver holotool card"
    speed = 0.8
    toolage_use = 3

/obj/item/holotool_module/screwdriver/rd
    name = "experimental screwdriver holotool card"
    speed = 0.4
    toolage_use = 2

/obj/item/holotool_module/crowbar
    preset_mode = /datum/holotool_mode/crowbar
    name = "basic crowbar holotool card"
    desc = "A card that lets your holotool take on a crowbar form. Not suitable for bludgeoning aliens."
    toolage_use = 2

/obj/item/holotool_module/crowbar/advanced
    name = "advanced crowbar holotool card"
    speed = 1
    toolage_use = 3

/obj/item/holotool_module/crowbar/elite
    name = "elite crowbar holotool card"
    speed = 0.8
    toolage_use = 4

/obj/item/holotool_module/crowbar/rd
    name = "experimental crowbar holotool card"
    speed = 0.4
    toolage_use = 2

/obj/item/holotool_module/multitool
    preset_mode = /datum/holotool_mode/multitool
    name = "basic multitool holotool card"
    desc = "A card that lets your holotool take on a multitool form. Warranty void if shocked."
    toolage_use = 2

/obj/item/holotool_module/multitool/advanced
    name = "advanced multitool holotool card"
    speed = 1
    toolage_use = 3

/obj/item/holotool_module/multitool/elite
    name = "elite multitool holotool card"
    speed = 0.8
    toolage_use = 4

/obj/item/holotool_module/multitool/rd
    name = "experimental multitool holotool card"
    speed = 0.4
    toolage_use = 2

/obj/item/holotool_module/wrench
    preset_mode = /datum/holotool_mode/wrench
    name = "basic wrench holotool card"
    desc = "A card that lets your holotool take on a wrench form. Typically used by holographic monkeys."

/obj/item/holotool_module/wrench/advanced
    name = "advanced wrench holotool card"
    speed = 1
    toolage_use = 2

/obj/item/holotool_module/wrench/elite
    name = "elite wrench holotool card"
    speed = 0.8
    toolage_use = 4

/obj/item/holotool_module/wrench/rd
    name = "experimental wrench wrench holotool card"
    speed = 0.4
    toolage_use = 2

/obj/item/holotool_module/snips
    preset_mode = /datum/holotool_mode/wirecutters
    name = "basic wirecutters holotool card"
    desc = "A card that lets your holotool take on a wirecutters form. Keep away from clowns."

/obj/item/holotool_module/snips/advanced
    name = "advanced wirecutters holotool card"
    toolage_use = 2
    speed = 1
    
/obj/item/holotool_module/snips/elite
    name = "elite wirecutters holotool card"
    toolage_use = 3
    speed = 0.8

/obj/item/holotool_module/snips/rd
    name = "experimental wirecutters holotool card"
    toolage_use = 2
    speed = 0.4

/obj/item/holotool_module/welder
    preset_mode = /datum/holotool_mode/welder
    name = "basic welder holotool card"
    desc = "A card that lets your holotool take on a welder form. Don't ask how it works."
    toolage_use = 2

/obj/item/holotool_module/welder/advanced
    name = "advanced welder holotool card"
    toolage_use = 3
    speed = 1

/obj/item/holotool_module/welder/elite
    name = "elite welder holotool card"
    toolage_use = 4
    speed = 0.8

/obj/item/holotool_module/welder/rd
    name = "experimental welder holotool card"
    toolage_use = 2
    speed = 0.4