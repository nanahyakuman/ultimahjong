# can also be hidden by the skip button
extends Control

@onready var holder = $VBoxContainer

func test_if_should_autohide():
	for vbc in holder:
		if vbc.get_child_count() > 0:
			return
	visible = false
