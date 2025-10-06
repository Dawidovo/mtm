# ============================================================================
# BASE_PANEL.GD - Wiederverwendbare Panel-Komponente
# Pfad: scripts/ui/components/base_panel.gd
# ============================================================================
extends PanelContainer
class_name BasePanel

signal panel_shown
signal panel_hidden
signal close_requested

@export_group("Panel Settings")
@export var panel_title: String = "Panel Title"
@export var show_close_button: bool = true
@export var closable_by_escape: bool = true
@export var show_title_bar: bool = true
@export var can_drag: bool = false

@export_group("Animation")
@export var fade_duration: float = 0.2
@export var slide_in: bool = false

var is_open: bool = false
var drag_offset: Vector2 = Vector2.ZERO
var is_dragging: bool = false

func _ready():
	setup_structure()
	apply_theme()
	
	if not visible:
		modulate.a = 0
		is_open = false

func setup_structure():
	# Erstelle Struktur wenn nicht vorhanden
	if get_child_count() == 0:
		var margin = MarginContainer.new()
		margin.name = "MarginContainer"
		add_child(margin)
		margin.add_theme_constant_override("margin_left", 15)
		margin.add_theme_constant_override("margin_right", 15)
		margin.add_theme_constant_override("margin_top", 10)
		margin.add_theme_constant_override("margin_bottom", 15)
		
		var vbox = VBoxContainer.new()
		vbox.name = "VBoxContainer"
		margin.add_child(vbox)
		
		if show_title_bar:
			create_title_bar(vbox)
		
		var content = VBoxContainer.new()
		content.name = "ContentContainer"
		content.size_flags_vertical = Control.SIZE_EXPAND_FILL
		vbox.add_child(content)

func create_title_bar(parent: Control):
	var title_bar = HBoxContainer.new()
	title_bar.name = "TitleBar"
	parent.add_child(title_bar)
	
	var title = Label.new()
	title.name = "TitleLabel"
	title.text = panel_title
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_bar.add_child(title)
	
	if show_close_button:
		var close = Button.new()
		close.name = "CloseButton"
		close.text = "×"
		close.custom_minimum_size = Vector2(40, 40)
		close.add_theme_font_size_override("font_size", 32)
		close.pressed.connect(_on_close_pressed)
		title_bar.add_child(close)
	
	var separator = HSeparator.new()
	separator.name = "Separator"
	parent.add_child(separator)
	parent.move_child(separator, 1)

func apply_theme():
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.149, 0.149, 0.2, 0.95)
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.border_color = Color(0.8, 0.6, 0.2, 1.0)
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	style.shadow_size = 8
	style.shadow_color = Color(0, 0, 0, 0.3)
	add_theme_stylebox_override("panel", style)

func show_panel():
	visible = true
	is_open = true
	
	if fade_duration > 0:
		var tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_CUBIC)
		
		if slide_in:
			var start_pos = position
			position.y -= 50
			tween.parallel().tween_property(self, "position", start_pos, fade_duration)
		
		tween.tween_property(self, "modulate:a", 1.0, fade_duration)
		await tween.finished
	else:
		modulate.a = 1.0
	
	panel_shown.emit()

func hide_panel():
	if fade_duration > 0:
		var tween = create_tween()
		tween.set_ease(Tween.EASE_IN)
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(self, "modulate:a", 0.0, fade_duration * 0.5)
		await tween.finished
	
	visible = false
	is_open = false
	panel_hidden.emit()

func _on_close_pressed():
	close_requested.emit()
	hide_panel()

func _input(event):
	if not is_open or not closable_by_escape:
		return
	
	if event.is_action_pressed("ui_cancel"):
		_on_close_pressed()
		get_viewport().set_input_as_handled()

func get_content_container() -> Container:
	return $MarginContainer/VBoxContainer/ContentContainer if has_node("MarginContainer/VBoxContainer/ContentContainer") else null


# ============================================================================
# TAB_CONTAINER_CUSTOM.GD - Erweiterte Tab-Komponente
# Pfad: scripts/ui/components/tab_container_custom.gd
# ============================================================================
class_name TabContainerCustom
extends Control

signal tab_changed(tab_index: int, tab_name: String)

@export var tab_height: int = 50
@export var tab_min_width: int = 150
@export var default_tab: int = 0

var tabs: Array[Dictionary] = []
var current_tab: int = -1
var tab_buttons: Array[Button] = []

@onready var tab_bar: HBoxContainer
@onready var content: Control

func _ready():
	setup_ui()
	if tabs.size() > 0:
		switch_to_tab(default_tab)

