class Arp extends Chubgraph
{
    SawOsc c => LPF filter => ADSR envelope => outlet;
    ADSR filterEnvelope => blackhole;
    
    envelope.set(20::ms, 20::ms, 1, 100::ms);
    filterEnvelope.set(50::ms, 100::ms, 0.5, 100::ms);
    
    0 => envelope.value;
    0 => filterEnvelope.value;
    
    220 => c.freq;
    c.freq()*8 => filter.freq;
    2 => filter.Q;
    
    spork ~ go();
    
    fun void go()
    {
        while(true)
        {
            c.freq()+c.freq()*20*filterEnvelope.value() => filter.freq;
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

class ArpPoly extends Poly
{
    fun UGen create()
    {
        Arp a;
        0.1 => a.gain;
        return a;
    }
}

class Arpeggio
{
    ArpPoly poly => NRev reverb => dac;
    0.05 => reverb.mix;
    1 => poly.gain;
    
    poly.setNumVoices(12);
    
    [36, 34, 39, 41] @=> int notes[];
    3 => int nOctave;
    
    int nSteps;
    
    fun void setNumber(int n)
    {
        n => nSteps;
    }
    
    spork ~ go();
    
    fun void go()
    {
        0.125::second => dur quarter;
        
        while(true)
        {
            int noteIndex;
            
            for(int i; i < nSteps; i++)
            {
                (poly.get() $ Arp) @=> Arp @ arp;
                
                notes[noteIndex%notes.cap()] + noteIndex/notes.cap()*12 + 12 => int note;
                <<< "arp note:", note >>>;
                if(i < nSteps/2)
                    noteIndex++;
                else
                    noteIndex--;
                
                note => Std.mtof => arp.freq;
                arp.keyOn();
                quarter => now;
                arp.keyOff();
            }
            
            if(nSteps < 4)
                (4-nSteps)::quarter => now;
        }
    }
}

Arpeggio arpeggio;

arpeggio.setNumber(13);

1::day => now;
