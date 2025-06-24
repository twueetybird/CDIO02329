import com.fazecast.jSerialComm.SerialPort;


public class App {
    public static void main(String[] args) {
        // Start GUI in another thread
        new Thread(() -> WheelGUI.main(new String[]{})).start();

        // Wait briefly for GUI to launch
        try { Thread.sleep(2000); } catch (InterruptedException ignored) {}

        SerialPort port = SerialPort.getCommPort("COM10");
        port.setComPortParameters(19200, 8, SerialPort.ONE_STOP_BIT, SerialPort.NO_PARITY);
        port.setComPortTimeouts(SerialPort.TIMEOUT_READ_SEMI_BLOCKING, 0, 0);

        if (!port.openPort()) {
            System.out.println("Failed to open port.");
            return;
        }

        System.out.println("Port opened. Waiting for data...");

        int state = 0, cmd = 0, data = 0;

        try {
            while (true) {
                int b = port.getInputStream().read();
                if (b == -1) continue;
                b = b & 0xFF;

                switch (state) {
                    case 0:
                        if (b == 0x55) state = 1;
                        break;
                    case 1:
                        cmd = b;
                        state = 2;
                        break;
                    case 2:
                        data = b;
                        if (cmd == 0x01 && WheelGUI.instance != null) {
                            int index = data;
                            System.out.println("Updating wheel to index: " + index);
                            WheelGUI.instance.setWheelIndex(index);
                        }
                        state = 0;
                        break;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}