func setup_ui():
	# Tab Bar erstellen
	tab_bar = HBoxContainer.new()
	tab_bar.name = "TabBar"
	tab_bar.custom_minimum_size.y = tab_height
	add_child(tab_bar)
	
	# Content Container
	content = Control.new()
	content.name = "Content"
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.anchor_right = 1.0
	content.anchor_bottom = 1.0
	content.offset_top = tab_height
	add_child(content)

func add_tab(tab_name: String, content_scene: Control) -> int:
	var tab_data = {
		"name": tab_name,
		"content": content_scene,
		"button": null
	}
	
	tabs.append(tab_data)
	var tab_index = tabs.size() - 1
	
	# Tab-Button erstellen
	var btn = Button.new()
	btn.text = tab_name
	btn.custom_minimum_size = Vector2(tab_min_width, tab_height)
	btn.toggle_mode = false
	btn.pressed.connect(_on_tab_pressed.bind(tab_index))
	
	_style_tab_button(btn, false)
	
	tab_bar.add_child(btn)
	tab_buttons.append(btn)
	tab_data.button = btn
	
	# Content hinzufügen
	content_scene.visible = false
	content.add_child(content_scene)
	content_scene.anchor_right = 1.0
	content_scene.anchor_bottom = 1.0
	content_scene.offset_left = 0
	content_scene.offset_top = 0
	content_scene.offset_right = 0
	content_scene.offset_bottom = 0
	
	# Ersten Tab aktivieren
	if tabs.size() == 1:
		switch_to_tab(0)
	
	return tab_index

func switch_to_tab(tab_index: int):
	if tab_index < 0 or tab_index >= tabs.size():
		return
	
	if current_tab == tab_index:
		return
	
	# Alten Tab ausblenden
	if current_tab >= 0:
		tabs[current_tab].content.visible = false
		_style_tab_button(tab_buttons[current_tab], false)
	
	# Neuen Tab einblenden
	current_tab = tab_index
	tabs[current_tab].content.visible = true
	_style_tab_button(tab_buttons[current_tab], true)
	
	tab_changed.emit(tab_index, tabs[tab_index].name)

func _on_tab_pressed(tab_index: int):
	switch_to_tab(tab_index)

func _style_tab_button(button: Button, active: bool):
	var style = StyleBoxFlat.new()
	
	if active:
		style.bg_color = Color(0.3, 0.25, 0.35, 1.0)
		style.border_width_bottom = 4
		style.border_color = Color(0.8, 0.6, 0.2, 1.0)
		button.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	else:
		style.bg_color = Color(0.2, 0.2, 0.25, 1.0)
		style.border_width_bottom = 2
		style.border_color = Color(0.4, 0.4, 0.45, 1.0)
		button.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7, 1))
	
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_stylebox_override("hover", style)
	button.add_theme_stylebox_override("pressed", style)

func get_current_tab_index() -> int:
	return current_tab

func get_tab_content(tab_index: int) -> Control:
	if tab_index >= 0 and tab_index < tabs.size():
		return tabs[tab_index].content
	return null


# ============================================================================
# LIST_COMPONENT.GD - Wiederverwendbare Liste mit Filter/Sort
# Pfad: scripts/ui/components/list_component.gd
# ============================================================================
class_name ListComponent
extends VBoxContainer

signal item_selected(item_data: Dictionary)
signal item_double_clicked(item_data: Dictionary)

@export var item_height: int = 80
@export var show_search: bool = true
@export var show_sort: bool = true
@export var alternating_colors: bool = true

var items: Array[Dictionary] = []
var filtered_items: Array[Dictionary] = []
var sort_key: String = ""
var sort_ascending: bool = true

@onready var search_box: LineEdit
@onready var sort_button: OptionButton
@onready var scroll_container: ScrollContainer
@onready var item_container: VBoxContainer

func _ready():
	setup_ui()

func setup_ui():
	# Search Box
	if show_search:
		var search_hbox = HBoxContainer.new()
		add_child(search_hbox)
		
		var search_label = Label.new()
		search_label.text = "🔍 Search:"
		search_hbox.add_child(search_label)
		
		search_box = LineEdit.new()
		search_box.placeholder_text = "Type to search..."
		search_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		search_box.text_changed.connect(_on_search_changed)
		search_hbox.add_child(search_box)
	
	# Sort Options
	if show_sort:
		sort_button = OptionButton.new()
		sort_button.add_item("Name ↑")
		sort_button.add_item("Name ↓")
		sort_button.add_item("Value ↑")
		sort_button.add_item("Value ↓")
		sort_button.item_selected.connect(_on_sort_changed)
		add_child(sort_button)
	
	# Scroll Container
	scroll_container = ScrollContainer.new()
	scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(scroll_container)
	
	# Item Container
	item_container = VBoxContainer.new()
	item_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_container.add_child(item_container)

