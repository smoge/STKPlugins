declare name "Banded Waveguide Modeled Glass Harmonica";
declare author "Romain Michon";
declare version "1.0"; 

import("math.lib");
import("music.lib");
import("filter.lib");
import("table.lib");

//==================== GUI SPECIFICATION ================

freq = nentry("freq", 440, 20, 20000, 1);
gain = nentry("gain", 0.8, 0, 1, 0.01); 
gate = button("gate");

select = nentry("selector",0,0,1,1);
integrationConstant = hslider("integrationConstant",0,0,1,0.01);
//trackVelocity = nentry("trackVelocity",0,0,1,1);
baseGain = hslider("baseGain",1,0,1,0.01);
bowPressure = hslider("bowPressure",0.2,0,1,0.01);
bowPosition = hslider("bowPosition",0,0,1,0.01);

//==================== MODAL PARAMETERS ================
nModes = 5;

modes0 = 1.0;
modes1 = 2.32;
modes2 = 4.25;
modes3 = 6.63;
modes4 = 9.38;

basegains0 = pow(0.999,1);
basegains1 = pow(0.999,2);
basegains2 = pow(0.999,3);
basegains3 = pow(0.999,4);
basegains4 = pow(0.999,5);

excitation = 1*gain/nModes;

//==================== SIGNAL PROCESSING ================

tableOffset = 0;
tableSlope = 10 - (9*bowPressure);

base = SR/freq;

//delay lengths in number of samples
delay0Length = base/modes0;
delay1Length = base/modes1;
delay2Length = base/modes2;
delay3Length = base/modes3;
delay4Length = base/modes4;

//delay lines
delay0 = delay(4096,delay0Length);
delay1 = delay(4096,delay1Length);
delay2 = delay(4096,delay2Length);
delay3 = delay(4096,delay3Length);
delay4 = delay(4096,delay4Length);

//Filter bank
radius = 1-PI*32/SR;

bandPass0 = bandPass(freq*modes0,radius);
bandPass1 = bandPass(freq*modes1,radius);
bandPass2 = bandPass(freq*modes2,radius);
bandPass3 = bandPass(freq*modes3,radius);
bandPass4 = bandPass(freq*modes4,radius);

//Delay lines feedback for bow table lookup control
baseGainApp = 0.8999999999999999 + (0.1 * baseGain);
velocityInputApp = integrationConstant;
velocityInput(fdbk0,fdbk1,fdbk2,fdbk3,fdbk4) = velocityInputApp + (baseGainApp*fdbk0) : 
	_+(baseGainApp*fdbk1) :
	_+(baseGainApp*fdbk2) :
	_+(baseGainApp*fdbk3) :
	_+(baseGainApp*fdbk4);

//Bow velocity is controled by an ADSR envelope
maxVelocity = 0.03 + (0.1 * gain);
//bowTarget = _ + 0.005 * ;
//bowVelocity = (maxVelocity*adsr(0.02,0.005,90,0.01,gate))*(1-trackVelocity) + ((_*0.9995 : _+ bowTarget));
bowVelocity = maxVelocity*adsr(0.02,0.005,90,0.01,gate);

//Bow table lookup
input = (bowVelocity - velocityInput) <: _*bow(tableOffset,tableSlope) : _/nModes;

//Resonance system
resonance0(in0) = (_+in0+(excitation*select) : delay0 : _*basegains0 : bandPass0);
resonance1(in1) = (_+in1+(excitation*select) : delay1 : _*basegains1 : bandPass1);
resonance2(in2) = (_+in2+(excitation*select) : delay2 : _*basegains2 : bandPass2);
resonance3(in3) = (_+in3+(excitation*select) : delay3 : _*basegains3 : bandPass3);
resonance4(in4) = (_+in4+(excitation*select) : delay4 : _*basegains4 : bandPass4);

process =
		//Bowed Excitation
		(input*((select-1)*-1) <: 
		resonance0(_)~_,resonance1(_)~_,resonance2(_)~_,resonance3(_)~_,
		resonance4(_)~_) ~(_,_,_,_,_) : _,_,_,_,_,0 :> + : 
		//Signal Scaling and stereo
		_*4 <: _,_;