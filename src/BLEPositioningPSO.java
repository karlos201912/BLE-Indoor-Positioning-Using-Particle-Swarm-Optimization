import javax.swing.*;
import java.util.Random;
import java.util.Arrays;

public class BLEPositioningPSO {
    private static final int MAP_SIZE = 30;
    private static final int NUM_BEACONS = 5;
    private static final int SWARM_SIZE = 100;
    private static final int MAX_ITERATIONS = 2000;
    private static final double FUNCTION_TOLERANCE = 1e-10;
    private static int OPTIMIZED_BEACONS = 1;
    private static int PATIENCE = 100;

    public static void main(String[] args) {
        // 1. Simulate the environment
        double[][] beaconPositions = generateBeaconPositions(NUM_BEACONS, MAP_SIZE);

        // Generate a random position for the smartphone
        double[] trueSmartphonePosition = generateRandomPosition(MAP_SIZE);

        // Set true path loss exponent and RSSI at 1 meter
        Random random = new Random();
//        double trueN = 2.5 + random.nextDouble() * 1 - 0.5;
        double[] trueN = generateTrueN(NUM_BEACONS);
        double[] trueRSSI0 = generateTrueRSSI0(NUM_BEACONS);

        // Simulate RSSI measurements
        double[] trueDistances = calculateDistances(beaconPositions, trueSmartphonePosition);
        double[] rssiMeasurements = simulateRSSIMeasurements(trueDistances, trueRSSI0, trueN);

        // 2. Run Particle Swarm Optimization
        PSO pso = new PSO(SWARM_SIZE, NUM_BEACONS, OPTIMIZED_BEACONS, MAP_SIZE, MAX_ITERATIONS, FUNCTION_TOLERANCE, PATIENCE);
        double[] estimatedParams = pso.optimize(beaconPositions, rssiMeasurements);

        // Extract estimated position, RSSI, and n
        double[] estimatedPosition = Arrays.copyOfRange(estimatedParams, 0, 2);
        double estimatedN = estimatedParams[2];
        double[] estimatedRSSI0 = Arrays.copyOfRange(estimatedParams, 3, 4);

        double dx = trueSmartphonePosition[0] - estimatedPosition[0];
        double dy = trueSmartphonePosition[1] - estimatedPosition[1];
        double distance_error = Math.sqrt(Math.pow(dx, 2) + Math.pow(dy, 2));

        // Display results
        System.out.println("True Smartphone Position: " + Arrays.toString(trueSmartphonePosition));
        System.out.println("Estimated Smartphone Position: " + Arrays.toString(estimatedPosition));
        System.out.println("True RSSI_0: " + Arrays.toString(trueRSSI0));
        System.out.println("Estimated RSSI_0: " + Arrays.toString(estimatedRSSI0));
        System.out.println("True n: " + trueN);
        System.out.println("Estimated n: " + estimatedN);
        System.out.println("Operation error: " + distance_error);

        PSOVisualization psovisual = new PSOVisualization("Optimization Results",
                beaconPositions,
                trueSmartphonePosition,
                estimatedPosition);
        psovisual.setSize(800, 600);
        psovisual.setLocationRelativeTo(null); // Center the window
        psovisual.setDefaultCloseOperation(WindowConstants.EXIT_ON_CLOSE);
        psovisual.setVisible(true);

    }

    // Method to generate random beacon positions around the edges of the map
    public static double[][] generateBeaconPositions(int numBeacons, int mapSize) {
        double[][] positions = new double[numBeacons][2];
        positions[0] = new double[]{0, 0};
        positions[1] = new double[]{0, mapSize};
        positions[2] = new double[]{mapSize, mapSize};
        positions[3] = new double[]{mapSize, 0};
        positions[4] = new double[]{mapSize / 2, mapSize / 2};
        return positions;
    }

    // Method to generate a random position for the smartphone
    public static double[] generateRandomPosition(int mapSize) {
        Random random = new Random();
        return new double[]{random.nextDouble() * mapSize, random.nextDouble() * mapSize};
    }

    // Method to generate true RSSI0 values for each beacon
    public static double[] generateTrueRSSI0(int numBeacons) {
        Random random = new Random();
        double[] rssi0 = new double[numBeacons];
        for (int i = 0; i < numBeacons; i++) {
            rssi0[i] = -40 + random.nextDouble() * 5 - 2.5;
        }
        return rssi0;
    }

    public static double[] generateTrueN(int numBeacons) {
        Random random = new Random();
        double [] true_N = new double[numBeacons];
        for (int i = 0; i < numBeacons; i++){
            true_N[i] = 2.5 + random.nextDouble() * 0.5 - 0.25;
        }
        return true_N;
    }

    // Calculate Euclidean distances between the smartphone and beacons
    public static double[] calculateDistances(double[][] beaconPositions, double[] smartphonePosition) {
        double[] distances = new double[beaconPositions.length];
        for (int i = 0; i < beaconPositions.length; i++) {
            distances[i] = Math.sqrt(Math.pow(beaconPositions[i][0] - smartphonePosition[0], 2) +
                    Math.pow(beaconPositions[i][1] - smartphonePosition[1], 2));
        }
        return distances;
    }

    // RSSI function based on log-distance path loss model
    public static double[] simulateRSSIMeasurements(double[] distances, double[] rssi0, double[] n) {
        double[] rssiMeasurements = new double[distances.length];
        for (int i = 0; i < distances.length; i++) {
            rssiMeasurements[i] = rssi0[i] - 10 * n[i] * Math.log10(distances[i] + 1e-9);
        }
        return rssiMeasurements;
    }
}
