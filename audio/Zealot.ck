
public class ZealotArpeggio extends RhythmArpeggio
{
    Gain master;
    SndBuf drum[2];
    
    "samples/UN_AFCNG_OPN_01.aif" => drum[0].read;
    "samples/UN_LCNG_HI_OPN_02.aif" => drum[1].read;
    
    for(int i; i < drum.cap(); i++)
    {
        drum[i] => master;
        drum[i].samples() => drum[i].pos;
    }
    
    fun UGen @ output() { return master; }
    
    fun void hit(int d, float intensity)
    {
        intensity => drum[d].gain;
        0 => drum[d].pos;
    }
    
    [
        [[0.0, 0.0, 0.0, 0.0], [0.0, 0.0, 0.0, 0.0]],
        [[0.5, 0.5, 0.0, 0.0], [0.0, 0.0, 0.5, 0.0]],
        [[0.5, 0.5, 0.0, 0.0], [0.0, 0.0, 0.5, 0.0]],
        [[0.0, 0.0, 0.0, 0.5], [0.5, 0.0, 0.5, 0.0]],
        [[0.0, 0.0, 0.0, 0.5], [0.5, 0.0, 0.5, 0.0]],
        [[0.5, 0.0, 0.5, 0.0], [0.0, 0.5, 0.0, 0.5]],
        [[0.5, 0.5, 0.5, 0.0], [0.0, 0.0, 0.0, 0.0]]
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
