using Toybox.Application;
using Toybox.BluetoothLowEnergy as Ble;

class AtomDataGNApp extends Application.AppBase {

    const USED_DEVICE_STORAGE_NAME = "UsedDevice";

    enum {
        STATUS_COLD,
        STATUS_SCAN,
        STATUS_PAIRING,
        STATUS_PAIRED,
    }

    private var _atomProfile;
    private var _deviceAddress;
    private var _useRoentgens;
    private var _savedDevice;
    private var _scanTo;
    private var _currentStatus;

    private var _scanController;
    private var _dataController;

    private var _statusTime;

    function initialize() {
        AppBase.initialize();
        self._atomProfile = new AtomFastProfile();
        self.loadSettings();

        self.loadDevice();

        Ble.registerProfile(self._atomProfile.getProfile());
        self._currentStatus = STATUS_COLD;
        self._statusTime = 0;
    }

    function isReady() {
        return (null != self._dataController) && self._dataController.isReady();
    }

    function isRoentgen() {
        return self._useRoentgens;
    }

    function getDoseRate() {
        if(null != self._dataController) {
            return self._dataController.getDoseRate();
        }
        return 0.0f;
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
            if(!self._deviceAddress.equals("") && (self.checkAddress(self._savedDevice, self._deviceAddress) != 1)) {
                self._savedDevice = null;
                self.cleanDevice();
            } else {
                System.println("Connect to!");
                self.connectTo(self._savedDevice, STATUS_SCAN);
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
        self._useRoentgens = Application.Properties.getValue("use_roentgens");
        self._scanTo = Application.Properties.getValue("max_connect_time");
        var newDevAddr = Application.Properties.getValue("device_mac");
        if(newDevAddr != self._deviceAddress) {
            self._deviceAddress = newDevAddr;
            self.reconnectNew();
        }
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
        self._scanTo = Application.Properties.getValue("max_connect_time");
    }

    function checkAddress(scanResult, addr) {
        try {
            return scanResult.hasAddress(addr) ? 1 : 0;
        } catch(e) {
            System.println(e.getErrorMessage());
        }
        return -1;
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
        self.setCurrentStatus(STATUS_SCAN);
        Ble.setScanState(Ble.SCAN_STATE_SCANNING);
    }

    function reconnectScan() {
        self._scanController = new ScanController(self._deviceAddress);
        Ble.setDelegate(self._scanController);
    }

    function onCompute() {
        if((self._scanTo > 0) && (self._currentStatus == STATUS_SCAN)) {
            if((System.getTimer() - self._statusTime) > (self._scanTo * 1000)) {
                if(self._dataController) {
                    self._dataController.stop();
                }
                if(self._scanController) {
                    Ble.setScanState(Ble.SCAN_STATE_OFF);
                }
                self._dataController = null;
                self._scanController = null;
                self.setCurrentStatus(STATUS_COLD);
                System.println("Bla!");
            }
        }
    }

    function reconnectPair() {

    }

    function connectTo(scanResult, status) {
        self._savedDevice = scanResult;
        self._dataController = new DataController();
        Ble.setDelegate(self._dataController);
        Ble.setScanState(Ble.SCAN_STATE_OFF);
        self.setCurrentStatus(status);
        self.saveDevice();
    }

    function setCurrentStatus(status) {
        self._currentStatus = status;
        self._statusTime = System.getTimer();
    }

    function onConnectChanged(val) {
        self.setCurrentStatus(val ? STATUS_PAIRING : STATUS_PAIRING);
    }

    function getInitialView() {
        return [ new AtomDataGNView() ];
    }
}

