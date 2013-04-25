
class MarineArp extends Arp
{
    SawOsc c => LPF filter => ADSR envelope => outlet;
    ADSR filterEnvelope => blackhole;
    
    envelope.set(5::ms, 5::ms, 1, 5::ms);
    1 => envelope.keyOff;
    filterEnvelope.set(50::ms, 100::ms, 0.5, 100::ms);
    1 => filterEnvelope.keyOff;
    
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
    
    fun void set(int techLevel, int stepNo)
    {
        (5+10*techLevel)::ms => envelope.attackTime;
        Math.min(5+10*techLevel, 20)::ms => envelope.decayTime;
        Math.min(5+10*techLevel, 200)::ms => envelope.releaseTime;
    }
    
    fun dur length() { return envelope.attackTime(); }
}


class ArpPoly extends Poly
{
    fun UGen create()
    {
        MarineArp a;
        0.075 => a.gain;
        return a;
    }
}

public class MarineArpeggio extends MelodyArpeggio
{
    ArpPoly poly => Pan8 pan;
    6 => poly.gain;

    poly.setNumVoices(8);
    
    0 => int thecount;
    
    //fun UGen @ output() { return poly; }
    fun UGen @ output(int c) { return pan.chan(c); }
    
    fun Arp @ getArp() { return (poly.get() $ Arp); }
    fun int[] getNotes() { return [36, 34, 39, 41]; }
    fun int getOctaves() { return 3; }
    fun dur getQuarterNote() { return 0.125::second; }
    fun int getMinSteps() { return 8; }
    fun int phaseShift() { return 0; }
    
    fun void set(int techLevel, int stepNo)
    {
        0.5+thecount/2.0 => pan.pan;
        thecount++;
    }
}

