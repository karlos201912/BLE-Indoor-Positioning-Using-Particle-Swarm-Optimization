import java.util.Arrays;
import java.util.Random;

public class PSO {
    private int swarmSize;
    private int numBeacons;
    private int mapSize;
    private int maxIterations;
    private double functionTolerance;
    private Random random;
    private int optimizedBeacons;
    private int patience;

    // Personal best and global best storage
    private double[][] pBestPositions;
    private double[] pBestFitness;
    private double[] gBestPosition;
    private double gBestFitness;
    private double noImprovementCount;

    public PSO(int swarmSize, int numBeacons, int optimizedBeacons, int mapSize,
               int maxIterations, double functionTolerance, int patience) {
        this.swarmSize = swarmSize;
        this.numBeacons = numBeacons;
        this.optimizedBeacons = optimizedBeacons;
        this.mapSize = mapSize;
        this.maxIterations = maxIterations;
        this.functionTolerance = functionTolerance;
        this.random = new Random();
        this.patience = patience;
    }

    public double[] optimize(double[][] beaconPositions, double[] rssiMeasurements) {
        // PSO Parameters (e.g., cognitive, social components)
        double c1 = 1.5, c2 = 1.5, inertiaMax = 0.9, inertiaMin = 0.4;
        double inertiaWeight = inertiaMax;
        double function_improvement = 100;
        double[][] swarm = new double[swarmSize][3 + optimizedBeacons];  // x, y, n, RSSI0
        double[][] velocities = new double[swarmSize][3 + optimizedBeacons];  // velocities for each particle

        // Initialize the swarm with random positions and velocities
        for (int i = 0; i < swarmSize; i++) {
            swarm[i][0] = random.nextDouble() * mapSize; // x
            swarm[i][1] = random.nextDouble() * mapSize; // y
            swarm[i][2] = random.nextDouble() * 2 + 2;  // n (path loss exponent)
            for (int j = 3; j < optimizedBeacons + 3; j++) {
                swarm[i][j] = -40 + random.nextDouble() * 20 - 10; // RSSI0 for each beacon
            }
            // Random initial velocities
            for (int j = 0; j < optimizedBeacons + 3; j++) {
                velocities[i][j] = random.nextDouble() * 2 - 1;  // Random velocities between -1 and 1
            }
        }

        // Initialize personal best and global best
        pBestPositions = new double[swarmSize][optimizedBeacons + 3];
        pBestFitness = new double[swarmSize];
        gBestPosition = new double[optimizedBeacons + 3];
        gBestFitness = Double.POSITIVE_INFINITY;

        // PSO main loop
        for (int iter = 0; iter < maxIterations; iter++) {
            boolean improved = false;

            // Evaluate each particle's fitness
            for (int i = 0; i < swarmSize; i++) {
                double[] particle = swarm[i];
                double fitness = evaluateFitness(particle, beaconPositions, rssiMeasurements);

                // Update personal best
                if (fitness < pBestFitness[i] || iter == 0) {
                    pBestFitness[i] = fitness;
                    System.arraycopy(particle, 0, pBestPositions[i], 0, optimizedBeacons + 3);
                }

                // Update global best
                if (fitness < gBestFitness || iter == 0) {
                    function_improvement = Math.abs(gBestFitness - fitness);
                    gBestFitness = fitness;
                    System.arraycopy(particle, 0, gBestPosition, 0, optimizedBeacons + 3);
                    improved = true;  // Mark that we found a new global best
                } else {
                    function_improvement = 0;
                }
            }

            // Update inertia weight (adaptive)
            if (improved) {
                inertiaWeight = Math.max(inertiaMin, inertiaWeight * 0.9);  // Decrease inertia (focus on exploitation)
            } else {
                inertiaWeight = Math.min(inertiaMax, inertiaWeight * 1.1);  // Increase inertia (encourage exploration)
            }

            // Update velocity and position for each particle
            for (int i = 0; i < swarmSize; i++) {
                for (int j = 0; j < optimizedBeacons + 3; j++) {
                    // Velocity update
                    double r1 = random.nextDouble();
                    double r2 = random.nextDouble();
                    velocities[i][j] = inertiaWeight * velocities[i][j]
                            + c1 * r1 * (pBestPositions[i][j] - swarm[i][j])  // Cognitive component
                            + c2 * r2 * (gBestPosition[j] - swarm[i][j]);    // Social component

                    // Position update
                    swarm[i][j] += velocities[i][j];

                    // Ensure positions stay within the map bounds (for x, y positions)
                    if (j < 2) { // Only x and y positions need to stay in the map
                        swarm[i][j] = Math.max(0, Math.min(swarm[i][j], mapSize));  // Bound x and y within map size
                    }
                }
            }

            // Check stopping criteria
            if (functionTolerance > 0 && function_improvement < functionTolerance) {
                noImprovementCount += 1;
            } else {
                noImprovementCount = 0;
            }
            if (noImprovementCount > patience){
                System.out.println("The optimization ends on iteration: " + (iter + 1));
                break;
            } else if (iter == maxIterations - 1) {
                System.out.println("The optimization ends on iteration: " + maxIterations);
            }
        }
        // Return the best solution found
        return gBestPosition;
    }

    // Objective function for PSO
    public double evaluateFitness(double[] params, double[][] beaconPositions, double[] rssiMeasurements) {
        double error = 0.0;
        double[] distances = BLEPositioningPSO.calculateDistances(beaconPositions, new double[]{params[0], params[1]});
        double estimatedRSSI;
        for (int i = 0; i < rssiMeasurements.length; i++) {
            if (optimizedBeacons == 1) {
                estimatedRSSI = params[3] - 10 * params[2] * Math.log10(distances[i] + 1e-9);
            } else {
                estimatedRSSI = params[3 + i] - 10 * params[2] * Math.log10(distances[i] + 1e-9);
            }
            error += Math.pow(rssiMeasurements[i] - estimatedRSSI, 2);
        }
        return error;
    }
}
