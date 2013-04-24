
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
        0.04 => a.gain;
        return a;
    }
}

public class MarineArpeggio extends MelodyArpeggio
{
    ArpPoly poly;
    1 => poly.gain;
    
    poly.setNumVoices(8);
    
    fun UGen @ output() { return poly; }
    fun Arp @ getArp() { return (poly.get() $ Arp); }
    fun int[] getNotes() { return [36, 34, 39, 41]; }
    fun int getOctaves() { return 3; }
    fun dur getQuarterNote() { return 0.125::second; }
    fun int getMinSteps() { return 8; }
    fun int phaseShift() { return 0; }
}


// MarineArp a => dac;
// 220 => a.freq;
// a.keyOn();
// 0.25::second => now;
// a.keyOff();
// 0.25::second => now;

