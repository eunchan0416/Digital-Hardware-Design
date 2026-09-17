SIM ?= iverilog
VVP ?= vvp
BUILD_DIR := build
RTL := -f sim/filelist.f

.PHONY: csr_interrupt apb_mmio firmware clean

firmware:
	python3 firmware/build_mem.py

csr_interrupt: firmware
	mkdir -p $(BUILD_DIR)
	$(SIM) -g2012 -I rtl $(RTL) -s tb_rv32i_csr_interrupt -o $(BUILD_DIR)/csr_interrupt.vvp tb/tb_rv32i_csr_interrupt.sv
	$(VVP) $(BUILD_DIR)/csr_interrupt.vvp

apb_mmio: firmware
	mkdir -p $(BUILD_DIR)
	$(SIM) -g2012 -I rtl $(RTL) -s tb_rv32i_apb_mmio -o $(BUILD_DIR)/apb_mmio.vvp tb/tb_rv32i_apb_mmio.sv
	$(VVP) $(BUILD_DIR)/apb_mmio.vvp

clean:
	rm -rf $(BUILD_DIR) test.mem dump.vcd
