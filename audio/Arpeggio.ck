
public class Arpeggio
{
    /* overrides for different unit types */
    fun UGen @ output() { return null; }
    fun UGen @ output(int c) { return output(); }
    fun void set(int techLevel, int stepNo) { }
    
    /* overrides for different supertypes (rhythm, melody) */
    fun void setNumber(int n) { }    
    fun void setTechLevel(int n) { }
}

