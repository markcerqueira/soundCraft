public class Plopper
{
    NRev reverb => dac;
    0.1 => reverb.mix;
    0.1 => reverb.gain;
    
    fun void plop()
    {
        SinOsc mod => TriOsc s => ADSR env => reverb;
        
        [36, 34, 39, 41] @=> int notes[];
        
        notes[Std.rand2(0,notes.cap()-1)] => Std.mtof => s.freq;
        s.freq()*3.5 => mod.freq;
        300 => mod.gain;
        env.set(10::ms, 20::ms, 0.5, 400::ms);
        
        1 => env.keyOn;
        100::ms => now;
        
        1 => env.keyOff;
        
        1::second => now;
    }
    
    fun void plopPlus()
    {
        SinOsc mod => TriOsc s => ADSR env => reverb;
        
        [36, 34, 39, 41] @=> int notes[];
        
        notes[Std.rand2(0,notes.cap()-1)] + 24 => Std.mtof => s.freq;
        s.freq()*3.5 => mod.freq;
        300 => mod.gain;
        env.set(10::ms, 20::ms, 0.5, 400::ms);
        
        1 => env.keyOn;
        100::ms => now;
        
        1 => env.keyOff;
        
        1::second => now;
    }
}

