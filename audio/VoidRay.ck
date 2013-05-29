
class VRVoice extends Chubgraph
{
    TriOsc m2 => SqrOsc m => SawOsc c => LPF filter => outlet;
    m => m2;
    c => HPF sweeper => outlet;
    0.05 => sweeper.gain;
    
    .25 => filter.gain;

    SawOsc modm => SinOsc modc => blackhole;
    Std.rand2f(0,1) => modc.phase;
    0.05 => modc.freq;
    2 => modc.sync;
    0.1 => modm.gain;
    0.8 => modm.freq;

    SawOsc modm2 => SinOsc modc2 => blackhole;
    Std.rand2f(0,1) => modc2.phase;
    0.2 => modc2.freq;
    2 => modc2.sync;
    0.5 => modm2.gain;
    0.9 => modm2.freq;
    
    27 => float note;
    note => Std.mtof => c.freq;
    2 => c.sync;
    c.freq() * 2 => m.freq;
    500 => m.gain;
    2 => m.sync;
    c.freq() * 0.49 => m2.freq;
    10 => m2.gain;

    c.freq()*5 => filter.freq;
    2 => filter.Q;

    2 => sweeper.Q;

    Math.pow(2,1.0/12.0) => float semitoneRatio;

    Vector3D iFreq;
    iFreq.set( Std.mtof(12), Std.mtof(36), 4 );
    spork ~ iFreq.interp( 5::ms );
    spork ~ apply( 5::ms );
    
    fun float apply( dur T )
    {
        while( true )
        {
            iFreq.value() => c.freq;
            iFreq.value() * 5 => filter.freq;
            iFreq.value() * 2 => m.freq;
            iFreq.value() * .49 => m2.freq;
            T => now;
        }
    }

    spork ~ go();
    
    fun float freq(float f)
    {
        f => iFreq.goal;
        // f => c.freq;
        // c.freq()*5 => filter.freq;
        // c.freq() * 2 => m.freq;
        // c.freq() * 0.49 => m2.freq;
        return f;
    }
    
    fun void go()
    {
        while(true)
        {
            1000*Math.pow(3,modc2.last()) => sweeper.freq;
    
            //c.freq()+2000*(2+modc.last()) => filter.freq;
            Math.pow(2,modc.last())*500 => m.gain;
    
            10*Math.pow(2, 1+modc2.last()) => m2.gain;
    
            20::ms => now;
        }
    }
}

class VoidRayArp extends Arp
{
    VRVoice top => Envelope envelope => outlet;
    VRVoice bottom => envelope;
    
    1 => envelope.keyOff;
    
    fun float freq(float f)
    {
        f => top.freq;
        f/2  => bottom.freq;
        return f;
    }
    
    fun void keyOn()
    {
        1 => envelope.keyOn;
    }
    
    fun void keyOff()
    {
        1 => envelope.keyOff;
    }
    
    fun void set(int techLevel, int stepNo)
    {
    }
    
    fun dur length() { return 1::second; }
}


class ArpPoly extends Poly
{
    fun UGen create()
    {
        VoidRayArp a;
        0.5 => a.gain;
        return a;
    }
}

public class VoidRayArpeggio extends MelodyArpeggio
{
    ArpPoly poly => Pan8 pan;
    6 => poly.gain;

    poly.setNumVoices(2);
    
    Lerp panVal;
    
    0 => int thecount;
    
    spork ~ go2();
    
    fun UGen @ output(int c) { return pan.chan(c); }
    
    fun Arp @ getArp() { return (poly.get() $ Arp); }
    fun int[] getNotes() { return [33, 29, 36, 27]; }
    fun int getOctaves() { return 1; }
    fun dur getQuarterNote() { return 8::second; }
    fun int getMinSteps() { return 1; }
    fun int phaseShift() { return 0; }
    
    fun int stepStart() { return techLevel*2; }
    
    fun void set(int techLevel, int stepNo)
    {
        if(stepNo%2 == 0)
            Std.rand2(0,8) => panVal.target;
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


