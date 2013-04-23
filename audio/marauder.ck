
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
    1.1 => filter.Q;
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
    
    fun void set(int techLevel, int stepNo)
    {
        20::ms*(techLevel+1) => envelope.attackTime;
    }
    
    fun dur length() { return envelope.attackTime() + envelope.decayTime(); }
}


class ArpPoly extends Poly
{
    fun UGen create()
    {
        MarauderArp a;
        0.1 => a.gain;
        return a;
    }
}

public class MarauderArpeggio extends Arpeggio
{
    ArpPoly poly => NRev reverb => dac;
    0.05 => reverb.mix;
    1 => poly.gain;
    
    poly.setNumVoices(8);
    
    fun Arp @ getArp() { return (poly.get() $ Arp); }
    fun int[] getNotes() { return [39, 41, 36, 34]; }
    fun int getOctaves() { return 3; }
    fun dur getQuarterNote() { return 0.125::second; }
    fun int phaseShift() { return 4; }
}


// MarauderArp a => dac;
// 220 => a.freq;
// a.keyOn();
// 0.25::second => now;
// a.keyOff();
// 0.25::second => now;
// 
