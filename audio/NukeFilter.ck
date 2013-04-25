public class NukeFilter
{
    Bitcrusher distortion[8];
    
    0 => int numNukes;
    20::second => dur nukeTime;
    //1::second => dur nukeTime;
    1.0/1.38 => float gameTimeConversion;
    
    fun UGen @ input(int c) { return distortion[c]; }
    fun UGen @ output(int c) { return distortion[c]; }
    
    fun void nukeCalled()
    {
        spork ~ callNuke();
    }
    
    fun void callNuke()
    {
        nukeTime*gameTimeConversion => now;
        numNukes++;
        Std2.clamp(16-numNukes*3, 1, 32) $int => int bits;
        numNukes*6+1 => int dsFactor;
        Math.pow(7, -Std2.clamp(numNukes-3, 0, 2)) => float gain;
        
        for(int i; i < distortion.cap(); i++)
        {
            bits => distortion[i].bits;
            dsFactor => distortion[i].downsampleFactor;
            gain => distortion[i].gain;
        }
        //1.0/Math.log2(distortion.drive()) => distortion.gain;
    }
}