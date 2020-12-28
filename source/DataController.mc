using Toybox.BluetoothLowEnergy as Ble;

class DataController extends Ble.BleDelegate {

    private var _app;
    private var _device;
    private var _service;
    private var _ready = false;
    private var _doseRate = 0.0;
    private var _temperature;
    private var _doseStart = -1;
    private var _doseAccumulated = 0.0;

    function initialize(app) {
        BleDelegate.initialize();
        self._app = app;
        self.start();
    }

    function start() {
        self._device = Ble.pairDevice(self._app.getScanResult());
    }

    function stop() {
        if(null != self._device) {
            Ble.unpairDevice(self._device);
        }
    }

    function getDoseRate() {
        return self._doseRate;
    }

    function getDoseAccumulated() {
        return self._doseAccumulated;
    }

    function getSessionDoseAccumulated() {
        if(self._doseStart < 0) {
            return 0.0;
        }
        return self._doseAccumulated - self._doseStart;
    }

    function getTemperature() {
        return self._temperature;
    }

    function isReady() {
        return self._ready;
    }

    function startNotification() {
        var char = self._service.getCharacteristic(self._app.getProfile().ATOM_FAST_CHAR);
        if(char) {
            var cccd = char.getDescriptor(Ble.cccdUuid());
            cccd.requestWrite([0x01, 0x00]b);
        }
    }

    function onConnectedStateChanged(device, state) {
        if(self._device != device) {
            return;
        }
        if(!self._device.isConnected()) {
            return;
        }
        self._service = self._device.getService(self._app.getProfile().ATOM_FAST_SERVICE);
        if(self._service) {
            System.println("startNotification");
            self.startNotification();
        }
    }

    function onDescriptorWrite(descriptor, status) {
        if(Ble.cccdUuid().equals(descriptor.getUuid())) {
            self._ready = true;
        }
    }

    // Write request
    function onCharacteristicWrite(characteristic, status) {
        System.println("Write " + characteristic.toString() + " " + status.toString());
    }

    // read request
    function onCharacteristicRead(characteristic, status, value) {
        System.println("onCharacteristicRead " + characteristic.toString() + " " + status.toString());
    }

    function onCharacteristicChanged(char, value) {
        if(value.size() >= 13) {
            self._doseAccumulated = value.decodeNumber(Lang.NUMBER_FORMAT_FLOAT,
                    { :offset => 1, :endianness => Lang.ENDIAN_LITTLE });
            self._doseRate = value.decodeNumber(Lang.NUMBER_FORMAT_FLOAT,
                    { :offset => 5, :endianness => Lang.ENDIAN_LITTLE });
            self._temperature = value[12];
            if(self._doseStart < 0) {
                self._doseStart = self._doseAccumulated;
            }
        }
    }
}
