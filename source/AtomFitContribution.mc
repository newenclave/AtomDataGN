using Toybox.FitContributor as Fit;
using Toybox.Application as App;

class AtomFitContribution {

    const FIELD_DOSE_POWER = 0;
    const FIELD_TEMPERATURE = 1;
    const FIELD_SESSION_DOSE = 2;
    const FIELD_DOSE_POWER_ROENTGEN = 3;
    const FIELD_SESSION_DOSE_ROENTGEN = 4;

    private var _doseRate;
    private var _temperature;
    private var _sessionDoze;
    private var _useR;

    function initialize(activity) {
        self._useR = App.getApp().isRoentgen();

        if(self._useR) {
            self._doseRate = activity.createField("dose_rate",
                FIELD_DOSE_POWER_ROENTGEN,
                Fit.DATA_TYPE_FLOAT, {
                    :units => "microroentgen"
                });
            self._sessionDoze = activity.createField("session_dose",
                FIELD_SESSION_DOSE_ROENTGEN,
                Fit.DATA_TYPE_FLOAT, {
                    :units => "milliroentgen",
                    :mesgType => Fit.MESG_TYPE_SESSION,
                });
        } else {
            self._doseRate = activity.createField("dose_rate",
                FIELD_DOSE_POWER,
                Fit.DATA_TYPE_FLOAT, {
                    :units => "microsieverts"
                });
            self._sessionDoze = activity.createField("session_dose",
                FIELD_SESSION_DOSE,
                Fit.DATA_TYPE_FLOAT, {
                    :units => "millisieverts",
                    :mesgType => Fit.MESG_TYPE_SESSION,
                });
        }

        self._temperature = activity.createField("temperature",
            FIELD_TEMPERATURE,
            Fit.DATA_TYPE_SINT8, {
                :units => "celsius"
            });

    }

    function update(data) {
        if(self._useR) {
            self._doseRate.setData(data.get(:doseRate) * 100.0);
            self._sessionDoze.setData(data.get(:sessionDoze) * 100.0);
        } else {
            self._doseRate.setData(data.get(:doseRate));
            self._sessionDoze.setData(data.get(:sessionDoze));
        }
        self._temperature.setData(data.get(:temperature));
    }
}
