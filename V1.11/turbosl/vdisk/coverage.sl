var array 16 byte hex

fun init_hex()
        var byte i
        i=0
        while i<16
                if i<10
                        hex[i]=i+48
                else
                        hex[i]=i+55
                end
                i=i+1
        end
end


fun printnum(word num)
	var array 8 byte buffer
	var byte s
	var byte i
	var byte b
	buffer[0]=7
	buffer[1]=30
	buffer[2]=4
	i=0
	s=12
	while i<4
		b=(num>>s)
		buffer[3+i]=b&15
		s=s-4
		i=i+1
	end
	buffer[7]=4
	gpu_block(buffer)
end

fun fib(word x)
	var word p
	var word q
	if x < 2
		return 1
	else
		p=fib(x-1)
		q=fib(x-2)
		return p+q
	end
end

fun main()
        var word a
        init_hex()
        a=fib(12)
        printnum(a)
end
