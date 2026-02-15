# ModelSim Run Script for Baseline Adder
vsim -t 1ps Work.tb_adder_baseline
transcript file ../Documentation/OutputFiles/transcript_baseline.txt
do wave.do
run -all
echo "Baseline Simulation finished. Transcript saved to Documentation/OutputFiles/transcript_baseline.txt"
