
public class BassDrone extends Chubgraph
{
    TriOsc m => SinOsc c => outlet;
    2 => c.sync;
    0.03 => c.gain;
    
    40 => c.freq;
    c.freq()*0.5 => m.freq;
    70 => m.gain;
    
    // added: ge
    SinOsc lfo => Gain add => outlet;
    // step
    Step step => add;
    // set gain
    .5 => add.gain;
    // set setp
    1 => step.next;
    // set to multiply
    3 => outlet.op;
    // tech level
    1 => int techLevel;
    // set LFO freq
    .045 => lfo.freq;
    
    c.freq() => float freq_target;
    
    0 => int numConstruction;
    0 => int numCompleted;
    
    spork ~ go();
    
    setTechLevel(2);
    setUnderConstruction(0);
    setCompleted(0);
    fun void setUnderConstruction(int n)
    {
        n => numConstruction;
        //50*Math.pow(1.1,numConstruction+numCompleted) => freq_target;
        40 + (numConstruction+numCompleted)*1.5 => freq_target;
    }
    
    fun void setCompleted(int n)
    {
        n => numCompleted;
        //50*Math.pow(1.1,numConstruction+numCompleted) => freq_target;
        40 + (numConstruction+numCompleted)*1.5 => freq_target;
    }
    
    fun void setTechLevel(int n)
    {
        // 100*(n+1) => m.gain;
        n => techLevel;
        // set LFO freq
        // .08 - (techLevel * .01) => lfo.freq;
    }
    
    fun void go()
    {
        while(true)
        {
            c.freq() + (freq_target-c.freq())*0.0625 => c.freq;
            c.freq()*(1+lfo.last()*.25) => m.freq;
            1 + lfo.last()*(150*(1+techLevel)) => m.gain;
            5::ms => now;
        }
    }
}
