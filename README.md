GXPlugins
==========

This project contains the core dsp code from the [FAUST-STK Project](http://guitarix.sourceforge.net/) that is written in the [Faust Programming Language](http://faust.grame.fr/).

Since it is possible to compile Faust code for several kinds of systems or standalone applications, the STKPlugins project tries to make a SuperCollider DSP Plugins out of each Faust module.

Compilation
-----------

To compile this plugins you have to have SuperCollider and Faust installed. You will also need the faust2sc programm. If your distribution does not provide this programm, install it looking at the /tools folder in the Faust source code.

Edit the build.sh script and make sure `SC_SOURCE_DIR=` is set to your SuperCollider-Source/common folder. Also check if `FAUST2SC=` is correctly set.

If everything is right, you can install like this:

    git clone git://github.com/smoge/stkplugins.git
    cd stkplugins
    ./build.sh


The generated files will be placed in the GXPlugins folder.


Packagers
---------

If you want to package STKPlugins, you can use the `DESTDIR=` variable to your $pkgdir folder.


FAUST-STK PROJECT
=================

WHAT IS IT?
----------

This project aims to implement the instruments and some audio effects from the Synthesis Tool Kit (STK) in the FAUST programming language. The Synthesis Tool Kit is a set of open source audio signal processing and algorithmic synthesis classes written in the C++ programming language. Faust AUdio STreams is a functional programming language for realtime audio signal processing developed at GRAME in Lyon (France). The Faust compiler translates DSP specifications into efficient C++ code. 

This work is being conducted at Stanford University CCRMA (Center for Computer Research in Music and Acoustics) and Jean-Monnet university (Saint-Etienne, France) CIEREC (Centre Interdisciplinaire d'Etude et de Recherche sur l'Expression Contemporaine) in the frame of the ASTREE project (Analyse et Synthèse de Traitement Temps Réel, ANR-08-CORD-003).      
The instruments will be documented using the Faust automatic documentation generator. Another goal of this project is to create a set of C++ functions to load parameters texts files and wave files in Faust in order to use any kind of raw datas for tables lookups. Inputing parameters texts files in Faust will make it possible to handle important number of datas requiered for some synthesis algorithms such as modal synthesis.  The current package (01/28/2011) contains the following instruments:

+ bowed.dsp: A bowed string instrument physical model using WaveGuide synthesis.
+ brass.dsp: A brass instrument physical model using WaveGuide synthesis.	
+ clarinet.dsp: A simple clarinet physical model using WaveGuide synthesis.
+ flute.dsp: A flute physical model using WaveGuide synthesis.
+ flutestk.dsp: A simple flute physical model based on the STK algorithm and using WaveGuide synthesis.
+ glassHarmonica.dsp: A banded WaveGuide modeled glass instrument.
+ saxophony.dsp: A simple saxophone physical model using WaveGuide synthesis.
+ tibetanBowl.dsp: A banded WaveGuide modeled Tibetan Bowl. 
+ tundeBar.dsp: A banded WaveGuide modeled Tuned Bar.
+ uniBar.dsp: A banded WaveGuide modeled uniform Bar.
+ modalBar.dsp: A set of modal percussive instruments (Marimba, Vibraphone, Agogo Bell, WoodBlock, Clump, sticks). Some bugs still remains to be fixed (File path problem for table look up in PureData).
+ voiceForm.dsp: This instrument contains an excitation singing wavetable (looping wave with random and periodic vibrato, smoothing on frequency, etc.), excitation noise, and four sweepable complex resonances.
Measured formant data is included, and enough data is there to support either parallel or cascade synthesis.  In the floating point case cascade synthesis is the most natural so that's what you'll find here.
+ blowHole.dsp: A clarinet physical model using WaveGuide synthesis with a tone hole.  


STK-FAUST CONTACTS 
-------------------


    Any question or suggestion, send us an e-mail at:

    rmichon@ccrma.stanford.edu

Romain MICHON 
