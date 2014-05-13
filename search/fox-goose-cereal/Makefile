
all: fg.png fg-trimmed.png

fg.png: fg.pl
	perl fg.pl | dot -Tpng > fg.png 

fg-trimmed.png: fg.pl
	perl fg.pl 1 | dot -Grankdir=RL -Tpng > fg-trimmed.png 