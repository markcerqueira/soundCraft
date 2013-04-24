
public class ArchonArpeggio extends RhythmArpeggio
{
    Gain master;
    SndBuf drum[2];
    
    "samples/DAT-MinimalElectro_boomkik.aif" => drum[0].read;
    "samples/IL02-CHI_TT_HI_OPN_02.aif" => drum[1].read;
    2 => drum[0].gain;
    1.1 => master.gain;
    
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
        [
            [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 ],
            [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 ]
        ],
        
        [
            [0.7, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 ],
            [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 ]
        ],
        
        [
            [0.0, 0.0, 0.0, 0.0, 0.7, 0.0, 0.0, 0.0 ],
            [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 ]
        ],
        
        [
            [0.7, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 ],
            [0.0, 0.0, 0.5, 0.5, 0.0, 0.0, 0.0, 0.0 ]
        ],
        
        [
            [0.7, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 ],
            [0.0, 0.0, 0.5, 0.5, 0.5, 0.0, 0.5, 0.0 ]
        ],
        
        [
            [0.7, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 ],
            [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 ]
        ],
        
        [
            [1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 ],
            [0.0, 0.0, 0.8, 0.8, 0.0, 0.0, 0.0, 0.0 ]
        ],
        
        [
            [0.7, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 ],
            [0.0, 0.0, 0.8, 0.8, 0.8, 0.0, 0.8, 0.0 ]
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
