#c program path variables
C_DIR=File_pipe      
C_PROGRAM=file_authenticator       

#proof path varibles
INPUT_FILE=input.json
CURVE=bn128
PTAU_FILE=pot12_final.ptau

#circom path variables
CIRCOM_PATH=driver
CIRCOM_DIR=circuits
CIRCUIT_NAME=driver

all: c_program compile_circuit witness setup proof verify

c_program: $(C_DIR)/$(C_PROGRAM).c
	@echo "C_DIR: $(C_DIR)"
	@echo "C_PROGRAM: $(C_PROGRAM)"
	@echo "Compiling and running C-program..."
	gcc $(C_DIR)/$(C_PROGRAM).c -o $(C_DIR)/$(C_PROGRAM)
	$(C_DIR)/$(C_PROGRAM)
 

compile_circuit: $(CIRCOM_DIR)/$(CIRCUIT_NAME).circom
	@echo "Compiling Circom circuit..."
	circom $(CIRCOM_DIR)/$(CIRCUIT_NAME).circom --r1cs --wasm --sym -o $(CIRCOM_DIR)/$(CIRCOM_PATH)

witness: $(CIRCOM_DIR)/$(CIRCOM_PATH)/$(CIRCUIT_NAME)_js/generate_witness.js $(INPUT_FILE)
	@echo "Generating witness..."
	node $(CIRCOM_DIR)/$(CIRCOM_PATH)/$(CIRCUIT_NAME)_js/generate_witness.js $(CIRCOM_DIR)/$(CIRCOM_PATH)/$(CIRCUIT_NAME)_js/$(CIRCUIT_NAME).wasm $(INPUT_FILE) $(CIRCOM_DIR)/$(CIRCOM_PATH)/witness.wtns

setup: $(CIRCOM_PATH)/$(CIRCUIT_NAME).r1cs $(PTAU_FILE)
	@echo "Setting up zk-SNARK keys..."
	snarkjs groth16 setup $(CIRCOM_DIR)/$(CIRCOM_PATH)/$(CIRCUIT_NAME).r1cs $(PTAU_FILE) $(CIRCOM_DIR)/$(CIRCOM_PATH)/$(CIRCUIT_NAME).zkey
	snarkjs zkey export verificationkey $(CIRCOM_DIR)/$(CIRCOM_PATH)/$(CIRCUIT_NAME).zkey $(CIRCOM_DIR)/$(CIRCOM_PATH)/verification_key.json

proof: $(CIRCOM_PATH)/$(CIRCUIT_NAME).zkey $(CIRCOM_PATH)/witness.wtns
	@echo "Generating proof..."
	snarkjs groth16 prove $(CIRCOM_DIR)/$(CIRCOM_PATH)/$(CIRCUIT_NAME).zkey $(CIRCOM_DIR)/$(CIRCOM_PATH)/witness.wtns $(CIRCOM_DIR)/$(CIRCOM_PATH)/proof.json $(CIRCOM_DIR)/$(CIRCOM_PATH)/public.json

verify: $(CIRCOM_PATH)/verification_key.json $(CIRCOM_PATH)/proof.json $(CIRCOM_PATH)/public.json
	@echo "Verifying proof..."
	snarkjs groth16 verify $(CIRCOM_DIR)/$(CIRCOM_PATH)/verification_key.json $(CIRCOM_DIR)/$(CIRCOM_PATH)/public.json $(CIRCOM_DIR)/$(CIRCOM_PATH)/proof.json

# Optional cleanup target
# clean:
# 	@echo "Cleaning up..."
# 	rm -rf $(CIRCOM_DIR)/$(CIRCOM_PATH)/*.zkey $(CIRCOM_DIR)/$(CIRCOM_PATH)/witness.wtns $(CIRCOM_DIR)/$(CIRCOM_PATH)/proof.json $(CIRCOM_DIR)/$(CIRCOM_PATH)/public.json $(CIRCOM_DIR)/$(CIRCOM_PATH)/verification_key.json
# 	rm -rf $(CIRCOM_DIR)/$(CIRCOM_PATH)/$(CIRCUIT_NAME).r1cs $(CIRCOM_DIR)/$(CIRCOM_PATH)/$(CIRCUIT_NAME).sym $(CIRCOM_DIR)/$(CIRCOM_PATH)/$(CIRCUIT_NAME)_js $(CIRCOM_DIR)/$(CIRCOM_PATH)/$(CIRCUIT_NAME).wasm
# 	rm -f $(C_EXECUTABLE)  # Remove the C executable

.PHONY: all c_program compile_circuit witness setup proof verify 