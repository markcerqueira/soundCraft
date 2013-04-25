
class MedivacArp extends Arp
{
    SinOsc m => SqrOsc c => LPF filter => ADSR envelope => outlet;
    SinOsc fmod => ADSR filterEnvelope => blackhole;
    2 => c.sync;
    2000 => m.gain;
    
    0.1 => fmod.freq;
    
    envelope.set(100::ms, 50::ms, 0.8, 150::ms);
    1 => envelope.keyOff;
    filterEnvelope.set(525::ms, 525::ms, 0.5, 425::ms);
    1 => filterEnvelope.keyOff;
    -1 => filterEnvelope.op;
    
    220 => c.freq;
    c.freq()*8 => filter.freq;
    2 => filter.Q;
    
    int techLevel;
    
    spork ~ go();
    
    fun void go()
    {
        while(true)
        {
            c.freq()+3000*Math.pow(techLevel+2,filterEnvelope.last()*1.25) => filter.freq;
            if(filter.freq() > second/samp/4)
                second/samp/4 => filter.freq;
            20::ms => now;
        }
    }
    
    fun float freq(float f)
    {
        f*2 => c.freq;
        f*8 => m.freq;
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
    
    fun void set(int _techLevel, int stepNo)
    {
        _techLevel => techLevel;
    }
    
    fun dur length() { return envelope.attackTime() + envelope.decayTime(); }
}


class ArpPoly extends Poly
{
    fun UGen create()
    {
        MedivacArp a;
        0.075 => a.gain;
        return a;
    }
}

public class MedivacArpeggio extends MelodyArpeggio
{
    ArpPoly poly => Pan8 pan;
    6 => poly.gain;
    
    poly.setNumVoices(8);
    
    fun UGen @ output(int c) { return pan.chan(c); }
    fun Arp @ getArp() { return (poly.get() $ Arp); }
    fun int[] getNotes() { return [39, 41, 36, 34]; }
    fun int getOctaves() { return 3; }
    fun dur getQuarterNote() { return 2::second; }
    fun int getMinSteps() { return 1; }
    fun int phaseShift() { return 0; }
    
    fun void set(int techLevel, int stepNo)
    {
        Std.rand2f(0,8) => pan.pan;
    }
}

