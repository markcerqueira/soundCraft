class Plop extends Chubgraph
{
    SinOsc mod => SinOsc s => HPF hpf => ADSR env => outlet;
    
    // added: ge
    500 => hpf.freq;
    300 => mod.gain;
    env.set(15::ms, 20::ms, 0.01, 50::ms);
    
    fun float freq(float f)
    {
        f => s.freq;
        s.freq()*2.5 => mod.freq;
        return f;
    }
}

class PlopPoly extends Poly
{
    fun UGen @ create()
    {
        return new Plop;
    }
}

public class Plopper extends Chubgraph
{
    PlopPoly ploppy => outlet;
    
    ploppy.setNumVoices(12);
    0.1 => ploppy.gain;
    
    // [36, 34, 39, 41] @=> int notes[];
    [72, 68, 78, 82] @=> int notes[];
    
    fun void plop()
    {
        ploppy.get() $ Plop @=> Plop @ plop;
        
        notes[Std.rand2(0,notes.cap()-1)] => Std.mtof => plop.freq;
        
        1 => plop.env.keyOn;
        40::ms => now;
        1 => plop.env.keyOff;
    }
    
    fun void plopPlus()
    {
        ploppy.get() $ Plop @=> Plop @ plop;
        
        notes[Std.rand2(0,notes.cap()-1)] + 24 => Std.mtof => plop.freq;
        
        1 => plop.env.keyOn;
        40::ms => now;
        1 => plop.env.keyOff;
    }
}

