VERILOG=iverilog
VVP=vvp
GTKWAVE=gtkwave

INPUT_FILES=direct_cache.v \

TEST_INPUT_FILES=tb_direct_cache.v \

all: test_cache

test_cache: test_build
	cd build && ${VVP} tb_direct_cache

test_build: ${INPUT_FILES} ${TEST_INPUT_FILES}
	mkdir -p build
	${VERILOG} tb_direct_cache.v -o build/tb_direct_cache
