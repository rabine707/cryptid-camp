extends Control

var visitors: Array = []

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
	welcome.add_theme_stylebox_override("panel", CampStyle.panel(CampStyle.PAPER,14,3,CampStyle.WOOD))
	page.add_child(welcome)
	var welcome_row := HBoxContainer.new()
	welcome.add_child(welcome_row)
	var greeting := _label(_daypart()+" at Camp", 27, CampStyle.INK)
	greeting.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	welcome_row.add_child(greeting)
	welcome_row.add_child(_label("%d / 48 discovered" % GameState.state.get("discovered_species",[]).size(),22,Color("5c4937")))

	var world := PanelContainer.new()
	world.custom_minimum_size.y = 850
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
		empty.set_anchors_preset(Control.PRESET_CENTER_WIDE)
		empty.offset_top=-80; empty.offset_bottom=40
		layer.add_child(empty)
		var go:=_button("Explore Whispering Woods","green")
		go.set_anchors_preset(Control.PRESET_CENTER)
		go.position=Vector2(-230,70); go.custom_minimum_size=Vector2(460,100)
		go.pressed.connect(_open_woods); layer.add_child(go)
	else:
		var spots=[Vector2(.20,.64),Vector2(.48,.70),Vector2(.76,.61),Vector2(.52,.36)]
		for i in range(mini(visitors.size(),4)): _add_visitor(layer,visitors[i],spots[i],i)

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
	var woods:=_button("Whispering Woods","wood"); woods.pressed.connect(_open_woods); quick.add_child(woods)
	var sanctuary:=_button("Sanctuary Areas","wood"); sanctuary.pressed.connect(_open_areas); quick.add_child(sanctuary)
	_add_build_badge()

func _add_visitor(layer:Control,c:Dictionary,pos:Vector2,index:int)->void:
	var resident:=VBoxContainer.new()
	resident.name="CampVisitor%d"%index
	resident.alignment=BoxContainer.ALIGNMENT_CENTER
	resident.anchor_left=pos.x; resident.anchor_right=pos.x
	resident.anchor_top=pos.y; resident.anchor_bottom=pos.y
	resident.position=Vector2(-105,-110)
	resident.custom_minimum_size=Vector2(210,220)
	var portrait:=TextureButton.new()
	portrait.ignore_texture_size=true
	portrait.stretch_mode=TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	portrait.custom_minimum_size=Vector2(210,165)
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
