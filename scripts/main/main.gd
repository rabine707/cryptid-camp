extends Control

var visitors: Array = []
const DAILY_ACTIVITY_COUNT := 6

func _ready() -> void:
	_build_home()

func _add_build_badge() -> void:
	var badge := _label("BUILD DEV", 16, Color("d8cda9"))
	badge.name = "BuildBadge"
	badge.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	badge.position = Vector2(-250, -42)
	badge.custom_minimum_size = Vector2(230, 28)
	badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	add_child(badge)

func _build_home() -> void:
	for child in get_children(): child.queue_free()
	var bg := TextureRect.new()
	bg.texture = ArtRegistry.texture_for("background.main_menu")
	bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	var shade := ColorRect.new()
	shade.color = Color(0.02,0.06,0.05,0.24)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(shade)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left","right"]: margin.add_theme_constant_override("margin_"+side, 24)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 22)
	add_child(margin)
	var page := VBoxContainer.new()
	page.add_theme_constant_override("separation", 12)
	margin.add_child(page)

	var header := HBoxContainer.new()
	page.add_child(header)
	var brand := _label("CRYPTID CAMP", 48, CampStyle.CREAM)
	brand.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(brand)
	var collection := _button("My Cryptids", "paper")
	collection.custom_minimum_size = Vector2(220,76)
	collection.pressed.connect(_open_areas)
	header.add_child(collection)

	var utility := HBoxContainer.new()
	utility.add_theme_constant_override("separation", 8)
	page.add_child(utility)
	for item in [["Camp","home"],["Explore","explore"],["Sanctuary","areas"],["Journal","journal"]]:
		var b := _button(item[0], "green" if item[1]=="home" else "wood")
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.custom_minimum_size.y = 78
		match item[1]:
			"explore": b.pressed.connect(_open_woods)
			"areas": b.pressed.connect(_open_areas)
			"journal": b.pressed.connect(_open_journal)
		utility.add_child(b)

	var welcome := PanelContainer.new()
	welcome.custom_minimum_size.y = 96
	welcome.add_theme_stylebox_override("panel", CampStyle.panel(CampStyle.PAPER,14,3,CampStyle.WOOD))
	page.add_child(welcome)
	var welcome_row := HBoxContainer.new()
	welcome_row.add_theme_constant_override("separation", 12)
	welcome.add_child(welcome_row)
	var greeting := _label(_daypart()+" at Camp", 27, CampStyle.INK)
	greeting.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	welcome_row.add_child(greeting)
	var progress := VBoxContainer.new()
	progress.custom_minimum_size.x = 250
	progress.alignment = BoxContainer.ALIGNMENT_CENTER
	welcome_row.add_child(progress)
	var discovered: int = int(GameState.state.get("discovered_species", []).size())
	var count := _label("%d / 48" % discovered, 25, CampStyle.INK)
	count.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	progress.add_child(count)
	var count_caption := _label("CRYPTIDS DISCOVERED", 15, Color("5c4937"))
	count_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	progress.add_child(count_caption)

	var world := PanelContainer.new()
	world.custom_minimum_size.y = 960
	world.size_flags_vertical = Control.SIZE_EXPAND_FILL
	world.add_theme_stylebox_override("panel",CampStyle.panel(Color(0.02,0.10,0.08,0.20),20,3,CampStyle.WOOD_LIGHT))
	page.add_child(world)
	var layer := Control.new()
	layer.clip_contents = true
	world.add_child(layer)
	var title := _label("CAMP CLEARING",25,CampStyle.GOLD)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.set_anchors_preset(Control.PRESET_TOP_WIDE)
	title.offset_top=16; title.offset_bottom=55
	layer.add_child(title)

	visitors=GameState.get_camp_visitors(4)
	if visitors.is_empty():
		var empty:=_label("The clearing is quiet.\nHead into the woods and see who is out there.",32,CampStyle.CREAM)
		empty.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
		empty.set_anchors_preset(Control.PRESET_CENTER_TOP)
		empty.anchor_left = 0.0
		empty.anchor_right = 1.0
		empty.offset_top=-80; empty.offset_bottom=40
		layer.add_child(empty)
		var go:=_button("Explore Whispering Woods","green")
		go.set_anchors_preset(Control.PRESET_CENTER)
		go.position=Vector2(-230,70); go.custom_minimum_size=Vector2(460,100)
		go.pressed.connect(_open_woods); layer.add_child(go)
	else:
		var spots=[Vector2(.20,.64),Vector2(.48,.70),Vector2(.76,.61),Vector2(.52,.36)]
		for i in range(mini(visitors.size(),4)): _add_visitor(layer,visitors[i],spots[i],i)
	_add_camp_hotspots(layer)

	var event_text := _maybe_random_event()
	if not event_text.is_empty():
		var event_card := _home_card("SOMETHING HAPPENED...", event_text)
		page.add_child(event_card)

	var bulletin := _home_card("CAMP BULLETIN", _camp_bulletin() + "\n\n" + _camp_progress_text())
	page.add_child(bulletin)

	var news := HBoxContainer.new()
	news.add_theme_constant_override("separation",10)
	page.add_child(news)
	var today:=_home_card("TODAY AT CAMP",_today_text())
	today.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	news.add_child(today)
	var quick:=VBoxContainer.new()
	quick.custom_minimum_size.x=290
	quick.add_theme_constant_override("separation",8)
	news.add_child(quick)
	var woods:=_button("Explore Woods","wood"); woods.pressed.connect(_open_woods); quick.add_child(woods)
	var sanctuary:=_button("Visit Sanctuary","wood"); sanctuary.pressed.connect(_open_areas); quick.add_child(sanctuary)

	var activities := HBoxContainer.new()
	activities.add_theme_constant_override("separation", 8)
	page.add_child(activities)
	for activity in [["Daily Check-In","checkin"],["Camp Chore","chore"],["Mystery Spot","mystery"],["Campfire Story","story"],["Resident Hangout","hangout"],["Lost & Found","lost"],["Trail Cam","trailcam"],["Curio Shelf","curios"],["Camp Mail","mail"]]:
		var activity_button := _button(activity[0], "paper")
		activity_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		activity_button.pressed.connect(_daily_activity.bind(activity[1]))
		activities.add_child(activity_button)

	var footer := HBoxContainer.new()
	footer.add_theme_constant_override("separation", 8)
	page.add_child(footer)
	var field_note := _button("Field Notes", "paper")
	field_note.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	field_note.pressed.connect(_open_journal)
	footer.add_child(field_note)
	var collection_note := _button("Resident Areas", "paper")
	collection_note.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	collection_note.pressed.connect(_open_areas)
	footer.add_child(collection_note)

	var wander := HBoxContainer.new()
	wander.add_theme_constant_override("separation", 8)
	page.add_child(wander)
	for place in [["Ranger Cabin","ranger"],["Creek Bank","creek"],["Old Stump","stump"],["Notice Board","board"]]:
		var place_button := _button(place[0], "wood")
		place_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		place_button.pressed.connect(_visit_camp_place.bind(place[1]))
		wander.add_child(place_button)
	_add_build_badge()

