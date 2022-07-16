/obj/item/lightreplacer/bluespace
	icon = 'monkestation/icons/obj/janitor.dmi'
	icon_state = "lightreplacer_blue0"
	bluespacemode = 1

/obj/item/lightreplacer/bluespace/update_icon()  // making sure it uses the new icon state names
	icon_state = "lightreplacer_blue[(obj_flags & EMAGGED ? 1 : 0)]"
