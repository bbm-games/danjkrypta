extends TabBar


func _on_line_edit_text_submitted(new_text):
	$VBoxContainer/RichTextLabel.append_text('\n' + new_text)
	var result = evalExpression(new_text)
	$VBoxContainer/RichTextLabel.append_text('\n' + str(result))
	$VBoxContainer/LineEdit.text = ''
	
func evalExpression(text_input):
	var expression = Expression.new()
	expression.parse(text_input)
	var result = expression.execute([], get_tree().get_root().get_node('Node2D'))
	return result

func run_script(input):
	var script = GDScript.new()
	script.set_source_code("\nfunc eval():\n\t" + input)
	script.reload()
	var ref = RefCounted.new()
	ref.set_script(script)
	return ref.eval()
