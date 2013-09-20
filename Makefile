BUILD = ocamlbuild -lib unix -lib str 

latex : 
	$(BUILD) make.byte
	./make.byte 
	rm -f out/*.log out/*.aux out/*.dvi out/*.pdf || echo 'Clean!'
	(cd out ; latex book.tex && latex book.tex && dvipdfm book.dvi)


