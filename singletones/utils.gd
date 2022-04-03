extends Node

func set_diff(main_array: Array, minus_array: Array) -> Array:
	var result = []
	for val in main_array:
		if !minus_array.has(val):
			result.append(val)
	return result

func unique(array: Array) -> Array:
	var result = []
	for val in array:
		if !array.has(val):
			result.append(val)
	return result
