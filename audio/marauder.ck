
class MarauderArp extends Arp
{
    SqrOsc m => SinOsc c => LPF filter => ADSR envelope => outlet;
    m => SinOsc c2 => filter;
    ADSR filterEnvelope => blackhole;
    2 => c.sync;
    600 => m.gain;
    
    // added: ge
    Vector3D iMod;
    iMod.set( 600,600,.1 );
    // interp rate
    5::ms => dur INTERP_RATE;
    spork ~ iMod.interp( INTERP_RATE );
    spork ~ apply( INTERP_RATE );
    
    // added: ge
    SinOsc lfo => Gain add => outlet;
    // step
    Step step => add;
    // set gain
    .5 => add.gain;
    // set setp
    1.2 => step.next;
    // set to multiply
    3 => outlet.op;
    // set LFO freq
    .05 + Std.rand2f(0,.05) => lfo.freq;
    
    
    envelope.set(20::ms, 10::ms, 0.4, 100::ms);
    1 => envelope.keyOff;
    filterEnvelope.set(150::ms, 150::ms, 0.5, 100::ms);
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
    
    // applying the value
    fun void apply( dur T )
    {
        while( true )
        {
            // apply
            iMod.value() => m.gain;
            // advance time
            T => now;
        }
    }
    
    fun float freq(float f)
    {
        f => c.freq;
        f/4 => c2.freq;
        f*0.25 => m.freq;
        return f;
    }
    
    fun void keyOn()
    {
        1 => iMod.value;
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
        0.05 => a.gain;
        return a;
    }
}

public class MarauderArpeggio extends MelodyArpeggio
{
    ArpPoly poly => Pan8 pan;
    6 => poly.gain;
    
    poly.setNumVoices(3);
    
    int count;
    
    fun UGen @ output(int c) { return pan.chan(c); }
    fun Arp @ getArp() { return (poly.get() $ Arp); }
    fun int[] getNotes() { return [39, 41, 36, 34]; }
    fun int getOctaves() { return 4; }
    fun dur getQuarterNote() { return 1::second; }
    fun int getMinSteps() { return 2; }
    fun int phaseShift() { return 0; }
    
    fun void set(int techLevel, int stepNo)
    {
        0.5+count*2.25 => pan.pan;
        count--;
    }
}

