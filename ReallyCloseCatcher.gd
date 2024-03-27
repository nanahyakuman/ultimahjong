##  ensure the player really wants to close the shop
extends Control

@onready var shop_root = %ShopRoot

func _on_return_button_pressed():
	visible = false

func _on_continue_button_pressed():
	shop_root.close()


