declare name "WaveGuide Brass from STK";
declare author "Romain Michon";
declare version "1.0"; 

import("math.lib");
import("music.lib");
import("filter.lib");

//==================== GUI SPECIFICATION ================

freq = nentry("freq", 440, 100, 2000, 1);
gain = nentry("gain", 1, 0, 1, 0.01); 
gate = button("gate");

pressure = hslider("pressure",1,0.01,1,0.01);
lipTension = hslider("lipTension",0.5,0.01,1,0.01);
vibratoFreq = hslider("vibratoFreq",6,1,15,0.1);
vibratoGain = hslider("vibratoGain",0.01,0,1,0.01);
slideLength = hslider("slideLength",0.5,0.01,1,0.01);

//==================== SIGNAL PROCESSING ================

//biquad filter whose poles are calculated in function of lips tension
lipFilterFrequency = freq*pow(4,(2*lipTension)-1);
lipFilter = TF2(b0,b1,b2,a1,a2)
	with{
		a1 = -2*0.997*cos(2*PI*lipFilterFrequency/SR);
		a2 = 0.997*0.997;
		b0 = 1;
		b1 = 0;
		b2 = 0;
	};
//function for non-linear saturation
clipingFunction(x) = x<: (_>1),(_<=1 : _*x) :> _+_;
vibrato = vibratoGain*osc(vibratoFreq);

//delay times in number of samples
freqDelay = ((SR/freq)*2 + 3)*slideLength;
boreDelay = delay(4096,freqDelay);

//envelope (Attack / Decay / Sustain / Release), breath pressure and vibrato
breathPressure = pressure*gain*adsr(0.005,0.001,100, 0.01,gate) + vibrato;
mouthPressure = 0.3 * breathPressure;

//scale the delay feedback
borePressure = _*0.85;

//differencial presure
deltaPressure = mouthPressure - _ : 
				//lips are simulated by a biquad filter whose output is squared and hard-clipped
				lipFilter(_*0.03) <: _*_ : clipingFunction;

bore(x) = deltaPressure(x) <: _*mouthPressure,(1-_)*x :> + ;

process = (borePressure <:bore :
		  //Body Filter
		  dcblocker) ~ boreDelay <: _,_;