declare name "WaveGuide Clarinet from STK";
declare author "Romain Michon";
declare version "1.0"; 

import("math.lib");
import("music.lib");
import("filter.lib");
import("envelope.lib");
import("table.lib");

//==================== GUI SPECIFICATION ================

freq = nentry("freq", 440, 20, 20000, 1);
gain = nentry("gain", 1, 0, 1, 0.01); 
gate = button("gate");

noiseGain = hslider("noiseGain",0,0,1,0.01);
vibratoFreq = hslider("vibratoFreq",5,1,15,0.1);
vibratoGain = hslider("vibratoGain",0.1,0,1,0.01);
vibratoAttack = hslider("vibratoAttack",0.5,0,1,0.01);
reedStiffness = hslider("reedStiffness",0.5,0,1,0.01);

//==================== SIGNAL PROCESSING ================

reedTableOffset = 0.7;
reedTableSlope = -0.44 + (0.26*reedStiffness);

//Delay length as a number of samples 
delayLength = SR/freq * 0.5 - 1.5;

//One zero filter with with pole at -1
oneZero(x) = (_*0.5 + x*0.5)~_;

//Breath pressure + vibrato + breath noise + envelope (Attack / Decay / Sustain / Release)
envelope = adsr(0.01,0.05,100, 0.1,gate)*gain*0.9;
vibratoEnvelope = env_vibr(0.1*2*vibratoAttack,0.9*2*vibratoAttack,100,0.01,gate);
vibrato = osc(vibratoFreq) * vibratoGain * vibratoEnvelope;
breath = envelope + envelope * noise * noiseGain;
breathPressure = breath + breath*vibrato;

process =
	//Commuted Loss Filtering
	(oneZero*-0.95 - breathPressure <: 
	//Non-Linear Scattering
	reed(reedTableOffset,reedTableSlope)*_ + breathPressure) ~ 
	//Delay with Feedback
	delay(4096,delayLength) <: 
	//stereo
	_,_; 