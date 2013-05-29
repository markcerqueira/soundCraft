

class GhostArp extends Arp
{
    SinOsc m => TriOsc c => LPF filter => ADSR envelope => outlet;
    ADSR filterEnvelope => blackhole;
    
    envelope.set(0.5::second, 0.5::second, 1.0, 0.5::second);
    //1 => envelope.keyOff;
    filterEnvelope.set(0.5::second, 0.5::second, 1.0, 5::second);
    //1 => filterEnvelope.keyOff;
    
    220 => c.freq;
    100 => m.gain;
    2 => c.sync;
    c.freq()*8 => filter.freq;
    20 => filter.Q;
    
    Math.pow(2.0,1.0/12.0) => float semitone;
    0 => float detune;
    
    spork ~ go();
    
    fun void go()
    {
        while(true)
        {
            //c.freq()+4000*filterEnvelope.value() => filter.freq;
            if(filter.freq() > second/samp/4)
                second/samp/4 => filter.freq;
            20::ms => now;
        }
    }
    
    fun float freq(float f)
    {
        f*Math.pow(semitone,Std.rand2f(-detune, detune)) => c.freq;
        c.freq() => filter.freq;
        c.freq() * 2 => m.freq;
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
        (2+20*techLevel)::ms => envelope.attackTime;
        Math.min(5+10*techLevel, 20)::ms => envelope.decayTime;
        Math.min(5+10*techLevel, 500)::ms => envelope.releaseTime;
    }
    
    fun dur length() { return envelope.attackTime(); }
}


class ArpPoly extends Poly
{
    fun UGen create()
    {
        GhostArp a;
        0.075 => a.gain;
        return a;
    }
}

public class GhostArpeggio extends MelodyArpeggio
{
    ArpPoly poly => Pan8 pan;
    6 => poly.gain;

    poly.setNumVoices(3);
    
    Lerp panVal;
    
    0 => int thecount;
    
    spork ~ go2();
    
    fun UGen @ output(int c) { return pan.chan(c); }
    
    fun Arp @ getArp() { return (poly.get() $ Arp); }
    // fun int[] getNotes() { return [36, 34, 39, 41]; }
    fun int[] getNotes() { return [12, 0]; }
    fun int getOctaves() { return 1; }
    fun dur getQuarterNote() { return 2::second; }
    fun int getMinSteps() { return 2; }
    fun int phaseShift() { return 0; }
    
    fun int stepStart() { return techLevel*2; }
    
    fun void set(int techLevel, int stepNo)
    {
        0.5+thecount/2.0 => panVal.target;
        thecount++;
    }
    
    fun void go2()
    {
        while(true)
        {
            panVal.lerp() => pan.pan;
            20::ms => now;
        }
    }
}


