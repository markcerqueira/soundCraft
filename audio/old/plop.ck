
SinOsc mod => TriOsc s => ADSR env => NRev reverb => dac;
//2 => s.sync;

0.1 => reverb.mix;

[36, 39, 34, 41] @=> int notes[];

notes[Std.rand2(0,notes.cap()-1)] => Std.mtof => s.freq;
s.freq()*3.5 => mod.freq;
200 => mod.gain;
env.set(10::ms, 20::ms, 0.5, 400::ms);

0.1 => reverb.gain;

1 => env.keyOn;
100::ms => now;

1 => env.keyOff;

5::second => now;
