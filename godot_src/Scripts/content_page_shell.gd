extends Node

@onready var login_page = preload("res://Pages/login_page.tscn")
@onready var player_page = preload("res://Pages/player_page.tscn")

enum Page {
	LOGIN_PAGE, PLAYER_PAGE
}

var content_page_holder = null

func set_content_page_holder(holder):
	if (content_page_holder == null):
		content_page_holder = holder
		return
	printerr("Page holder has already been alloted")

func clear_pages():
	if (content_page_holder == null):
		printerr("Page Holder not set up properly")
	for i in content_page_holder.get_children():
		i.queue_free()
	

func load_view(page: Page):
	clear_pages()
	var curr_page = null
	
	match page:
		Page.LOGIN_PAGE:
			curr_page = login_page 
		Page.PLAYER_PAGE:
			curr_page = player_page 
			
	var scene = curr_page.instantiate()
	content_page_holder.add_child(scene)
