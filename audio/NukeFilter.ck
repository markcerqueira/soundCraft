public class NukeFilter extends Chubgraph
{
    inlet => Bitcrusher distortion => outlet;
    
    //limiter.limit();
    
    //1 => distortion.drive;
    1 => distortion.gain;
    
    0 => int numNukes;
    20::second => dur nukeTime;
    //1::second => dur nukeTime;
    1.0/1.38 => float gameTimeConversion;
    
    fun void nukeCalled()
    {
        spork ~ callNuke();
    }
    
    fun void callNuke()
    {
        nukeTime*gameTimeConversion => now;
        numNukes++;
        Std2.clamp(16-numNukes*3, 1, 32) $int => distortion.bits;
        numNukes*6+1 => distortion.downsampleFactor;
        Math.pow(7, -Std2.clamp(numNukes-3, 0, 2)) => distortion.gain;
        //1.0/Math.log2(distortion.drive()) => distortion.gain;
    }
}