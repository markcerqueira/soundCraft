
public class SentryArpeggio extends RhythmArpeggio
{
    Gain master => Pan8 pan;
    4 => pan.gain;
    // SndBuf drum[2];
    Impulse imp[2];
    LPF lpf[2];

    
    // pandeiro
    //"samples/UN_PAND1_OPN_02.aif" => drum[0].read;
    // repinique
    //"samples/UN_RDM_HI_EDG_01.aif" => drum[1].read;
    3 => master.gain;
    500 => lpf[0].freq;
    1000 => lpf[1].freq;
        
    float pannings[2];
    
    // for(int i; i < drum.cap(); i++)
    // {
    //    drum[i] => master;
    //    drum[i].samples() => drum[i].pos;
    // }
    
    for( int i; i < imp.cap(); i++ )
    {
        imp[i] => lpf[i] => master;
    }
    
    fun UGen @ output(int c) { return pan.chan(c); }
    
    fun void hit(int d, float intensity)
    {
        //Math.pow(1.1, Std.rand2f(-1,1)) => drum[d].rate;
        pannings[d] => pan.pan;
        intensity => imp[d].next;
        // intensity => drum[d].gain;
        // 0 => drum[d].pos;
    }
    
    fun void nextRhythm()
    {
        Std.rand2f(0,8) => pannings[0];
        Std.rand2f(0,8) => pannings[1];
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
