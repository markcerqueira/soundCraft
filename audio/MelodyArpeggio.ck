
public class MelodyArpeggio extends Arpeggio
{
	/* overrides */
	
	fun Arp @ getArp() { return null; }
	fun int[] getNotes() { return null; }
	fun int getOctaves() { return 1; }
    fun dur getQuarterNote() { return 0.125::second; }
    fun int getMinSteps() { return 8; }
    fun int phaseShift() { return 0; }
	
	/* internal */
	
    getNotes() @=> int notes[];
    getOctaves() => int nOctave;
    
    int nSteps;
    getMinSteps() => int minSteps;
    
    0 => int techLevel;
    
    fun void setNumber(int n)
    {
        n => nSteps;
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
            int noteIndex;
            1 => int noteInc;
            
            for(int i; i < nSteps; i++)
            {
                getArp() @=> Arp @ arp;
                arp.set(techLevel, i);
                this.set(techLevel, i);
                
                noteIndex/notes.cap() => int octave;
                if(octave > 4)
                {
                    1 +=> noteInc;
                    -noteInc => noteInc;
                    4 => octave;
                }
                
                notes[noteIndex%notes.cap()] + octave*12 + 12 => int note;
                //<<< "arp note:", note >>>;
                if(i == nSteps/2)
                    -noteInc => noteInc;
                noteInc +=> noteIndex;
                if(noteIndex < 0)
                {
                    0 => noteIndex;
                    -noteInc => noteInc;
                }
                
                note => Std.mtof => arp.freq;
                
                arp.keyOn();
                quarter => now;
                if(arp.length() < quarter)
                    arp.keyOff();
                else
                    spork ~ arp.keyOff(arp.length()-quarter);
            }
            
            if(nSteps < minSteps)
                (minSteps-nSteps)::quarter => now;
        }
    }
}

