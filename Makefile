VERILOG=iverilog
VVP=vvp
GTKWAVE=gtkwave

INPUT_FILES=cpu.v \
			registerfile32/registerfile32x32.v \
			alu32/alu32.v \
			load_store_unit/load_store_unit.v \
			direct_cache/direct_cache.v \
			mem32/mem1024x32.v \

HEADERS=cpu.vh \
        alu32/alu_ops.vh \
		load_store_unit/load_store_unit.vh \

TEST_INPUT_FILES=tb_cpu.v \
                 cpu_tests/test_common.vh \
				 cpu_tests/test_op.vh \
				 cpu_tests/test_lui.vh \
				 cpu_tests/test_load_store.vh \
				 cpu_tests/test_branch.vh \
				 cpu_tests/test_auipc.vh \

all:
	@echo "Use this:"
	@echo "	$$ make test_cpu"
	@echo "or"
	@echo "	$$ make test_program"

test_cpu: tb_cpu
	${VVP} tb_cpu

test_program: tb_comp
	${VVP} tb_comp

tb_comp: ${INPUT_FILES} ${HEADERS} tb_comp.v
	${VERILOG} -gstrict-expr-width tb_comp.v -o tb_comp

tb_cpu: ${INPUT_FILES} ${HEADERS} ${TEST_INPUT_FILES}
	${VERILOG} -gstrict-expr-width tb_cpu.v -o tb_cpu

clean:
	rm -f tb_cpu