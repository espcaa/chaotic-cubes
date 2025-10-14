extends Control

var patterns = [
	{
		"name": "Three of a kind",
		"check":
		func(arr):
			return (
				arr[0]["value"] == arr[1]["value"]
				and arr[1]["value"] == arr[2]["value"]
				and arr[0]["name"] != "null"
				and arr[1]["name"] != "null"
				and arr[2]["name"] != "null"
				and arr[0]["value"] == arr[2]["value"]
			),
		"multiplier": 3
	},
	{
		"name": "Ascending sequence",
		"check":
		func(arr): return check_ascending([arr[0]["value"], arr[1]["value"], arr[2]["value"]]),
		"multiplier": 2
	},
	{
		"name": "Descending sequence",
		"check":
		func(arr): return check_ascending([arr[2]["value"], arr[1]["value"], arr[0]["value"]]),
		"multiplier": 2
	},
	{
		"name": "Double",
		"check": func(arr): return arr[2]["name"] == "null" and arr[0]["value"] == arr[1]["value"],
		"multiplier": 1.2
	},
	{
		"name": "All purple!!",
		"check":
		func(arr):
			return (
				arr[0]["name"] == "static dice"
				and arr[1]["name"] == "static dice"
				and arr[2]["name"] == "static dice"
			),
		"multiplier": 2.5
	},
	{
		"name": "Even!",
		"check":
		func(arr):
			return (
				arr[0]["value"] % 2 == 0 and arr[1]["value"] % 2 == 0 and arr[2]["value"] % 2 == 0
			),
		"multiplier": 1.5
	}
]


func check_ascending(arr):
	arr = arr.duplicate()
	return arr[1] == arr[0] + 1 and arr[2] == arr[1] + 1 and arr[2] <= 6