func _add_camp_hotspots(layer: Control) -> void:
	var spots := [
		["Trail Cam", "trailcam", Vector2(.10,.16)],
		["Lost & Found", "lost", Vector2(.72,.18)],
		["Campfire", "story", Vector2(.38,.80)]
	]
	for spot in spots:
		var button := _button(str(spot[0]), "paper")
		button.custom_minimum_size = Vector2(190, 62)
		button.anchor_left = spot[2].x
		button.anchor_right = spot[2].x
		button.anchor_top = spot[2].y
		button.anchor_bottom = spot[2].y
		button.position = Vector2(-80, 0)
		button.pressed.connect(_daily_activity.bind(str(spot[1])))
		layer.add_child(button)

func _visit_camp_place(place: String) -> void:
	var key := _today_key()
	var title := ""
	var body := ""
	match place:
		"ranger":
			title = "OLD RANGER CABIN"
			var notes := ["A hand-drawn map has three trails circled, but no explanation.", "A dusty field guide is open to a page about unexplained lights.", "Someone pinned a note here: Listen first. Follow second.", "A mug is still warm. Nobody is inside."]
			body = notes[abs(hash(key + place)) % notes.size()]
		"creek":
			title = "CREEK BANK"
			var creek := ["Tiny wet tracks vanish at the waterline.", "A smooth stone has been carefully placed on top of another.", "Something croaks once from beneath the reeds, then goes silent.", "The water is clear. Something small darts under a root."]
			body = creek[abs(hash(key + place)) % creek.size()]
		"stump":
			title = "THE OLD STUMP"
			var stump := ["There is a bottle cap tucked into a crack like an offering.", "Three scratches mark the bark. They look fresh.", "Someone—or something—has arranged acorns in a neat circle.", "Nothing happens. Somehow that feels suspicious."]
			body = stump[abs(hash(key + place)) % stump.size()]
		"board":
			title = "NOTICE BOARD"
			var discovered := int(GameState.state.get("discovered_species", []).size())
			var curios := int(GameState.state.get("curiosities", []).size())
			var moments := int(GameState.state.get("moments", []).size())
			body = "FIELD OFFICE TOTALS\nCryptids documented: %d / 48\nCurios recovered: %d\nCamp Moments: %d\n\nRumor of the day: %s" % [discovered, curios, moments, _daily_rumor()]
	_show_activity_popup(title, body)

