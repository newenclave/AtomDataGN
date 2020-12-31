using Toybox.BluetoothLowEnergy as Ble;
using Toybox.Application as App;

class ScanController extends Ble.BleDelegate {

    private var _results;
    private var _mac;

    function initialize(mac) {
        BleDelegate.initialize();
        self._mac = mac;
        self._results = [];
    }

    function onScanResults(scanResults) {
        var added = 0;
        for( var result = scanResults.next(); result != null; result = scanResults.next() ) {
            if(self.contains(result.getServiceUuids(), App.getApp().getProfile().ATOM_FAST_SERVICE)) {
                self._results.add(result);
                System.println("Mac: '" + self._mac + "'");
                if(!self._mac.equals("")) {
                    if(App.getApp().checkAddress(result, self._mac) == 1) {
                        System.println("Found device with mac: " + self._mac);
                        App.getApp().connectTo(result, App.getApp().STATUS_PAIRING);
                    }
                } else {
                    System.println("Using first device");
                    App.getApp().connectTo(result, App.getApp().STATUS_PAIRING);
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
