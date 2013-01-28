SawOsc c => LPF filter => ADSR envelope => NRev reverb => dac;
ADSR filterEnvelope => blackhole;

0.05 => reverb.mix;

envelope.set(10::ms, 20::ms, 0.75, 100::ms);
filterEnvelope.set(50::ms, 100::ms, 0, 100::ms);

220 => c.freq;
c.freq()*8 => filter.freq;
2 => filter.Q;

spork ~ go();

1 => envelope.keyOn;
1 => filterEnvelope.keyOn;
0.25::second => now;

1 => envelope.keyOff;
1 => filterEnvelope.keyOff;

2::second => now;

fun void go()
{
    while(true)
    {
        c.freq()+c.freq()*20*envelope.value() => filter.freq;
        20::ms => now;
    }
}
