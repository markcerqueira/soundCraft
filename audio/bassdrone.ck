SinOsc m => SinOsc c => NRev reverb => dac;
2 => c.sync;

50 => c.freq;
c.freq()*0.5 => m.freq;
100 => m.gain;

0.1 => reverb.mix;

1::day => now;
