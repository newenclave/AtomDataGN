using Toybox.Application;
using Toybox.BluetoothLowEnergy as Ble;

class AtomDataGNApp extends Application.AppBase {

    const USED_DEVICE_STORAGE_NAME = "UsedDevice";

    enum {
        STATUS_COLD,
        STATUS_SCAN,
        STATUS_PAIRED,
    }

    private var _atomProfile;
    private var _deviceAddress;
    private var _useRoentgens;
    private var _savedDevice;
    private var _currentStatus;

    private var _scanController;
    private var _dataController;

    function initialize() {
        AppBase.initialize();
        self._atomProfile = new AtomFastProfile();
        self.loadSettings();

        self.loadDevice();

        System.println("Init!");
        Ble.registerProfile(self._atomProfile.getProfile());
        self._currentStatus = STATUS_COLD;
    }

    function isReady() {
        return (null != self._dataController) && self._dataController.isReady();
    }

    function isRoentgen() {
        return self._useRoentgens;
    }

    function getDoseRate() {
        return self._dataController.getDoseRate();
    }

    function getScanResult() {
        return self._savedDevice;
    }

    function getSessionDoseAccumulated() {
        return self._dataController.getSessionDoseAccumulated();
    }

    function getTemperature() {
        return self._dataController.getTemperature();
    }

    function getProfile() {
        return self._atomProfile;
    }

    function onStart(state) {
        if(null != self._savedDevice) {
            if(!self._deviceAddress.equals("") && !self._savedDevice.hasAddress(self._deviceAddress)) {
                self._savedDevice = null;
                self.cleanDevice();
            } else {
                System.println("Connect to!");
                self.connectTo(self._savedDevice);
                return;
            }
        }
        self.reconnectNew();
    }

    function onStop(state) {
        if(self._dataController) {
            self._dataController.stop();
        }
        Ble.setScanState(Ble.SCAN_STATE_OFF);
    }

    function onSettingsChanged() {
        var newDevAddr = Application.Properties.getValue("device_mac");
        if(newDevAddr != self._deviceAddress) {
            self._deviceAddress = newDevAddr;
            self.reconnectNew();
        }
        self._useRoentgens = Application.Properties.getValue("use_roentgens");
    }

    function loadDevice() {
        self._savedDevice = Application.Storage.getValue(USED_DEVICE_STORAGE_NAME);
    }

    function cleanDevice() {
        self._savedDevice = Application.Storage.deleteValue(USED_DEVICE_STORAGE_NAME);
    }

    function saveDevice() {
        Application.Storage.setValue(USED_DEVICE_STORAGE_NAME, self._savedDevice);
    }

    function loadSettings() {
        self._deviceAddress = Application.Properties.getValue("device_mac");
        self._useRoentgens = Application.Properties.getValue("use_roentgens");
    }

    function reconnectNew() {
        switch(self._currentStatus) {
        case STATUS_COLD:
            self.reconnectCold();
            break;
        case STATUS_SCAN:
            break;
        case STATUS_PAIRED:
            break;
        }
    }

    function reconnectCold() {
        self.reconnectScan();
        Ble.setScanState(Ble.SCAN_STATE_SCANNING);
    }

    function reconnectScan() {
        self._scanController = new ScanController(self, self._deviceAddress);
        Ble.setDelegate(self._scanController);
    }

    function reconnectPair() {

    }

    function connectTo(scanResult) {
        self._savedDevice = scanResult;
        self._dataController = new DataController(self);
        Ble.setDelegate(self._dataController);
        Ble.setScanState(Ble.SCAN_STATE_OFF);
        self._currentStatus = STATUS_PAIRED;
        self.saveDevice();
    }

    function getInitialView() {
        return [ new AtomDataGNView(self) ];
    }
}

