extends Button

@onready var shop_root = %ShopRoot

func _on_pressed():
	shop_root.close()
