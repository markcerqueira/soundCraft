
public class StalkerArpeggio extends RhythmArpeggio
{
    Gain master;
    SndBuf drum[2];
    
    "samples/TMD EH SNAP 1.aif" => drum[0].read;
    "samples/DAT-MinimalElectro_Snr.aif" => drum[1].read;
    0.5 => drum[1].gain;
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
            [0.0, 0.0, 0.0, 0.0, 0.0, 0.7, 0.7, 0.7 ],
            [0.0, 0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 ]
        ],
        
        
        [
            [0.0, 0.0, 0.0, 0.0, 0.0, 0.7, 0.7, 0.7 ],
            [0.0, 0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 ]
        ],
        
        [
            [0.0, 0.0, 0.0, 0.0, 0.0, 0.7, 0.7, 0.7 ],
            [0.0, 0.5, 0.0, 0.5, 0.0, 0.0, 0.0, 0.0 ]
        ],
        
        [
            [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.8 ],
            [0.0, 0.0, 0.7, 0.0, 0.7, 0.0, 0.7, 0.0 ]
        ],
        
        [
            [0.7, 0.0, 0.0, 0.7, 0.0, 0.0, 0.7, 0.0 ],
            [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.9 ]
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
