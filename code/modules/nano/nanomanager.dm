// This is the window/UI manager for Nano UI
// There should only ever be one (global) instance of nanomanger
/datum/nanomanager
	var/open_uis[0]
	var/list/processing_uis = list()

/datum/nanomanager/New()
	return

/datum/nanomanager/proc/get_open_ui(var/mob/user, src_object, ui_key)
	var/src_object_key = "\ref[src_object]"
	if (isnull(open_uis[src_object_key]) || !istype(open_uis[src_object_key], /list))
		return null
	else if (isnull(open_uis[src_object_key][ui_key]) || !istype(open_uis[src_object_key][ui_key], /list))
		return null

	for (var/datum/nanoui/ui in open_uis[src_object_key][ui_key])
		if (ui.user == user)
			return ui

	return null
	
/datum/nanomanager/proc/update_uis(src_object)
	var/src_object_key = "\ref[src_object]"
	if (isnull(open_uis[src_object_key]) || !istype(open_uis[src_object_key], /list))
		return 0	

	var/update_count = 0
	for (var/ui_key in open_uis[src_object_key])			
		for (var/datum/nanoui/ui in open_uis[src_object_key][ui_key])
			if(ui && ui.src_object && ui.user)
				ui.process()
				update_count++
	return update_count

/datum/nanomanager/proc/ui_opened(var/datum/nanoui/ui)
	var/src_object_key = "\ref[ui.src_object]"
	if (isnull(open_uis[src_object_key]) || !istype(open_uis[src_object_key], /list))
		open_uis[src_object_key] = list(ui.ui_key = list())
	else if (isnull(open_uis[src_object_key][ui.ui_key]) || !istype(open_uis[src_object_key][ui.ui_key], /list))
		open_uis[src_object_key][ui.ui_key] = list();

	ui.user.open_uis.Add(ui)
	var/list/uis = open_uis[src_object_key][ui.ui_key]
	uis.Add(ui)
	processing_uis.Add(ui)

/datum/nanomanager/proc/ui_closed(var/datum/nanoui/ui)
	var/src_object_key = "\ref[ui.src_object]"
	if (isnull(open_uis[src_object_key]) || !istype(open_uis[src_object_key], /list))
		return 0 // wasn't open
	else if (isnull(open_uis[src_object_key][ui.ui_key]) || !istype(open_uis[src_object_key][ui.ui_key], /list))
		return 0 // wasn't open

	processing_uis.Remove(ui)
	ui.user.open_uis.Remove(ui)
	var/list/uis = open_uis[src_object_key][ui.ui_key]
	return uis.Remove(ui)

// user has logged out (or is switching mob) so close/clear all uis
/datum/nanomanager/proc/user_logout(var/mob/user)
	if (isnull(user.open_uis) || !istype(user.open_uis, /list) || open_uis.len == 0)
		return 0 // has no open uis

	for (var/datum/nanoui/ui in user.open_uis)
		ui.close();



