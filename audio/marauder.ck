
class Arp extends Chubgraph
{
    fun float freq(float f) { return f; }
    fun void keyOn() { }
    fun void keyOff() { }
}

class MarauderArp extends Arp
{
    SinOsc m => SinOsc c => LPF filter => ADSR envelope => outlet;
    ADSR filterEnvelope => blackhole;
    2 => c.sync;
    200 => m.gain;
    
    
    envelope.set(20::ms, 10::ms, 0.4, 100::ms);
    1 => envelope.keyOff;
    filterEnvelope.set(20::ms, 100::ms, 0.5, 100::ms);
    1 => filterEnvelope.keyOff;
    
    220 => c.freq;
    c.freq()*8 => filter.freq;
    2 => filter.Q;
    2 => c.gain;
    
    spork ~ go();
    
    fun void go()
    {
        while(true)
        {
            c.freq()+1000*filterEnvelope.value() => filter.freq;
            if(filter.freq() > second/samp/4)
                second/samp/4 => filter.freq;
            20::ms => now;
        }
    }
    
    fun float freq(float f)
    {
        f => c.freq;
        f*0.25 => m.freq;
        return f;
    }
    
    fun void keyOn()
    {
        1 => envelope.keyOn;
        1 => filterEnvelope.keyOn;
    }
    
    fun void keyOff()
    {
        1 => envelope.keyOff;
        1 => filterEnvelope.keyOff;
    }
}


MarauderArp a => dac;
220 => a.freq;
a.keyOn();
0.25::second => now;
a.keyOff();
0.25::second => now;

