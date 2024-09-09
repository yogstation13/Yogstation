/obj/item/sensor_device/blueshield
	name = "blueshield's handheld monitor"
	desc = "A unique model of handheld crew monitor that seems to have been customized for Executive Protection purposes."
	icon = 'monkestation/code/modules/blueshield/icons/device.dmi'
	icon_state = "blueshield_scanner"

/obj/item/sensor_device/blueshield/attack_self(mob/user)
	GLOB.blueshield_crewmonitor.show(user,src)
