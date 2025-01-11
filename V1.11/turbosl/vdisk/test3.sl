
var array 56 byte offsets = [
	254,   0, 255,   0,   0,   0,   1,   0,
	255,   0,   0,   0,   1,   0,   1,   1,
	255,   0,   0,   0,   1,   0,   1, 255,
	255,   0,   0,   0,   1,   0,   0,   1,
	255,   0,   0,   0,   0, 255,   1, 255,
	255,   0,   0,   0,   0,   1,   1,   1,
	255,   0,   0,   0, 255,   1,   0,   1
]

fun func1(word a)
	return a+1
end

var array 24 byte other = [
	0,1,2,3,4,5,6,7,8,9,
	0,1,2,3,4,5,6,7,8,9,
	0,1,2,3
]

fun func2(byte b)
	return b+1
end

fun main()
	var word r
	r=func1()+func2()
end

