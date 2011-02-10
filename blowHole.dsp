declare name "WaveGuide Clarinet with holes model";
declare author "Romain Michon";
declare version "1.0"; 

import("math.lib");
import("music.lib");
import("filter.lib");
import("envelope.lib");
import("table.lib");

//==================== GUI SPECIFICATION ================

freq = nentry("freq", 440, 100, 2000, 1);
gain = nentry("gain", 0.9, 0, 1, 0.01); 
gate = button("gate");

toneHoleOpenness = hslider("toneHoleOpenness",0,0,1,0.01);
ventOpenness = hslider("ventOpenness",0,0,1,0.01);
reedStiffness = hslider("reedStiffness",0.35,0,1,0.01);
noiseGain = hslider("noiseGain",0.05,0,1,0.01);
vibratoGain = hslider("vibratoGain",0.05,0,1,0.01);
vibratoFreq = hslider("vibratoFreq",6,1,15,0.1);
vibratoAttack = hslider("vibratoAttack",0.5,0,1,0.01);

//==================== SIGNAL PROCESSING ================

//parameters for the reed table look-up
reedTableOffset = 0.7;
reedTableSlope = -0.44 + (0.26*reedStiffness);

//filters declaration: to add in the external lib
poleZero(b0,b1,a1,x) = (b0*x + b1*x' - a1*_)~_;
oneZero(x) = (_*0.5 + x*0.5)~_;

// Calculate the initial tonehole three-port scattering coefficient
rb = 0.0075;    // main bore radius
rth = 0.003;    // tonehole radius
scatter = pow(rth,2)*-1 / ( pow(rth,2) + 2*pow(rb,2) );

// Calculate register hole filter coefficients
r_rh = 0.0015; 	// register vent radius
teVent = 1.4*r_rh;	 // effective length of the open hole
xi = 0 ; 	// series resistance term
zeta = 347.23 + 2*PI*pow(rb,2)*xi/1.1769;
psi = 2*PI*pow(rb,2)*teVent / (PI*pow(r_rh,2));
rhCoeff = (zeta - 2 * SR * psi) / (zeta + 2 * SR * psi);
rhGain = -347.23 / (zeta + 2 * SR * psi);
ventFilterGain = rhGain*ventOpenness;

// Vent filter
vent = _*ventFilterGain : poleZero(1,1,rhCoeff);

teHole = 1.4*rth; // effective length of the open hole
coeff = (teHole*2*SR-347.23)/(teHole*2*SR+347.23);
scaledCoeff = (toneHoleOpenness*(coeff - 0.9995)) + 0.9995;

//register hole filter
toneHoleFilter = _*1 : poleZero(b0,-1,a1)
	with{
		b0 = scaledCoeff;
		a1 = -scaledCoeff;
	};

//delay lengths in number of samples
delay0Freq = 5*SR/22050;
delay2Freq = 4*SR/22050;
delay1Freq = (SR/freq*0.5-3.5) - (delay0Freq + delay2Freq);

//fractional delay lines
delay0 = fdelay(4096,delay0Freq);
delay1 = fdelay(4096,delay1Freq);
delay2 = fdelay(4096,delay2Freq);

//envelope(ADSR) + vibrato + noise
envelope = (0.55+gain*0.3)*asr(gain*0.01,100,gain*0.1,gate);
vibratoEnvelope = env_vibr(0.1*2*vibratoAttack,0.9*2*vibratoAttack,100,0.01,gate);
vibrato = vibratoGain*osc(vibratoFreq)*vibratoEnvelope;
breath = envelope + envelope*noiseGain*noise;
breathPressure = breath + (breath*vibrato);

//two-port junction scattering for register vent
twoPortJunction(portB) = (pressureDiff : (portA(breathPressure) <: (_+portB : vent <: _ + portB,_),_))~delay0 : inverter
	with{
		pressureDiff = _-breathPressure; 
		portA(x) = _ <: x + _*reed(reedTableOffset,reedTableSlope);
		inverter(a,b,c) = b,c,a;
	};

//three-port junction scattering (under tonehole)
threePortJunction(x) =  (_ <: junctionScattering(x),_ : _+x,_+_ : oneZero*-0.95,_)~delay2 : !,_
	with{
		toneHole(temp,portA2,portB2) = (portA2+portB2-_+temp : toneHoleFilter)~_;
		junctionScattering(portA2,portB2) = (((portA2+portB2-2*_)*scatter) <: toneHole(_,portA2,portB2),_,_)~_ : !,_,_;
	};

process = (twoPortJunction : (_+_ : threePortJunction),_) ~ delay1 : !,_ <: _,_;