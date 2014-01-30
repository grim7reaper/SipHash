BUILD_MODE=debug

.PHONY: clean

all: tests

run_tests : tests
	./bin/tests-block_interface
	./bin/tests-streaming_interface

tests: block streaming

block:
	gnatmake -Psiphash -Xtest=block -Xmode=$(BUILD_MODE)

streaming:
	gnatmake -Psiphash -Xtest=streaming -Xmode=$(BUILD_MODE)

clean:
	gnatclean -Psiphash -Xtest=block -Xmode=$(BUILD_MODE)
	gnatclean -Psiphash -Xtest=streaming -Xmode=$(BUILD_MODE)
