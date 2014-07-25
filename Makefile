BUILD = ocamlbuild -lib unix -lib str 

latex: out/map-levant.eps out/map-ponant.eps out/map-centre.eps out/map-abyssales.eps 
	$(BUILD) make.byte
	./make.byte 
	rm -f out/*.log out/*.aux out/*.dvi out/*.pdf || echo 'Clean!'
	(cd out ; latex book.tex && latex book.tex && dvipdfm book.dvi)

out/map-levant.eps: map-levant.png
	convert $< -resize 1200x1900\> -size 1200x1900 'xc:white' +swap -gravity center -composite $@

out/map-ponant.eps: map-ponant.png
	convert $< -resize 1200x1900\> -size 1200x1900 'xc:white' +swap -gravity center -composite $@

out/map-centre.eps: map-centre.png
	convert $< -resize 1200x1900\> -size 1200x1900 'xc:white' +swap -gravity center -composite $@

out/map-abyssales.eps: map-abyssales.png
	convert $< -resize 1200x1900\> -size 1200x1900 'xc:white' +swap -gravity center -composite $@


