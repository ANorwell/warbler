src = $(wildcard *.js)
package = $(src:.js=.zip)

default: $(package)

%.zip: %.js
	zip $@ $<