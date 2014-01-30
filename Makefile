BUILD_MODE=debug

.PHONY: tests clean

all: tests

tests: block streaming

block:
	gnatmake -Psiphash -Xtest=block -Xmode=$(BUILD_MODE)

streaming:
	gnatmake -Psiphash -Xtest=streaming -Xmode=$(BUILD_MODE)

clean:
	gnatclean -Psiphash -Xtest=block -Xmode=$(BUILD_MODE)
	gnatclean -Psiphash -Xtest=streaming -Xmode=$(BUILD_MODE)
