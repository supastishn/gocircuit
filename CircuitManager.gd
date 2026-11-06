extends Node


class DSU extends RefCounted:
	var parents: Dictionary = {}
	var rank: Dictionary = {}

	func find(x: Variant) -> Variant:
		if not parents.has(x):
			parents[x] = x
			rank[x] = 0
			return x
		if parents[x] != x:
			parents[x] = find(parents[x])
		return parents[x]

	func union(x: Variant, y: Variant) -> bool:
		var root_x: Variant = find(x)
		var root_y: Variant = find(y)
		if root_x == root_y:
			return false
		if rank[root_x] < rank[root_y]:
			var temp = root_y
			root_y = root_x
			root_x = temp
		parents[root_y] = root_x
		if rank[root_x] == rank[root_y]:
			rank[root_x] += 1
		return true	
	



var connections: Array[Array] # represents which pins connected to which others.
func reset():
	jacobian.clear()
	pass

## Connects two pins.
func connect_pin(pin1: int, pin2: int):
	if (not pin2 in connections[pin1]):
		connections[pin1].append(pin2)
	# jus in case something weird japoen
	if (not pin1 in connections[pin2]):
		connections[pin2].append(pin1)
		
## Disconnects two pins.
func disconnect_pin(pin1: int, pin2: int):
	# my codeforces brain is like "THIS IS BAD! O(N)" but eh
	if (pin2 in connections[pin1]):
		connections[pin1].erase(pin2)
	if (pin1 in connections[pin2]):
		connections[pin2].erase(pin1)

var global_dsu := DSU.new()
## Prepares the graph. In this model a "node" is considered all locations where voltage is the same , NOT every individual component
func prepare_nodes():
	global_dsu = DSU.new()
	for i in range(connections.size()):
		for j in range(connections[i].size()):
			global_dsu.union(i, j)
			
var jacobian: Dictionary[int,float]
var guess: PackedFloat64Array
var cache: Dictionary
# maps all roots 
# var roots: Dictionary

## Counts number of connected components. and assembles the Jacobian matrix.
## In this model a "node/vertex/component" is considered all locations where voltage is the same , NOT every individual component
## If clear cache is true, the DSU cache will be erased

func prepare_jacobian(clear_cache: bool = true):
	if clear_cache: cache.clear()
	var num_components:= 0
	for key in global_dsu.parents:
		var value = global_dsu.parents[key]
		if key == value: # root
			num_components += 1
			
	jacobian.clear()
	guess.clear()
	guess.resize(num_components)
	guess.fill(0)
#	jacobian.resize(num_components)
#	for i in range(num_components):
	#	jacobian[i].resize(num_components)
	#	jacobian[i].fill(0)

var pins: Dictionary[int, int]
## Automaticslly find all pin IDs & map to their root
func find_pin_roots():
	var pins_arr := get_tree().get_nodes_in_group("Pin")
	for i in range(pins_arr.size()):
		#Bad
		pins[pins_arr[i].id] = global_dsu.find(pins_arr[i].id)
		
	
var residual: PackedFloat64Array = PackedFloat64Array()

## Automatically loops over all components and calculation of f(x) is made.
func process_all_fx(curr_guess: PackedFloat64Array):
	residual.resize(curr_guess.size())
	residual.fill(0)
	var components := get_tree().get_nodes_in_group("Node")
	for i in range(components.size()):
		var component := components[i]
		component.output(curr_guess, residual, pins)
		


## Connects an electrical component (edge) from one node to another.
## Only call AFTER preparing the Jacobian!

func process_all_jacobians(curr_guess):
	var components := get_tree().get_nodes_in_group("Node")
	for i in range(components.size()):
		var component := components[i]
		component.jacobian(curr_guess, jacobian, residual, pins)
			
		
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
