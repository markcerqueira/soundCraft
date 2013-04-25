
public class ZealotArpeggio extends RhythmArpeggio
{
    Gain master => Pan8 pan;
    4 => pan.gain;
    SndBuf drum[2];
    
    "samples/UN_AFCNG_OPN_01.aif" => drum[0].read;
    "samples/UN_LCNG_HI_OPN_02.aif" => drum[1].read;
    1.5 => master.gain;
    
    float pannings[2];
    
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
        intensity => drum[d].gain;
        0 => drum[d].pos;
    }
    
    fun void nextRhythm()
    {
        Std.rand2f(0,8) => pannings[0];
        Std.rand2f(0,8) => pannings[1];
    }
    
    [
        [
            [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
            [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
        ],
        
        [
            [0.5, 0.0, 0.5, 0.0, 0.0, 0.0, 0.0, 0.0],
            [0.0, 0.0, 0.0, 0.0, 0.5, 0.0, 0.0, 0.0]
        ],
        
        [
            [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.0],
            [0.5, 0.0, 0.5, 0.5, 0.5, 0.0, 0.0, 0.0]
        ],
        
        [
            [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.0],
            [0.5, 0.0, 0.0, 0.0, 0.5, 0.0, 0.0, 0.0]
        ],
        
        [
            [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.0],
            [0.5, 0.0, 0.0, 0.0, 0.5, 0.0, 0.0, 0.0]
        ],
        
        [
            [0.0, 0.0, 0.0, 0.0, 0.7, 0.5, 0.7, 0.5],
            [0.0, 0.0, 0.0, 0.0, 0.5, 0.0, 0.5, 0.0]
        ],
        
        [
            [0.5, 0.0, 0.0, 0.0, 0.5, 0.0, 0.0, 0.0],
            [0.0, 0.0, 0.5, 0.0, 0.0, 0.0, 0.5, 0.0]
        ],
        [
            [0.5, 0.0, 0.0, 0.0, 0.5, 0.0, 0.0, 0.0],
            [0.0, 0.0, 0.5, 0.0, 0.0, 0.0, 0.5, 0.0]
        ],
        
        [
            [0.5, 0.0, 0.5, 0.0, 0.5, 0.0, 0.0, 0.0],
            [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
        ],
        [
            [0.5, 0.0, 0.5, 0.0, 0.5, 0.0, 0.0, 0.0],
            [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
        ]
    ] @=> 
    float rhythm[][][];
    
    fun int numRhythms() { return rhythm.cap(); }
    fun int numDrums() { return rhythm[0].cap(); }
    
    fun float[] getRhythm(int no, int drum)
    {
        return rhythm[no][drum];
    }
    fun dur getQuarterNote() { return 0.25::second; }
    fun int phaseShift() { return 0; }
}
