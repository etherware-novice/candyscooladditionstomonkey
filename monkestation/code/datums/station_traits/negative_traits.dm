/datum/station_trait/announcement_syndie
	name = "(REDACTED) announcements"
	trait_type = STATION_TRAIT_NEGATIVE
	weight = 300000000000000000000000000
	show_in_report = TRUE
	report_message = "Traitors have hijacked our announcement system. Be warn- (CONNECTION END.)"
	blacklist = list(/datum/station_trait/announcement_medbot,
	/datum/station_trait/announcement_baystation,
	/datum/station_trait/announcement_duke,
	/datum/station_trait/announcement_intern
	)

/datum/station_trait/announcement_syndie/New()
	. = ..()
	SSstation.announcer = /datum/centcom_announcer/syndie
