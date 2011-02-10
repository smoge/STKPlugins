declare name "Blowed Botle instrument";
declare author "Romain Michon";
declare version "1.0"; 

import("math.lib");
import("music.lib");
import("filter.lib");
import("table.lib");

//==================== GUI SPECIFICATION ================

freq = nentry("freq", 440, 20, 20000, 1);
gain = nentry("gain", 0.9, 0, 1, 0.01); 
gate = button("gate");

vibratoGain = hslider("vibratoGain",0.1,0,1,0.01);
vibratoFreq = hslider("vibratoFreq",6,1,15,0.1);
noiseGain = hslider("noiseGain",0.5,0,1,0.01)*2;
pressure = hslider("pressure",1,0,1,0.01);

//==================== SIGNAL PROCESSING ================

botleRadius = 0.999;

//global envelope
envelopeG =  gain*adsr(gain*0.01,0.01,80,0.5,gate);

//pressure envelope (ADSR)
envelope = pressure*adsr(gain*0.02,0.01,80,gain*0.02,gate);

//vibrato
vibrato = osc(vibratoFreq)*vibratoGain;

breathPressure = envelope+vibrato;

//breath noise
randPressure = noiseGain*noise*breathPressure ;

process = 
	//differential pressure
	(breathPressure - _ <: 
	((1+_)*randPressure : breathPressure + _) - (jetTable*_),_ : bandPass(freq,botleRadius),_)~_ : !,_ : 
	//signal scaling
	dcblocker*envelopeG*0.5 <: _,_;