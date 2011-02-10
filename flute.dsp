declare name "WaveGuide Flute";
declare author "Romain Michon";
declare version "1.0"; 

import("math.lib");
import("music.lib");
import("filter.lib");
import("envelope.lib");

//==================== GUI SPECIFICATION ================

freq = nentry("freq", 440, 20, 20000, 1);
gain = 10*nentry("gain", 0.5, 0, 1, 0.01); 
gate = button("gate");

vibratoFreq = hslider("vibratoFreq",5,3,10,0.1);
vibratoGain = hslider("vibratoGain",0.5,0,1,0.01);
noiseGain = hslider("noiseGain",0.6,0,1,0.01)/100;
pressure = hslider("presure",0.9,0,1,0.01);

//==================== SIGNAL PROCESSING ================

//Envelopes for pressure, vibrato and the global amplitude
pressureEnvelope = adsr(0.06,0.2,100*pressure,0.1,gate);
globalEnvelope = gain*asr(0.01,100,0.1,gate);
vibratoEnvelope = vibratoGain*env_vibr(0.5,0.5,100,0.01,gate);

//Loops feedbacks gains
feedback1 = 0.4;
feedback2 = 0.4;

//Delay lines length in number of samples
fqc1 = (SR/freq - 10)/2;
fqc2 = SR/freq - 10;

//Polinomial
cubic(x) = (_-_*_*_);

vibrato = osc(vibratoFreq);

//Noise + vibrato + pressure
blow = (noiseGain*noise) + (0.1*vibrato*vibratoEnvelope) + (pressure*1.1*pressureEnvelope);

//Instrument
bore = (+ : delay(4096, fqc1)) ~ 
	(_<:cubic : (+ : lowpass(1,2000) : delay(4096, fqc2)) ~ (* (feedback2)))*(feedback1);

process = blow : bore : _*globalEnvelope <: _,_;