class Plop extends Chubgraph
{
    SinOsc mod => TriOsc s => ADSR env => outlet;
    
    300 => mod.gain;
    env.set(10::ms, 20::ms, 0.5, 400::ms);
    
    fun float freq(float f)
    {
        f => s.freq;
        s.freq()*3.5 => mod.freq;
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
    
    ploppy.setNumVoices(32);
    0.1 => ploppy.gain;
    
    [36, 34, 39, 41] @=> int notes[];
    
    fun void plop()
    {
        ploppy.get() $ Plop @=> Plop @ plop;
        
        notes[Std.rand2(0,notes.cap()-1)] => Std.mtof => plop.freq;
        
        1 => plop.env.keyOn;
        100::ms => now;
        1 => plop.env.keyOff;
    }
    
    fun void plopPlus()
    {
        ploppy.get() $ Plop @=> Plop @ plop;
        
        notes[Std.rand2(0,notes.cap()-1)] + 24 => Std.mtof => plop.freq;
        
        1 => plop.env.keyOn;
        100::ms => now;
        1 => plop.env.keyOff;
    }
}

