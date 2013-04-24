
public class RhythmArpeggio extends Arpeggio
{
    /* overrides */
	
    fun void hit(int drum, float intensity) { }
    fun int numRhythms() { return 0; }
    fun int numDrums() { return 0; }
    fun float[] getRhythm(int no, int drum) { return null; }
    fun dur getQuarterNote() { return 0.125::second; }
    fun int phaseShift() { return 0; }
	
    
    /* internal */
    
    0 => int number;
    0 => int techLevel;
    
    fun void setNumber(int n)
    {
        n => number;
    }
    
    fun void setTechLevel(int n)
    {
        n => techLevel;
    }
    
    spork ~ go();
    
    fun void go()
    {
        getQuarterNote() => dur quarter;
        phaseShift()::quarter => now;
        
        while(true)
        {
            Std.rand2f(0,Std2.clamp(Math.ceil(Math.log2(number)/Math.log2(1.5)),0,numRhythms()-1)) $int => int r;
            
            getRhythm(r, 0).cap() => int nSteps;
            
            for(int i; i < nSteps; i++)
            {
                for(int d; d < numDrums(); d++)
                {
                    getRhythm(r, d)[i] => float P;
                    if(P > 0)
                    {
                        Math.pow(P, 1.0/(techLevel*2+1)) => P;
                        hit(d, Std2.clamp(Std.rand2f(P-0.5,P), 0, 1));
                    }
                }
                
                quarter => now;
            }
        }
    }
}