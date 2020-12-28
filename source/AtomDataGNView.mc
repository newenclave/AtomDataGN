using Toybox.WatchUi;
using Toybox.FitContributor as Fit;

class AtomDataGNView extends WatchUi.SimpleDataField {

    private var _app;
    private var _fitContibution;

    function initialize(app) {
        SimpleDataField.initialize();
        label = Application.loadResource(Rez.Strings.label_dose_rate);
        self._app = app;
        self._fitContibution = new AtomFitContribution(self);
    }

    function compute(info) {
        var result = "--.--";

        var r = self._app.isRoentgen();
        var ready = self._app.isReady();
        if(ready) {
            var d = self._app.getDoseRate();
            if(r) {
                result = (d * 100.0).format("%.2f");
            } else {
                result = (d).format("%.2f");
            }

            self._fitContibution.update({
                :doseRate => d,
                :temperature => 0.0,
                :sessionDoze => self._app.getSessionDoseAccumulated()
            });
        }
        result = Lang.format("$1$ $2$", [result,
            (r ? Application.loadResource(Rez.Strings.text_micro_roentgen_hours)
               : Application.loadResource(Rez.Strings.text_micro_sieverts_hours))]);
        return result;
    }
}
