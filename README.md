# Zk-SNARK file ownership auhtenticator

A basic circom ciruit which proves that of a finite set over a field representing all possible permissions of file, the prover has atleast 'read' privilege.

File privilege is checked using stat in the "File_pipe" directory and is outputted to "input.json" .The main circuit and a functional circuit are given in "circuits" directory.

*note*: please check if the makefile works correctly on your system and make appropriate changes to make sure it does.