func _daily_rumor() -> String:
	var rumors := ["Two knocks were heard beyond the eastern trail.", "The pond was perfectly still at sunrise.", "A lantern turned itself toward the woods overnight.", "Fresh tracks appeared beside the clearing.", "Something keeps moving stones near the old trail.", "A local swears something enormous crossed the moon."]
	return rumors[abs(hash(_today_key() + "world_rumor")) % rumors.size()]

func _maybe_random_event() -> String:
	var day_key := _today_key()
	var daily: Dictionary = GameState.state.get("daily_camp", {})
	var today: Dictionary = daily.get(day_key, {})
	if today.get("random_event_seen", false):
		return ""
	# Stable per day: roughly half of days have a surprise on the first visit.
	if abs(hash(day_key + "random_event")) % 100 >= 52:
		return ""
	var events := ["You find a strange feather snagged on the fence.", "Something rustles behind the supply shed. By the time you look, it is gone.", "A resident left a tiny object beside the campfire.", "Three unfamiliar footprints cross the path and stop abruptly.", "The camp lantern flickers twice even though there is no wind.", "A distant knock answers another from deeper in the woods."]
	today["random_event_seen"] = true
	daily[day_key] = today
	GameState.state["daily_camp"] = daily
	GameState.persist()
	return events[abs(hash(day_key + "event_text")) % events.size()]

