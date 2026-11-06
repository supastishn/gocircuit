extends Node

## Sparse Matrix Vector multiplication 
## Dimensions will automaticsllybe figured out from vector
## Passing in improper matrix/vector makes everything break. Try not to do that.
func smvm(sparse_keys: PackedInt32Array, sparse_values: PackedFloat64Array, vector: PackedFloat64Array, output: PackedFloat64Array):
	var shared := vector.size() # one row = shared
	for key in sparse_keys:
		var value := sparse_values[key]
		var row := key/shared
		var col := key%shared
		
		output[row] += value * vector[col]
		
		
# TODO: add sparse solving via eigen+gdextension
# This uses dense gaussian elimination which is O(n³)
# Circuits above ~500 nodes will lag noticeably

func dense_GE()


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
