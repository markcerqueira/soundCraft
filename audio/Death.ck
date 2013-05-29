public class Death extends Chubgraph
{
    SndBuf buffy => outlet;
    
    "samples/__zing-1.aiff" => buffy.read;
    buffy.samples() => buffy.pos;
    
    buffy => Delay d => buffy;
    0.1::second => d.max => d.delay;
    0.5 => d.gain;
    
    spork ~ go();
    
    fun void go()
    {
        while(true)
        {
            20::ms => now;
        }
    }
    
    fun void strike()
    {
        Std.rand2f(.8,1.2) => buffy.gain;
        Std.rand2f(.8,1) => buffy.rate;
        0 => buffy.pos;
    }
    
    fun void strike(dur after)
    {
        after => now;
        Std.rand2f(.8,1.2) => buffy.gain;
        Std.rand2f(.8,1) => buffy.rate;
        0 => buffy.pos;
    }
}
