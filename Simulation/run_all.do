# ModelSim Master Run Script
echo "Starting All Simulations..."
do compile.do
echo "Running Baseline..."
do run_baseline.do
echo "Running FastRipple..."
do run_ripple.do
echo "Running CSA..."
do run_csa.do
echo "All simulations complete."