func _daily_activity(kind: String) -> void:
	var day_key := _today_key()
	var daily: Dictionary = GameState.state.get("daily_camp", {})
	var today: Dictionary = daily.get(day_key, {})
	var title := ""
	var body := ""
	match kind:
		"checkin":
			title = "DAILY CHECK-IN"
			if today.get("checkin", false):
				body = "You already checked in today. The campfire is still warm."
			else:
				today["checkin"] = true
				body = "Checked in! Everyone at camp gets a little extra attention today."
		"chore":
			title = "CAMP CHORE"
			if today.get("chore", false):
				body = "Today's camp chore is already done. Nice work."
			else:
				today["chore"] = true
				var chores := ["Refill the lantern oil.", "Tidy the field notes.", "Gather fallen sticks by the fire.", "Check the trail cam batteries.", "Freshen the water by the dock."]
				body = chores[abs(hash(day_key)) % chores.size()] + "\nDone! A tiny everyday camp moment has been recorded."
				GameState.unlock_moment("daily_chore_" + day_key)
		"story":
			title = "CAMPFIRE STORY"
			var stories := ["A ranger once followed enormous footprints until they simply stopped.", "Three lanterns flickered in sequence even though there was no wind.", "Something huge surfaced on the lake, then the water went perfectly still.", "A traveler heard soft crying in the woods, but every trail led back to camp.", "For one minute every bird in the forest went silent. Then came a single knock."]
			body = stories[abs(hash(day_key + "story")) % stories.size()] + "\n\nA new story will be waiting tomorrow."
		"hangout":
			title = "RESIDENT HANGOUT"
			if visitors.is_empty():
				body = "The clearing is quiet. Befriend a cryptid and someone can hang out here."
			elif today.get("hangout", false):
				body = "You already spent some quality time with a resident today."
			else:
				today["hangout"] = true
				var friend: Dictionary = visitors[abs(hash(day_key + "friend")) % visitors.size()]
				body = "%s spends a while with you.\n%s\n\n+1 Trust" % [_name(friend), _visitor_blurb(friend)]
				GameState.change_trust(str(friend.get("id", "")), 1)
		"lost":
			title = "LOST & FOUND"
			if today.get("lost", false):
				body = "You already checked the Lost & Found today."
			else:
				today["lost"] = true
				var objects := ["bent bottle cap", "smooth striped stone", "old brass button", "tiny blue feather", "pinecone tied with red thread", "strangely warm marble", "piece of sea glass", "tiny rusted key"]
				var found: String = objects[abs(hash(day_key + "lost")) % objects.size()]
				var curios: Array = GameState.state.get("curiosities", [])
				if found not in curios: curios.append(found)
				GameState.state["curiosities"] = curios
				body = "You found a %s.\n\nAdded to Curios · %d collected" % [found, curios.size()]
		"trailcam":
			title = "TRAIL CAM"
			var sightings := ["Nothing but a raccoon staring directly into the lens.", "A pale shape crosses the very edge of frame.", "Two bright eyes appear much higher than expected.", "The camera caught branches moving with no visible animal.", "A resident wandered past and investigated the camera.", "One frame is completely washed out by a strange glow."]
			body = "Last night's camera card:\n\n" + sightings[abs(hash(day_key + "cam")) % sightings.size()]
			if not GameState.state.get("discovered_species", []).is_empty():
				body += "\n\nYour existing field notes may help explain it."
		"curios":
			title = "CURIO SHELF"
			var curios: Array = GameState.state.get("curiosities", [])
			if curios.is_empty():
				body = "The shelf is empty. Check Lost & Found each day and strange little objects will start collecting here."
			else:
				body = "%d curios collected\n\n• %s" % [curios.size(), "\n• ".join(curios)]
		"mail":
			title = "CAMP MAIL"
			var letters := ["RANGER NOTE\nHeard something knocking beyond the eastern trail. Didn't sound like a woodpecker.", "POSTCARD\nWish you were here. Something enormous moved under the lake this morning.", "FIELD OFFICE\nReminder: unusual tracks are evidence, not an invitation to chase things into the dark.", "ANONYMOUS NOTE\nYour lantern setup is visible from farther into the woods than you think.", "LOCAL TIP\nIf you hear crying near the wet trail, look for puddles before footprints."]
			body = letters[abs(hash(day_key + "mail")) % letters.size()] + "\n\nNew mail arrives with the next day."
		"mystery":
			title = "MYSTERY SPOT"
			if today.get("mystery", false):
				body = "You already investigated today's strange little spot."
			else:
				today["mystery"] = true
				var finds := ["Tiny tracks circle the edge of camp.", "Something shiny was tucked beneath a log.", "A few unfamiliar hairs cling to the fence.", "The lantern glass has a strange little handprint.", "Something moved the stones beside the path."]
				body = finds[abs(hash(day_key + "mystery")) % finds.size()] + "\nYou add the observation to today's camp notes."
	today["last_activity"] = kind
	daily[day_key] = today
	GameState.state["daily_camp"] = daily
	GameState.persist()
	_show_activity_popup(title, body)

