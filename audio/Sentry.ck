
public class SentryArpeggio extends RhythmArpeggio
{
    Gain master;
    SndBuf drum[2];
    
    // pandeiro
    "samples/UN_PAND1_OPN_02.aif" => drum[0].read;
    // repinique
    "samples/UN_RDM_HI_EDG_01.aif" => drum[1].read;
    1.5 => master.gain;
    
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
            [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 ]
        ],
        [
            [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 ],
            [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 ]
        ],
        
        [
            [0.2, 0.0, 0.2, 0.0, 0.2, 0.0, 2.0, 0.0 ],
            [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 ]
        ],

        [
            [0.7, 0.5, 0.5, 0.3, 0.0, 0.0, 0.0, 0.0 ],
            [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.9, 0.0 ]
        ],
        [
            [0.7, 0.5, 0.5, 0.3, 0.0, 0.0, 0.0, 0.0 ],
            [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.9, 0.0 ]
        ],
        
        [
            [0.0, 0.0, 0.0, 0.3, 0.0, 0.0, 0.0, 0.3 ],
            [0.0, 0.0, 0.9, 0.0, 0.0, 0.0, 0.9, 0.0 ]
        ],
        [
            [0.0, 0.0, 0.0, 0.3, 0.0, 0.0, 0.0, 0.3 ],
            [0.0, 0.0, 0.9, 0.0, 0.0, 0.0, 0.9, 0.0 ]
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