func add_item(item_data: Dictionary):
	items.append(item_data)
	_refresh_list()

func set_items(new_items: Array):
	items.clear()
	for item in new_items:
		items.append(item)
	_refresh_list()

func clear_items():
	items.clear()
	_refresh_list()

func _refresh_list():
	# Alte Items entfernen
	for child in item_container.get_children():
		child.queue_free()
	
	# Filter anwenden
	filtered_items = items.duplicate()
	if show_search and search_box and search_box.text != "":
		var search_term = search_box.text.to_lower()
		filtered_items = filtered_items.filter(func(item):
			return item.get("name", "").to_lower().contains(search_term)
		)
	
	# Sort anwenden
	if sort_key != "":
		filtered_items.sort_custom(func(a, b):
			var val_a = a.get(sort_key, "")
			var val_b = b.get(sort_key, "")
			if sort_ascending:
				return val_a < val_b
			else:
				return val_a > val_b
		)
	
	# Items erstellen
	for i in range(filtered_items.size()):
		var item = filtered_items[i]
		var item_panel = _create_item_panel(item, i)
		item_container.add_child(item_panel)

func _create_item_panel(item_data: Dictionary, index: int) -> Control:
	var panel = PanelContainer.new()
	panel.custom_minimum_size.y = item_height
	
	# Alternierende Farben
	var style = StyleBoxFlat.new()
	if alternating_colors and index % 2 == 0:
		style.bg_color = Color(0.2, 0.2, 0.25, 1.0)
	else:
		style.bg_color = Color(0.15, 0.15, 0.2, 1.0)
	panel.add_theme_stylebox_override("panel", style)
	
	# Button für Interaktion
	var button = Button.new()
	button.flat = true
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	panel.add_child(button)
	
	# Content
	var hbox = HBoxContainer.new()
	button.add_child(hbox)
	
	# Icon (wenn vorhanden)
	if item_data.has("icon"):
		var icon = TextureRect.new()
		icon.custom_minimum_size = Vector2(60, 60)
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		# icon.texture = item_data.icon
		hbox.add_child(icon)
	
	# Text Content
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(vbox)
	
	var name_label = Label.new()
	name_label.text = item_data.get("name", "Unknown")
	name_label.add_theme_font_size_override("font_size", 18)
	name_label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	vbox.add_child(name_label)
	
	if item_data.has("description"):
		var desc_label = Label.new()
		desc_label.text = item_data.description
		desc_label.add_theme_font_size_override("font_size", 14)
		desc_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7, 1))
		vbox.add_child(desc_label)
	
	# Value (rechts)
	if item_data.has("value"):
		var value_label = Label.new()
		value_label.text = str(item_data.value)
		value_label.add_theme_font_size_override("font_size", 20)
		value_label.add_theme_color_override("font_color", Color(0.8, 0.6, 0.2, 1))
		hbox.add_child(value_label)
	
	# Signals
	button.pressed.connect(func(): item_selected.emit(item_data))
	
	return panel

func _on_search_changed(new_text: String):
	_refresh_list()

func _on_sort_changed(index: int):
	match index:
		0: sort_key = "name"; sort_ascending = true
		1: sort_key = "name"; sort_ascending = false
		2: sort_key = "value"; sort_ascending = true
		3: sort_key = "value"; sort_ascending = false
	_refresh_list()


# ============================================================================
# CHOICE_DIALOG.GD - Event-Entscheidungsdialog
# Pfad: scripts/ui/components/choice_dialog.gd
# ============================================================================
class_name ChoiceDialog
extends BasePanel

signal choice_made(choice_index: int)

var choices: Array = []
var choice_buttons: Array[Button] = []

@onready var description_label: RichTextLabel
@onready var choices_container: VBoxContainer

func _ready():
	super._ready()
	panel_title = "Make a Decision"
	setup_choice_ui()

func setup_choice_ui():
	var content = get_content_container()
	if not content:
		return
	
	# Description
	description_label = RichTextLabel.new()
	description_label.bbcode_enabled = true
	description_label.fit_content = true
	description_label.custom_minimum_size.y = 100
	description_label.add_theme_font_size_override("normal_font_size", 16)
	content.add_child(description_label)
	
	var spacer = Control.new()
	spacer.custom_minimum_size.y = 20
	content.add_child(spacer)
	
	# Choices Container
	choices_container = VBoxContainer.new()
	choices_container.add_theme_constant_override("separation", 10)
	content.add_child(choices_container)