func _open_chore_game(day_key: String, daily: Dictionary, today: Dictionary) -> void:
	if today.get("chore", false):
		_show_activity_popup("CAMP CHORE", "Today's camp chore is already done. Nice work.")
		return
	var chores := [
		{"name":"Gather Firewood","prompt":"The campfire is running low. Get three good pieces ready.","steps":["Pick up branch","Pick up log","Gather kindling"]},
		{"name":"Check Trail Cam","prompt":"The trail cam needs attention before tonight.","steps":["Open camera","Swap battery","Test flash"]},
		{"name":"Refill Lanterns","prompt":"The paths will be dark soon.","steps":["Fill dock lantern","Fill path lantern","Fill gate lantern"]},
		{"name":"Freshen the Pond","prompt":"The little water area needs some care.","steps":["Clear leaves","Refill basin","Set water dish"]},
		{"name":"Field Notes","prompt":"Get today's observation kit ready.","steps":["Sharpen pencil","Pack notebook","Mark the map"]}
	]
	var chore: Dictionary = chores[abs(hash(day_key)) % chores.size()]
	var panel := _home_card("CAMP CHORE · " + str(chore["name"]).to_upper(), str(chore["prompt"]))
	panel.name = "ChoreGame"
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.position = Vector2(-360, -300)
	panel.custom_minimum_size = Vector2(720, 600)
	var box: VBoxContainer = panel.get_child(0)
	var progress := _label("0 / 3 tasks complete", 21, Color("5c4937"))
	box.add_child(progress)
	var completed: Array = []
	for step in chore["steps"]:
		var task := _button(str(step), "paper")
		task.pressed.connect(_complete_chore_step.bind(task, str(step), completed, progress, panel, day_key, daily, today))
		box.add_child(task)
	var cancel := _button("Back to Camp", "wood")
	cancel.pressed.connect(panel.queue_free)
	box.add_child(cancel)
	add_child(panel)

func _complete_chore_step(button: Button, step: String, completed: Array, progress: Label, panel: PanelContainer, day_key: String, daily: Dictionary, today: Dictionary) -> void:
	if step in completed: return
	completed.append(step)
	button.text = "Done · " + step
	button.disabled = true
	progress.text = "%d / 3 tasks complete" % completed.size()
	if completed.size() < 3: return
	today["chore"] = true
	today["last_activity"] = "chore"
	daily[day_key] = today
	GameState.state["daily_camp"] = daily
	GameState.unlock_moment("daily_chore_" + day_key)
	GameState.persist()
	panel.queue_free()
	_show_activity_popup("CHORE COMPLETE", "Camp is ready for the day. You recorded a new everyday Camp Moment.")

func _camp_progress_text() -> String:
	var daily: Dictionary = GameState.state.get("daily_camp", {})
	var today: Dictionary = daily.get(_today_key(), {})
	var keys := ["checkin","chore","mystery","hangout","lost"]
	var done := 0
	for key in keys:
		if today.get(key, false): done += 1
	return "%d / %d daily discoveries complete" % [done, keys.size()]

func _camp_bulletin() -> String:
	var key := _today_key()
	var lines: Array[String] = []
	if not visitors.is_empty():
		var friend: Dictionary = visitors[abs(hash(key + "bulletin_friend")) % visitors.size()]
		lines.append("%s: %s" % [_name(friend), _visitor_blurb(friend)])
	var evidence: Dictionary = GameState.state.get("evidence", {})
	if not evidence.is_empty():
		lines.append("Field desk: New observations are waiting in your Journal.")
	else:
		lines.append("Field desk: The woods have been unusually quiet. A fresh setup might change that.")
	lines.append("Rumor: " + _daily_rumor())
	return "\n".join(lines)

func _show_activity_popup(title: String, body: String) -> void:
	var old := get_node_or_null("DailyActivityPopup")
	if old != null:
		old.queue_free()
	var panel := _home_card(title, body)
	panel.name = "DailyActivityPopup"
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.position = Vector2(-360, -210)
	panel.custom_minimum_size = Vector2(720, 420)
	var close := _button("Back to Camp", "wood")
	close.pressed.connect(panel.queue_free)
	panel.get_child(0).add_child(close)
	add_child(panel)

func _today_key() -> String:
	var date := Time.get_date_dict_from_system()
	return "%04d-%02d-%02d" % [int(date.get("year", 0)), int(date.get("month", 0)), int(date.get("day", 0))]

