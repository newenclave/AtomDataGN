using Toybox.BluetoothLowEnergy as Ble;

class ScanController extends Ble.BleDelegate {

    private var _app;
    private var _results;
    private var _mac;

    function initialize(app, mac) {
        BleDelegate.initialize();
        self._app = app;
        self._mac = mac;
        self._results = [];
    }

    function onScanResults(scanResults) {
        var added = 0;
        for( var result = scanResults.next(); result != null; result = scanResults.next() ) {
            if(self.contains(result.getServiceUuids(), self._app.getProfile().ATOM_FAST_SERVICE)) {
                self._results.add(result);
                System.println("Mac: '" + self._mac + "'");
                if(!self._mac.equals("")) {
                    if(result.hasAddress(self._mac)) {
                        System.println("Found device with mac: " + self._mac);
                        self._app.connectTo(result);
                    }
                } else {
                    System.println("Using first device");
                    self._app.connectTo(result);
                }
            }
        }
    }

    private function contains(iter, obj) {
        for(var uuid = iter.next(); uuid != null; uuid = iter.next()) {
            if(uuid.equals(obj)) {
                return true;
            }
        }
        return false;
    }
}
