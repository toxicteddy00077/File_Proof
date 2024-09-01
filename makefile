C_DIR=File_pipe      
C_PROGRAM=File_pipe/file_authenticate          
CIRCUIT_NAME=driver
INPUT_FILE=input.json
CURVE=bn128
PTAU_FILE=pot12_final.ptau
CIRCOM_PATH=driver

all: c_program compile_circuit witness setup proof verify

c_program: $(C_PROGRAM).c
	@echo "Compiling and running C-program..."
	gcc -o $(C_PROGRAM) $(C_PROGRAM).c
    $(C_PROGRAM) 

compile_circuit: $(CIRCUIT_NAME).circom
	@echo "Compiling Circom circuit..."
	circom $(CIRCUIT_NAME).circom --r1cs --wasm --sym -o $(CIRCOM_PATH)

witness: $(CIRCOM_PATH)/$(CIRCUIT_NAME)_js/generate_witness.js $(INPUT_FILE)
	@echo "Generating witness..."
	node $(CIRCOM_PATH)/$(CIRCUIT_NAME)_js/generate_witness.js $(CIRCOM_PATH)/$(CIRCUIT_NAME)_js/$(CIRCUIT_NAME).wasm $(INPUT_FILE) $(CIRCOM_PATH)/witness.wtns

setup: $(CIRCOM_PATH)/$(CIRCUIT_NAME).r1cs $(PTAU_FILE)
	@echo "Setting up zk-SNARK keys..."
	snarkjs groth16 setup $(CIRCOM_PATH)/$(CIRCUIT_NAME).r1cs $(PTAU_FILE) $(CIRCOM_PATH)/$(CIRCUIT_NAME).zkey
	snarkjs zkey export verificationkey $(CIRCOM_PATH)/$(CIRCUIT_NAME).zkey $(CIRCOM_PATH)/verification_key.json

proof: $(CIRCOM_PATH)/$(CIRCUIT_NAME).zkey $(CIRCOM_PATH)/witness.wtns
	@echo "Generating proof..."
	snarkjs groth16 prove $(CIRCOM_PATH)/$(CIRCUIT_NAME).zkey $(CIRCOM_PATH)/witness.wtns $(CIRCOM_PATH)/proof.json $(CIRCOM_PATH)/public.json

verify: $(CIRCOM_PATH)/verification_key.json $(CIRCOM_PATH)/proof.json $(CIRCOM_PATH)/public.json
	@echo "Verifying proof..."
	snarkjs groth16 verify $(CIRCOM_PATH)/verification_key.json $(CIRCOM_PATH)/public.json $(CIRCOM_PATH)/proof.json

# Optional cleanup target
clean:
	@echo "Cleaning up..."
	rm -rf $(CIRCOM_PATH)/*.zkey $(CIRCOM_PATH)/witness.wtns $(CIRCOM_PATH)/proof.json $(CIRCOM_PATH)/public.json $(CIRCOM_PATH)/verification_key.json
	rm -rf $(CIRCOM_PATH)/$(CIRCUIT_NAME).r1cs $(CIRCOM_PATH)/$(CIRCUIT_NAME).sym $(CIRCOM_PATH)/$(CIRCUIT_NAME)_js $(CIRCOM_PATH)/$(CIRCUIT_NAME).wasm
	rm -f $(C_EXECUTABLE)  # Remove the C executable

.PHONY: all run_c_program compile witness setup proof verify clean