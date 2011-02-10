declare name "WaveGuide Bowed Instrument from STK";
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

vibratoGain = hslider("vibratoGain",0.02,0,1,0.01);
vibratoFreq = hslider("vibratoFreq",6,1,15,0.1);
bowPosition = hslider("bowPosition",0.8,0.01,1,0.01);
bowPressure = hslider("bowPressure",0.5,0,1,0.01);

//==================== SIGNAL PROCESSING ================

//Parameters for bow table look-up
tableOffset =  0;
tableSlope = 5 - (4*bowPressure);

//The shape of the envelope (Attack / Decay / Sustain / Release) is calculated in function of the global amplitude
envelope = adsr(gain*0.01,0.005,90, (1-gain)*0.005,gate);
maxVelocity = 0.03 + (0.2 * gain);

//Delay length in number of samples calculated in function of freq and bowPosition
betaRatio = 0.027236 + (0.2*bowPosition);
fdelneck = (SR/freq-4) * (1 - betaRatio);
fdelbridge = (SR/freq-4) * betaRatio;

vibrato = fdelneck + ((SR/freq-4)*vibratoGain*osc(vibratoFreq));

//Body Filter: a biquad filter with a normalized pick gain
bodyFilter = TF2(b0,b1,b2,a1,a2)
	with{
		b0= 0.5-0.5*a2;
		b1= 0;
		b2= -b0;
		a1= -2*0.85*cos(2*PI*500/SR);
		a2= 0.85*0.85;
	};

//Bridge Filter: a lowpass filter whose cut-off frequency is 5KHz
bridgeFilter = lowpass(1,5000);

bowVelocity = envelope*maxVelocity;

newVel = hgroup("Differential Velocity",bowVelocity-_) <: 
		hgroup("Bow Table",(bow(tableOffset,tableSlope)*_));

bridge(input) = _+(-bridgeFilter(input*0.95));
bowAndString(x,y) = newVel(x)<:_,_+y;

instrumentBody(x) = ((hgroup("Nut Reflexion",_*-1) <:
					hgroup("Bow, String and Bridge", bridge(x),_ : bowAndString) : bridge(x),_)) ~ 
					hgroup("Neck Delay",delay(4096,vibrato)) : !,_;

process = instrumentBody ~ delay(4096,fdelbridge) : bodyFilter(_*0.2) <: _,_;