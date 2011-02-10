#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <iostream>
#include <sndfile.h>

#define MAX_PATH 1024

float tableRead (int index, const char* fileName, int fileSize)
{	
	SNDFILE	 	*infile = NULL ;
	SF_INFO	 	sfinfo ;
	float buf [fileSize], output ;

	if ((infile = sf_open (fileName, SFM_READ, &sfinfo)) == NULL)
	{	printf ("Not able to open input file\n") ;
		puts (sf_strerror (NULL)) ;
		return 1 ;
		} ;

	sf_readf_float (infile, buf, fileSize);
	output = buf[index];
	sf_close (infile) ;

	return output ;
}

//SineWave table, size: 1024
float readSineWave(int index){
	return tableRead(index,"/Users/romainmichon/Desktop/CCRMA/waves/sinewave.aiff",1024);
};

float readMand1(int index){
	return tableRead(index,"/Users/romainmichon/Desktop/CCRMA/mandolin/waves/mand1.aiff",1024);
};

float readImpuls20(int index){
	return tableRead(index,"/Users/romainmichon/Desktop/CCRMA/Faust-STK/puredatadir/waves/impuls20.aiff",256);
};

//marmstk1.aiff, size: 256
float readMarmstk1(int index){
	//char CurrentPath[MAX_PATH];
	//getcwd(CurrentPath, MAX_PATH);
	//strcat(CurrentPath, "/waves/marmstk1.aiff");
	return tableRead(index,"/Users/romainmichon/Desktop/CCRMA/Faust-STK/puredatadir/waves/marmstk1.aiff",256);
};




