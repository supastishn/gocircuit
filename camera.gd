extends Camera3D
@export var sensitivity: float = 0.005
@export var min_pitch_degrees: float = -89.9
@export var max_pitch_degrees: float = 89.9
var active_drag_index: int = -1
var is_mouse_dragging: bool = false
var yaw: float = 0.0
var pitch: float = 0.0
func _ready() -> void:
	yaw = rotation.y
	pitch = rotation.x
func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		active_drag_index = -1
		is_mouse_dragging = false
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			if active_drag_index == -1 and not _is_touch_on_ui(event.position):
				active_drag_index = event.index
		elif event.index == active_drag_index:
			active_drag_index = -1
	elif event is InputEventScreenDrag:
		if event.index == active_drag_index:
			_rotate_camera(event.relative)
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if active_drag_index == -1 and not _is_touch_on_ui(event.position):
					is_mouse_dragging = true
			else:
				is_mouse_dragging = false
	elif event is InputEventMouseMotion:
		if is_mouse_dragging and active_drag_index == -1:
			_rotate_camera(event.relative)
func _rotate_camera(relative: Vector2) -> void:
	yaw -= relative.x * sensitivity
	pitch = clampf(pitch - relative.y * sensitivity, deg_to_rad(min_pitch_degrees), deg_to_rad(max_pitch_degrees))
	rotation = Vector3(pitch, yaw, 0.0)
func _is_touch_on_ui(screen_pos: Vector2) -> bool:
	var viewport_rect: Rect2 = get_viewport().get_visible_rect()
	var root_node: Window = get_tree().root
	var touch_buttons: Array[Node] = root_node.find_children("*", "TouchScreenButton", true, false)
	for button_node in touch_buttons:
		var touch_button := button_node as TouchScreenButton
		if touch_button and touch_button.is_visible_in_tree():
			var local_pos: Vector2 = touch_button.get_global_transform_with_canvas().affine_inverse() * screen_pos
			if touch_button.texture_normal:
				var texture_rect := Rect2(Vector2.ZERO, touch_button.texture_normal.get_size())
				if texture_rect.has_point(local_pos):
					return true
			elif touch_button.shape:
				if touch_button.shape is CircleShape2D:
					if local_pos.length() <= (touch_button.shape as CircleShape2D).radius:
						return true
				elif touch_button.shape is RectangleShape2D:
					var rect_shape := touch_button.shape as RectangleShape2D
					var half_size: Vector2 = rect_shape.size * 0.5
					if Rect2(-half_size, rect_shape.size).has_point(local_pos):
						return true
	var control_nodes: Array[Node] = root_node.find_children("*", "Control", true, false)
	for control_node in control_nodes:
		var control := control_node as Control
		if not control or not control.is_visible_in_tree():
			continue
		if control is BaseButton:
			if control.get_global_rect().has_point(screen_pos):
				return true
		var control_name_lower: String = control.name.to_lower()
		var control_class_name: String = control.get_class()
		if control_name_lower.contains("joystick") or control_class_name == "VirtualJoystick":# or control is VirtualJoystickDX:
			if control.get_global_rect().has_point(screen_pos):
				return true
			var radius_variant: Variant = control.get("joystick_radius")
			if radius_variant != null:
				var joystick_radius: float = float(radius_variant)
				var joystick_center: Vector2 = control.global_position + Vector2(joystick_radius, joystick_radius)
				if screen_pos.distance_to(joystick_center) <= joystick_radius * 1.5:
					return true
		if control.mouse_filter == Control.MOUSE_FILTER_STOP:
			var control_rect: Rect2 = control.get_global_rect()
			if control_rect.size.x < viewport_rect.size.x * 0.95 or control_rect.size.y < viewport_rect.size.y * 0.95:
				if control_rect.has_point(screen_pos):
					return true
	return false
