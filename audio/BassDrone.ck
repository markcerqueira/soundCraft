
public class BassDrone
{
    SinOsc m => SinOsc c => NRev reverb => dac;
    2 => c.sync;
    0.025 => c.gain;
    
    50 => c.freq;
    c.freq()*0.5 => m.freq;
    100 => m.gain;
    
    0.1 => reverb.mix;
    
    c.freq() => float freq_target;
    
    0 => int numConstruction;
    0 => int numCompleted;
    
    spork ~ go();
    
    fun void setUnderConstruction(int n)
    {
        n => numConstruction;
        50*Math.pow(1.1,numConstruction+numCompleted) => freq_target;
    }
    
    fun void setCompleted(int n)
    {
        n => numCompleted;
        50*Math.pow(1.1,numConstruction+numCompleted) => freq_target;
    }
    
    fun void setTechLevel(int n)
    {
        100*(n+1) => m.gain;
    }
    
    fun void go()
    {
        while(true)
        {
            c.freq() + (freq_target-c.freq())*0.25 => c.freq;
            c.freq()*0.5 => m.freq;
            20::ms => now;
        }
    }
}
