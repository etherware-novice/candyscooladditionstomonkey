/obj/item/id_emag_chip
	name = "cryptographic chip"
	desc = "A small cryptographic chip that can be inserted into an id."
	is_emag = 0
	icon = 'icons/obj/device.dmi'
	icon_state = "jammer"

/obj/item/id_emag_chip/attack_self(mob/user)
	if(!is_emag)
		is_emag = 1
		to_chat(user, "You discretely enable the emag circuts.")
	else
		is_emag = 1
		to_chat(user, "You discretely enable the emag circuts.")
