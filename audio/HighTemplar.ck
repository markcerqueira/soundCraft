
public class HighTemplarArpeggio extends RhythmArpeggio
{
    Gain master;
    SndBuf drum[4];
    
    "samples/tabla_09.aiff" => drum[0].read;
    "samples/tabla_10.aiff" => drum[1].read;
    "samples/tabla_01.aiff" => drum[2].read;
    "samples/bells_01.aiff" => drum[3].read;
    1.3 => master.gain;
    
    for(int i; i < drum.cap(); i++)
    {
        drum[i] => master;
        drum[i].samples() => drum[i].pos;
    }
    
    fun UGen @ output() { return master; }
    
    fun void hit(int d, float intensity)
    {
        //Math.pow(1.1, Std.rand2f(-1,1)) => drum[d].rate;
        intensity => drum[d].gain;
        0 => drum[d].pos;
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
