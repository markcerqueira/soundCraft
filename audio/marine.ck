class Arp extends Chubgraph
{
    fun float freq(float f) { return f; }
    fun void keyOn() { }
    fun void keyOff() { }
}

class MarineArp extends Arp
{
    SawOsc c => LPF filter => ADSR envelope => outlet;
    ADSR filterEnvelope => blackhole;
    
    envelope.set(20::ms, 20::ms, 1, 100::ms);
    1 => envelope.keyOff;
    filterEnvelope.set(50::ms, 100::ms, 0.5, 100::ms);
    1 => filterEnvelope.keyOff;
    
    //0 => envelope.value;
    //0 => filterEnvelope.value;
    
    220 => c.freq;
    c.freq()*8 => filter.freq;
    2 => filter.Q;
    
    spork ~ go();
    
    fun void go()
    {
        while(true)
        {
            c.freq()+4000*filterEnvelope.value() => filter.freq;
            if(filter.freq() > second/samp/4)
                second/samp/4 => filter.freq;
            20::ms => now;
        }
    }
    
    fun float freq(float f)
    {
        f => c.freq;
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


MarineArp a => dac;
220 => a.freq;
a.keyOn();
0.25::second => now;
a.keyOff();
0.25::second => now;

