# BLE Positioning using Particle Swarm Optimization (PSO)

This project demonstrates the use of **Particle Swarm Optimization (PSO)** to estimate the position of a smartphone based on simulated Bluetooth Low Energy (BLE) beacons' RSSI (Received Signal Strength Indicator) measurements. The goal is to optimize the smartphone's estimated position based on distances to multiple BLE beacons distributed around the map.

## Features

- **BLE Beacon Simulation**: Beacons are distributed around the edges of a 30x30 map.
- **Smartphone Position Estimation**: The position of the smartphone is randomly generated on the map.
- **RSSI-based Distance Estimation**: The distance between the smartphone and beacons is estimated using a log-distance path loss model.
- **PSO Algorithm**: Particle Swarm Optimization is used to estimate the smartphone's position and optimize the RSSI parameters.
- **Visualization**: A graphical visualization of the true smartphone position, estimated position, and beacons.

## How It Works

1. **Beacon Placement**: A set of BLE beacons is placed at known positions around the map.
2. **Smartphone Position**: The smartphone is randomly placed somewhere on the map.
3. **RSSI Simulation**: The RSSI values are calculated based on the distance between the smartphone and the beacons using the log-distance path loss model.
4. **PSO Optimization**: The Particle Swarm Optimization (PSO) algorithm estimates the smartphone's position by optimizing the RSSI values and path loss exponent.
5. **Visualization**: The true position, estimated position, and beacon locations are visualized using a graphical interface.

## Requirements

- **Java 8 or higher**
- **Swing** (for GUI visualization)
- **JFreeChart** (optional for enhanced visualizations if needed)

## Project Structure


## Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/yourusername/BLEPositioningPSO.git