func set_event_data(event_title: String, event_description: String, event_choices: Array):
	panel_title = event_title
	if has_node("MarginContainer/VBoxContainer/TitleBar/HBoxContainer/TitleLabel"):
		$MarginContainer/VBoxContainer/TitleBar/HBoxContainer/TitleLabel.text = event_title
	
	description_label.text = event_description
	choices = event_choices
	
	# Alte Buttons entfernen
	for btn in choice_buttons:
		btn.queue_free()
	choice_buttons.clear()
	
	# Neue Choice-Buttons erstellen
	for i in range(choices.size()):
		var choice = choices[i]
		var choice_btn = _create_choice_button(choice, i)
		choices_container.add_child(choice_btn)
		choice_buttons.append(choice_btn)

func _create_choice_button(choice: EventChoice, index: int) -> Button:
	var btn = Button.new()
	btn.custom_minimum_size.y = 80
	btn.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	
	var label_text = "[b]%s[/b]\n%s" % [choice.label, choice.description]
	
	# Requirements prüfen
	var available = true  # Simplified, sollte eigentlich game_state prüfen
	if choice.required_money > 0:
		label_text += "\n💰 Costs: $%d" % choice.required_money
	
	btn.text = label_text
	
	if not available:
		btn.disabled = true
		btn.tooltip_text = "Requirements not met"
	
	# Styling
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.25, 0.2, 0.3, 1.0)
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.8, 0.6, 0.2, 1.0)
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	btn.add_theme_stylebox_override("normal", style)
	
	var hover_style = style.duplicate()
	hover_style.bg_color = Color(0.3, 0.25, 0.35, 1.0)
	btn.add_theme_stylebox_override("hover", hover_style)
	
	btn.pressed.connect(_on_choice_pressed.bind(index))
	
	return btn

func _on_choice_pressed(choice_index: int):
	choice_made.emit(choice_index)
	hide_panel()


# ============================================================================
# NOTIFICATION_SYSTEM.GD - Toast Notifications
# Pfad: scripts/ui/components/notification_system.gd
# ============================================================================
class_name NotificationSystem
extends CanvasLayer

enum NotificationType {
	INFO,
	SUCCESS,
	WARNING,
	ERROR
}

var notification_queue: Array[Dictionary] = []
var active_notifications: Array[Control] = []
var max_notifications: int = 5

func _ready():
	layer = 100  # Über allem

func show_notification(message: String, type: NotificationType = NotificationType.INFO, duration: float = 3.0):
	var notification_data = {
		"message": message,
		"type": type,
		"duration": duration
	}
	
	notification_queue.append(notification_data)
	_process_queue()

func _process_queue():
	if notification_queue.is_empty():
		return
	
	if active_notifications.size() >= max_notifications:
		return
	
	var data = notification_queue.pop_front()
	var notification = _create_notification(data)
	add_child(notification)
	active_notifications.append(notification)
	
	_animate_notification(notification, data.duration)

func _create_notification(data: Dictionary) -> Control:
	var panel = PanelContainer.new()
	panel.custom_minimum_size = Vector2(300, 60)
	
	# Position oben rechts
	panel.anchor_left = 1.0
	panel.anchor_right = 1.0
	panel.offset_left = -320
	panel.offset_right = -20
	panel.offset_top = 20 + (active_notifications.size() * 70)
	
	# Styling basierend auf Type
	var style = StyleBoxFlat.new()
	match data.type:
		NotificationType.INFO:
			style.bg_color = Color(0.2, 0.4, 0.6, 0.95)
		NotificationType.SUCCESS:
			style.bg_color = Color(0.2, 0.6, 0.3, 0.95)
		NotificationType.WARNING:
			style.bg_color = Color(0.8, 0.6, 0.2, 0.95)
		NotificationType.ERROR:
			style.bg_color = Color(0.8, 0.2, 0.2, 0.95)
	
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.shadow_size = 4
	style.shadow_color = Color(0, 0, 0, 0.5)
	panel.add_theme_stylebox_override("panel", style)
	
	var label = Label.new()
	label.text = data.message
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	panel.add_child(label)
	
	return panel

func _animate_notification(notification: Control, duration: float):
	# Slide in
	var start_x = notification.offset_left
	notification.offset_left += 50
	notification.modulate.a = 0
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(notification, "offset_left", start_x, 0.3)
	tween.tween_property(notification, "modulate:a", 1.0, 0.3)
	
	# Wait
	await get_tree().create_timer(duration).timeout
	
	# Slide out
	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(notification, "offset_left", start_x + 50, 0.3)
	tween.tween_property(notification, "modulate:a", 0.0, 0.3)
	await tween.finished
	
	active_notifications.erase(notification)
	notification.queue_free()
	
	# Nächste Notification
	if not notification_queue.is_empty():
		_process_queue()
