extends Node3D
class_name Component

var pins: Array[Node3D]


signal pin_connected(pin1: Pin, pin2: Pin)
signal pin_disconnected(pin1: Pin, pin2: Pin)
func on_connect(pin1: Pin, pin2: Pin):
	CircuitManager.connect_pin(pin1.id, pin2.id)
	
func on_disconnect(pin1: Pin, pin2: Pin):
	CircuitManager.disconnect_pin(pin1.id, pin2.id)

## Returns the current to subtract/add from the residual guess.
## THIS FUNCTION SHOULD HANDLE CHANGING OF THE guess VARIABLE
## guess: the current guess voltage
## pins: the mapping of each pin
func output(guess: PackedFloat64Array, residual: PackedFloat64Array, pin_map: Dictionary) -> void:
	# Do stuff here.

	pass
	
func jacobian(guess: PackedFloat64Array, jacobian: PackedFloat64Array, residual, pin_map: Dictionary) -> void:
	# Do stuff here.

	pass	
# Called when the node enters the scene tree for the first time.
func _ready():
	pin_connected.connect(on_connect)

	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
