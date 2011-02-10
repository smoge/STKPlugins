declare name "Voice Formant Instrument";
declare author "Romain Michon";
declare version "1.0"; 

import("math.lib");
import("music.lib");
import("filter.lib");
import("envelope.lib");

//==================== GUI SPECIFICATION ================

freq = nentry("freq", 440, 20, 20000, 1);
gain = nentry("gain", 1, 0, 1, 0.01); 
gate = button("gate");

phoneme = nentry("phoneme",4,0,20,1);
vibratoFreq = hslider("vibratoFreq",6,1,15,0.1);
vibratoGain = hslider("vibratoGain",0.05,0,1,0.01);
interpFactor = hslider("interpFactor",0.999,0,0.999,0.001);

//==================== SIGNAL PROCESSING ================

//filters declaration (should be integrated in the external lib)
onePole(pole,x) = (b0*x - a1*_)~_
	with{
		b0 = 1-pole;
		a1 = -pole;	
	};
oneZero(zero,x) = x'*b1 + x*b0
	with{
		b0 = 1/(1-zero);
		b1 = -zero*b0;
	};

//the formants filter is a biquad with a constant unity peak gain
formSwep(frequency,radius,filterGain) = _*gain_ : TF2(b0,b1,b2,a1,a2)
	with{
		//filter's radius, gain and frequency are interpolated
		radius_ = radius : smooth(interpFactor);
		frequency_ = frequency : smooth(interpFactor);
		gain_ = filterGain : smooth(interpFactor);
		
		a1 = -2*radius_*cos(2*PI*frequency_/SR) ;
		a2 = radius_*radius_;	
		b0 = 0.5-0.5*a2;
		b1 = 0;
		b2 = -b0;
	};

//formants parameters are countained in a C++ file
phonemeGains = ffunction(float loadPhonemeGains(int,int), <phonemes.h>,"");
phonemeParameters = ffunction(float loadPhonemeParameters(int,int,int), <phonemes.h>,"");

//formants frequencies
ffreq0 = phonemeParameters(phoneme,0,0);
ffreq1 = phonemeParameters(phoneme,1,0);
ffreq2 = phonemeParameters(phoneme,2,0);
ffreq3 = phonemeParameters(phoneme,3,0);

//formants radius
frad0 = phonemeParameters(phoneme,0,1);
frad1 = phonemeParameters(phoneme,1,1);
frad2 = phonemeParameters(phoneme,2,1);
frad3 = phonemeParameters(phoneme,3,1);

//formants gains
fgain0 = phonemeParameters(phoneme,0,2) : pow(10,(_/20));
fgain1 = phonemeParameters(phoneme,1,2) : pow(10,(_/20));
fgain2 = phonemeParameters(phoneme,2,2) : pow(10,(_/20));
fgain3 = phonemeParameters(phoneme,3,2) : pow(10,(_/20));

//gain of the voiced part od the sound
voiceGain = phonemeGains(phoneme,0) : smooth(interpFactor);

//gain of the fricative part of the sound 
noiseGain = phonemeGains(phoneme,1) : smooth(interpFactor);

//formants filters
filter0 = formSwep(ffreq0,frad0,fgain0);
filter1 = formSwep(ffreq1,frad1,fgain1);
filter2 = formSwep(ffreq2,frad2,fgain2);
filter3 = formSwep(ffreq3,frad3,fgain3);

//the voice source is read from a table (impuls20.aiff)
voiced = rdtable(impuls20TableSize, impuls20, int(phaser)) : _*voiceGain*asr(0.01,100,0.01,gate)
	with{
		impuls20TableSize = 256;
		vibrato = osc(vibratoFreq)*vibratoGain*100;
		readImpuls20 = ffunction(float readImpuls20(int), <readTable.h>,"");
		impuls20 = time%impuls20TableSize : int : readImpuls20;
		phaser = (freq+vibrato)/float(samplingfreq) : (+ : decimal) ~ _ : *(float(impuls20TableSize));
	};

//ficative sounds are produced by a noise generator
frica = noise*asr(0.001,100,0.001,gate)*noiseGain;

process = voiced : oneZero(-0.9) : onePole(0.97 - (gain*0.2)) : 
		_ + frica <: filter0,filter1,filter2,filter3 :> + <: _,_;