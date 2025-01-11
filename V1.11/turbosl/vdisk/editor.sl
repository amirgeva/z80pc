

struct Line
	var array byte chars
end

struct Document
	var array 4096 Line lines
end

struct Point
	var word x
	var word y
end

fun draw(Document doc, word offset)
	cls()
	var word y
	y=0
	while y<25
		line=doc.lines[offset+y]
		text_cursor(0,y)
	end
end

fun main()
	var word offset
	var Document doc
	var Point cursor
	var byte done
	done=0
	offset = 0
	cursor.x=0
	cursor.y=0
	while done=0
	end
end