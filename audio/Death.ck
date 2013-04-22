public class Death
{
    SinOsc m => SawOsc c => HPF hi => HPF lo => HPF mid => Gain direct => Gain amp => NRev reverb => dac;
    
    Impulse energy => OnePole op => amp;
    3 => amp.op;
    0.99995 => op.pole;
    
    2 => c.sync;
    
    direct => Delay d => direct;
    0.1::second => d.max => d.delay;
    0.95 => d.gain;
    
    0.1 => reverb.mix;
    
    SinOsc lfo1 => blackhole;
    4 => lfo1.freq;
    SinOsc lfo2 => blackhole;
    0.8 => lfo2.freq;
    SinOsc lfo3 => blackhole;
    0.2 => lfo3.freq;
    
    2000 => c.freq;
    c.freq()*4.1 => m.freq;
    2000 => m.gain;
    
    1.1 => hi.Q;
    1.1 => lo.Q;
    1.1 => mid.Q;
    
    spork ~ go();
    
    fun void go()
    {
        while(true)
        {
            c.freq()*Math.pow(2,lfo1.last()) => hi.freq;
            c.freq()*Math.pow(1.5,lfo2.last()) => lo.freq;
            c.freq()*Math.pow(3,lfo3.last()) => mid.freq;
            20::ms => now;
        }
    }
    
    fun void strike()
    {
        5000 => energy.next;
    }
}
