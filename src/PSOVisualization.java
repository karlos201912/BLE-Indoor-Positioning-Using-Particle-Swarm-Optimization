import org.jfree.chart.ChartFactory;
import org.jfree.chart.ChartPanel;
import org.jfree.chart.JFreeChart;
import org.jfree.chart.plot.PlotOrientation;
import org.jfree.data.xy.XYSeries;
import org.jfree.data.xy.XYSeriesCollection;

import javax.swing.*;
import java.awt.*;

public class PSOVisualization extends JFrame {

    public PSOVisualization(String title, double[][] beaconPositions, double[] truePosition, double[] predictedPosition) {
        super(title);

        // Create dataset
        XYSeriesCollection dataset = createDataset(beaconPositions, truePosition, predictedPosition);

        // Create chart
        JFreeChart chart = ChartFactory.createScatterPlot(
                "Beacon and Position Estimation",
                "X-Axis", "Y-Axis", dataset, PlotOrientation.VERTICAL, true, true, false);

        // Customize the chart
        chart.setBackgroundPaint(Color.white);

        // Add chart to panel
        ChartPanel chartPanel = new ChartPanel(chart);
        chartPanel.setPreferredSize(new Dimension(800, 600));
        setContentPane(chartPanel);
    }

    private XYSeriesCollection createDataset(double[][] beaconPositions, double[] truePosition, double[] predictedPosition) {
        XYSeriesCollection dataset = new XYSeriesCollection();

        // Beacons
        XYSeries beaconSeries = new XYSeries("Beacons");
        for (double[] beacon : beaconPositions) {
            beaconSeries.add(beacon[0], beacon[1]);
        }

        // Ground Truth Position
        XYSeries truePositionSeries = new XYSeries("Ground Truth");
        truePositionSeries.add(truePosition[0], truePosition[1]);

        // Predicted Position (from PSO)
        XYSeries predictedSeries = new XYSeries("Predicted Position");
        predictedSeries.add(predictedPosition[0], predictedPosition[1]);

        // Add series to dataset
        dataset.addSeries(beaconSeries);
        dataset.addSeries(truePositionSeries);
        dataset.addSeries(predictedSeries);

        return dataset;
    }

    public static void main(String[] args) {
        // Sample data
        double[][] beaconPositions = {
                {0, 0}, {0, 100}, {100, 100}, {100, 0}, {50, 50}
        };
        double[] truePosition = {30, 30};  // Actual smartphone location
        double[] predictedPosition = {32, 28};  // Predicted position from PSO

        // Create and display the chart
        SwingUtilities.invokeLater(() -> {
            PSOVisualization example = new PSOVisualization("PSO Results Visualization", beaconPositions, truePosition, predictedPosition);
            example.setSize(800, 600);
            example.setLocationRelativeTo(null);
            example.setDefaultCloseOperation(WindowConstants.EXIT_ON_CLOSE);
            example.setVisible(true);
        });
    }
}
