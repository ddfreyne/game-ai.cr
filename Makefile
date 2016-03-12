main: *.cr games/*.cr Makefile
	crystal build --release main.cr
