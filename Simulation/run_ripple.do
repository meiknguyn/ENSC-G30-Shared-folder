# ModelSim Run Script for FastRipple Adder
vsim -t 1ps Work.tb_adder_ripple
transcript file ../Documentation/OutputFiles/transcript_ripple.txt
do wave.do
run -all
echo "Ripple Simulation finished. Transcript saved to Documentation/OutputFiles/transcript_ripple.txt"
