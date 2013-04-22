
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


class ArpPoly extends Poly
{
    fun UGen create()
    {
        MarauderArp a;
        0.1 => a.gain;
        return a;
    }
}

public class MarauderArpeggio
{
    ArpPoly poly => NRev reverb => dac;
    0.05 => reverb.mix;
    1 => poly.gain;
    
    poly.setNumVoices(8);
    
    [36, 34, 39, 41] @=> int notes[];
    3 => int nOctave;
    
    int nSteps;
    8 => int minSteps;
    
    0 => int techLevel;
    
    fun void setNumber(int n)
    {
        n => nSteps;
    }
    
    fun void setTechLevel(int n)
    {
        n => techLevel;
    }
    
    spork ~ go();
    
    fun void go()
    {
        0.125::second => dur quarter;
        
        while(true)
        {
            int noteIndex;
            1 => int noteInc;
            
            for(int i; i < nSteps; i++)
            {
                (poly.get() $ MarauderArp) @=> MarauderArp @ arp;
                20::ms*(techLevel+1) => arp.envelope.attackTime;
                
                noteIndex/notes.cap() => int octave;
                if(octave > 4)
                {
                    1 +=> noteInc;
                    -noteInc => noteInc;
                    4 => octave;
                }
                
                notes[noteIndex%notes.cap()] + octave*12 + 12 => int note;
                //<<< "arp note:", note >>>;
                if(i == nSteps/2)
                    -noteInc => noteInc;
                noteInc +=> noteIndex;
                if(noteIndex < 0)
                {
                    0 => noteIndex;
                    -noteInc => noteInc;
                }
                
                note => Std.mtof => arp.freq;
                arp.keyOn();
                quarter => now;
                arp.keyOff();
            }
            
            if(nSteps < minSteps)
                (minSteps-nSteps)::quarter => now;
        }
    }
}


// MarauderArp a => dac;
// 220 => a.freq;
// a.keyOn();
// 0.25::second => now;
// a.keyOff();
// 0.25::second => now;
// 
