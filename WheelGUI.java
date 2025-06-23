import javafx.application.Application;
import javafx.application.Platform;
import javafx.scene.Scene;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.scene.layout.Pane;
import javafx.scene.paint.Color;
import javafx.scene.shape.Circle;
import javafx.scene.text.Font;
import javafx.scene.text.Text;
import javafx.stage.Stage;

public class WheelGUI extends Application {

    public static WheelGUI instance;

    private final int[] wheelValues = {1, 3, 1, 5, 1, 3, 1, 9, 3, 1, 5, 1, 3};
    private final int wheelSize = wheelValues.length;
    private final double radius = 280;
    private final double centerX = 400;
    private final double centerY = 400;

    private Circle[] wheelSegments;
    private Text[] valueTexts;
    private int currentIndex = 0;

    // Googly eye elements
    private Circle leftPupil, rightPupil;
    private final double eyeOffsetX = 45;
    private final double eyeOffsetY = -10; // moved eyes slightly down
    private final double pupilRadius = 9; // made pupils bigger

    @Override
    public void start(Stage primaryStage) {
        instance = this;

        Pane root = new Pane();

        // Add background image of your face
        ImageView face = new ImageView(new Image("file:Rasmus_2021_Pasfoto.jpg"));
        face.setFitWidth(300);
        face.setPreserveRatio(true);
        face.setX(centerX - 150);
        face.setY(centerY - 200);
        root.getChildren().add(face);

        wheelSegments = new Circle[wheelSize];
        valueTexts = new Text[wheelSize];

        for (int i = 0; i < wheelSize; i++) {
            double angle = 2 * Math.PI * i / wheelSize;
            double x = centerX + radius * Math.cos(angle);
            double y = centerY + radius * Math.sin(angle);

            Circle dot = new Circle(x, y, 40);
            dot.setFill(getColorForValue(wheelValues[i]));
            dot.setStroke(Color.BLACK);
            dot.setStrokeWidth(3);
            wheelSegments[i] = dot;

            Text label = new Text(String.valueOf(wheelValues[i]));
            label.setFont(new Font(26));
            label.setX(x - 10);
            label.setY(y + 8);
            valueTexts[i] = label;

            root.getChildren().addAll(dot, label);
        }

        // Add googly eyes
        Circle leftEye = new Circle(centerX - eyeOffsetX, centerY + eyeOffsetY, 20, Color.WHITE);
        Circle rightEye = new Circle(centerX + eyeOffsetX, centerY + eyeOffsetY, 20, Color.WHITE);

        leftPupil = new Circle(centerX - eyeOffsetX, centerY + eyeOffsetY, pupilRadius, Color.BLACK);
        rightPupil = new Circle(centerX + eyeOffsetX, centerY + eyeOffsetY, pupilRadius, Color.BLACK);

        root.getChildren().addAll(leftEye, rightEye, leftPupil, rightPupil);

        highlightCurrentIndex();

        Scene scene = new Scene(root, 800, 800);
        primaryStage.setTitle("LC3 Wheel Viewer with Googly Eyes");
        primaryStage.setScene(scene);
        primaryStage.show();
    }

    private void highlightCurrentIndex() {
        for (int i = 0; i < wheelSize; i++) {
            wheelSegments[i].setStrokeWidth(3);
        }
        wheelSegments[currentIndex].setStrokeWidth(8);
        updatePupilDirection();
    }

    public void setWheelIndex(int index) {
        if (index < 0 || index >= wheelSize) return;
        currentIndex = index;
        Platform.runLater(this::highlightCurrentIndex);
    }

    private void updatePupilDirection() {
        double angle = 2 * Math.PI * currentIndex / wheelSize;
        double dx = Math.cos(angle) * 5;
        double dy = Math.sin(angle) * 5;

        leftPupil.setCenterX(centerX - eyeOffsetX + dx);
        leftPupil.setCenterY(centerY + eyeOffsetY + dy);
        rightPupil.setCenterX(centerX + eyeOffsetX + dx);
        rightPupil.setCenterY(centerY + eyeOffsetY + dy);
    }

    private Color getColorForValue(int value) {
        return switch (value) {
            case 1 -> Color.GOLD;
            case 3 -> Color.LIMEGREEN;
            case 5 -> Color.ROYALBLUE;
            case 9 -> Color.CRIMSON;
            default -> Color.GRAY;
        };
    }

    public static void main(String[] args) {
        launch(args);
    }
}
