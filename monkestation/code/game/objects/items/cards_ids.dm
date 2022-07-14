/obj/item/card/emag/chip
	name = "identification card"
	desc = "A card used to provide ID and determine access across the station. A few loose wires hang off the end of it."
	icon = 'monkestation/icons/obj/card.dmi'
	icon_state = "emag_hidden"
	var/id_internal

/obj/item/card/emag/chip/attack_self(mob/user)
	user.put_in_hands(id_internal)  // qdel(src) prevents this from running if put before
	qdel(src)
	to_chat(user, "You silently slip the electronics back into the card, reenabling the id functions.")
