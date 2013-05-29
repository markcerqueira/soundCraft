
public class Arp extends Chubgraph
{
	/* overrides */
    fun float freq(float f) { return f; }
    fun void keyOn() { }
    fun void keyOff() { }
    fun dur length() { return 0::second; }
	
	fun void set(int techLevel, int stepNo) { }
	fun void setQuantity(int qty) { }
    
    
    /* internal */
    
    fun void keyOff(dur at)
    {
        at => now;
        keyOff();
    }
}

