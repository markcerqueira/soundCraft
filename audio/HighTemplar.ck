
public class HighTemplarArpeggio extends RhythmArpeggio
{
    Gain master => Pan8 pan;
    4 => pan.gain;
    SndBuf drum[4];
    
    "samples/tabla_09.aiff" => drum[0].read;
    "samples/tabla_10.aiff" => drum[1].read;
    "samples/tabla_01.aiff" => drum[2].read;
    "samples/bells_01.aiff" => drum[3].read;
    1.3 => master.gain;
    
    float pannings[4];
    
    for(int i; i < drum.cap(); i++)
    {
        drum[i] => master;
        drum[i].samples() => drum[i].pos;
    }
    
    fun UGen @ output(int c) { return pan.chan(c); }
    
    fun void hit(int d, float intensity)
    {
        //Math.pow(1.1, Std.rand2f(-1,1)) => drum[d].rate;
        pannings[d] => pan.pan;
        intensity * Std.rand2f(1,.6) => drum[d].gain;
        Std.rand2f(.99,1.01) => drum[d].rate;
        0 => drum[d].pos;
    }
    
    fun void nextRhythm()
    {
        Std.rand2f(0,8) => pannings[0];
        Std.rand2f(0,8) => pannings[1];
        Std.rand2f(0,8) => pannings[2];
        Std.rand2f(0,8) => pannings[3];
    }
    
    [
        [
            [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 ],
            [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 ],
            [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 ],
            [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 ]
        ],
        
        [
            [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 ],
            [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 ],
            [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 ],
            [0.0, 0.0, 0.9, 0.0, 0.0, 0.0, 0.0, 0.0 ]
        ],
        
        [
            [0.6, 0.0, 0.6, 0.0, 0.0, 0.0, 0.0, 0.6 ],
            [0.0, 0.6, 0.0, 0.6, 0.0, 0.0, 0.6, 0.0 ],
            [0.0, 0.0, 0.0, 0.0, 0.8, 0.0, 0.0, 0.0 ],
            [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 ]
        ],
        
        [
            [0.6, 0.0, 0.6, 0.0, 0.0, 0.0, 0.0, 0.0 ],
            [0.0, 0.6, 0.0, 0.6, 0.0, 0.0, 0.0, 0.0 ],
            [0.0, 0.0, 0.0, 0.0, 0.8, 0.0, 0.0, 0.0 ],
            [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.0 ]
        ],
        
        [
            [0.6, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 ],
            [0.0, 0.6, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 ],
            [0.0, 0.0, 0.8, 0.0, 0.8, 0.0, 0.8, 0.0 ],
            [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.7, 0.7 ]
        ],
        
        [
            [0.6, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 ],
            [0.0, 0.6, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 ],
            [0.0, 0.0, 0.8, 0.0, 0.8, 0.0, 0.8, 0.0 ],
            [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.8, 0.0 ]
        ]
        
    ] @=> 
    float rhythm[][][];
    
    fun int numRhythms() { return rhythm.cap(); }
    fun int numDrums() { return rhythm[0].cap(); }
    
    fun float[] getRhythm(int no, int drum)
    {
        return rhythm[no][drum];
    }
    fun dur getQuarterNote() { return 0.125::second; }
    fun int phaseShift() { return 0; }
}