func _add_visitor(layer:Control,c:Dictionary,pos:Vector2,index:int)->void:
	var resident:=VBoxContainer.new()
	resident.name="CampVisitor%d"%index
	resident.alignment=BoxContainer.ALIGNMENT_CENTER
	resident.anchor_left=pos.x; resident.anchor_right=pos.x
	resident.anchor_top=pos.y; resident.anchor_bottom=pos.y
	resident.position=Vector2(-105,-110)
	resident.custom_minimum_size=Vector2(230,235)
	var portrait:=TextureButton.new()
	portrait.ignore_texture_size=true
	portrait.stretch_mode=TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	portrait.custom_minimum_size=Vector2(230,180)
	portrait.texture_normal=_cryptid_texture(c)
	portrait.pressed.connect(_visitor_tapped.bind(c))
	resident.add_child(portrait)
	var n:=_label(_name(c),27,CampStyle.CREAM); n.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; resident.add_child(n)
	var s:=_label(_species(c),19,Color("ead49d")); s.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER; resident.add_child(s)
	layer.add_child(resident)

func _visitor_tapped(c:Dictionary)->void:
	var panel:=_home_card(_name(c).to_upper(),"%s · Trust %d\n%s" % [_species(c),int(c.get("trust",0)),_visitor_blurb(c)])
	panel.name="VisitorPopup"
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.position=Vector2(-360,-170)
	panel.custom_minimum_size=Vector2(720,340)
	var close:=_button("Close","paper"); close.pressed.connect(panel.queue_free)
	panel.get_child(0).add_child(close)
	add_child(panel)

func _visitor_blurb(c:Dictionary)->String:
	match str(c.get("species","")):
		"mothling": return "Seems very interested in the camp lights tonight."
		"froglet": return "Looks happiest near anything damp."
		"sprigfoot": return "Has been collecting little sticks around camp."
		"stilts": return "Keeps wandering along the edge of the clearing."
		"squonk": return "Left another tiny puddle behind."
	return "Looks comfortable here at camp."

func _cryptid_texture(c:Dictionary)->Texture2D:
	var species:=str(c.get("species","")).to_lower()
	var variant:=str(c.get("variant","classic")).to_lower()
	var t:=ArtRegistry.texture_for("cryptid.%s.%s"%[species,variant])
	if t==null:t=ArtRegistry.texture_for("cryptid.%s.classic"%species)
	return t

func _home_card(title:String,body:String)->PanelContainer:
	var p:=PanelContainer.new(); p.add_theme_stylebox_override("panel",CampStyle.panel(CampStyle.PAPER,14,3,CampStyle.WOOD))
	var b:=VBoxContainer.new(); b.add_theme_constant_override("separation",5); p.add_child(b)
	b.add_child(_label(title,23,CampStyle.INK)); b.add_child(_label(body,21,Color("4d4334")))
	return p

func _today_text()->String:
	if GameState.needs_first_hunt(): return "Your Trail Cam is waiting. Try a lantern in Whispering Woods."
	var evidence:Dictionary=GameState.state.get("evidence",{})
	var moments:Array=GameState.state.get("moments",[])
	if not moments.is_empty(): return "You have %d camp moment%s recorded in your journal."%[moments.size(),"" if moments.size()==1 else "s"]
	if not evidence.is_empty(): return "Your field notes are growing. Check the Journal for new clues."
	return "The woods change with every setup. Try something different tonight."

func _daypart()->String:
	var h:=int(Time.get_datetime_dict_from_system().get("hour",12))
	if h<12:return "Morning"
	if h<17:return "Afternoon"
	return "Tonight"

func _name(c:Dictionary)->String:
	var n:=str(c.get("name","")).strip_edges()
	return n if not n.is_empty() else _species(c)

func _species(c:Dictionary)->String:
	return str(c.get("species","Cryptid")).replace("_"," ").capitalize()

func _label(value:String,size:int,color:=CampStyle.CREAM)->Label:
	var l:=Label.new(); l.text=value; l.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	l.add_theme_font_size_override("font_size",size); l.add_theme_color_override("font_color",color); return l

func _button(value:String,kind:="wood")->Button:
	var b:=Button.new(); b.text=value; b.custom_minimum_size.y=74; CampStyle.button(b,kind); b.add_theme_font_size_override("font_size",23); return b

func _open_woods()->void:get_tree().change_scene_to_file("res://scenes/lure_sites/whispering_woods.tscn")
func _open_areas()->void:get_tree().change_scene_to_file("res://scenes/sanctuary/area_selector.tscn")
func _open_journal()->void:get_tree().change_scene_to_file("res://scenes/journal/journal.tscn")
