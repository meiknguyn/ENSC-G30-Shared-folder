# ModelSim Run Script for CSA Adder
vsim -t 1ps Work.tb_adder_csa
transcript file ../Documentation/OutputFiles/transcript_csa.txt
do wave.do
run -all
echo "CSA Simulation finished. Transcript saved to Documentation/OutputFiles/transcript_csa.txt"
