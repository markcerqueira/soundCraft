
class Plopper
{
    NRev reverb => dac;
    0.1 => reverb.mix;
    0.1 => reverb.gain;
    
    fun void plop()
    {
        SinOsc mod => TriOsc s => ADSR env => reverb;
        
        [36, 34, 39, 41] @=> int notes[];
        
        notes[Std.rand2(0,notes.cap()-1)] => Std.mtof => s.freq;
        s.freq()*3.5 => mod.freq;
        300 => mod.gain;
        env.set(10::ms, 20::ms, 0.5, 400::ms);
        
        1 => env.keyOn;
        100::ms => now;
        
        1 => env.keyOff;
        
        2::second => now;
    }
    
    fun void plopPlus()
    {
        SinOsc mod => TriOsc s => ADSR env => reverb;
        
        [36, 34, 39, 41] @=> int notes[];
        
        notes[Std.rand2(0,notes.cap()-1)] + 24 => Std.mtof => s.freq;
        s.freq()*3.5 => mod.freq;
        300 => mod.gain;
        env.set(10::ms, 20::ms, 0.5, 400::ms);
        
        1 => env.keyOn;
        100::ms => now;
        
        1 => env.keyOff;
        
        2::second => now;
    }
}

class BassDrone
{
    SinOsc m => SinOsc c => NRev reverb => dac;
    2 => c.sync;
    0.1 => c.gain;
    
    50 => c.freq;
    c.freq()*0.5 => m.freq;
    100 => m.gain;
    
    0.1 => reverb.mix;
    
    c.freq() => float freq_target;
    
    0 => int numConstruction;
    0 => int numCompleted;
    
    spork ~ go();
    
    fun void setUnderConstruction(int n)
    {
        n => numConstruction;
        50*Math.pow(1.1,numConstruction+numCompleted) => freq_target;
    }
    
    fun void setCompleted(int n)
    {
        n => numCompleted;
        50*Math.pow(1.1,numConstruction+numCompleted) => freq_target;
    }
    
    fun void go()
    {
        while(true)
        {
            c.freq() + (freq_target-c.freq())*0.25 => c.freq;
            c.freq()*0.5 => m.freq;
            20::ms => now;
        }
    }
}

class Arp extends Chubgraph
{
    SawOsc c => LPF filter => ADSR envelope => outlet;
    ADSR filterEnvelope => blackhole;
    
    envelope.set(20::ms, 20::ms, 1, 100::ms);
    filterEnvelope.set(50::ms, 100::ms, 0.5, 100::ms);
    
    0 => envelope.value;
    0 => filterEnvelope.value;
    
    220 => c.freq;
    c.freq()*8 => filter.freq;
    2 => filter.Q;
    
    spork ~ go();
    
    fun void go()
    {
        while(true)
        {
            c.freq()+c.freq()*20*filterEnvelope.value() => filter.freq;
            20::ms => now;
        }
    }
    
    fun float freq(float f)
    {
        f => c.freq;
        return f;
    }
    
    fun void keyOn()
    {
        1 => envelope.keyOn;
        1 => filterEnvelope.keyOn;
    }
    
    fun void keyOff()
    {
        1 => envelope.keyOff;
        1 => filterEnvelope.keyOff;
    }
}

class ArpPoly extends Poly
{
    fun UGen create()
    {
        Arp a;
        0.1 => a.gain;
        return a;
    }
}

class Arpeggio
{
    ArpPoly poly => NRev reverb => dac;
    0.05 => reverb.mix;
    1 => poly.gain;
    
    poly.setNumVoices(12);
    
    [36, 34, 39, 41] @=> int notes[];
    3 => int nOctave;
    
    int nSteps;
    
    fun void setNumber(int n)
    {
        n => nSteps;
    }
    
    spork ~ go();
    
    fun void go()
    {
        0.125::second => dur quarter;
        
        while(true)
        {
            int noteIndex;
            1 => int noteInc;
            
            for(int i; i < nSteps; i++)
            {
                (poly.get() $ Arp) @=> Arp @ arp;
                
                noteIndex/notes.cap() => int octave;
                if(octave > 4)
                {
                    1 +=> noteInc;
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
                arp.keyOff();
            }
            
            if(nSteps < 4)
                (4-nSteps)::quarter => now;
        }
    }
}

Arpeggio arpeggio;
Plopper plopper;
BassDrone bassDrone;


// create and setup our OSC receiver
OscRecv recv;
6449 => recv.port;
recv.listen();

fun void listenForMineralChanges()
{    
    recv.event( "/lorkCraft/mineralBank.SC2Bank, s i" ) @=> OscEvent oe;
    
    while ( true )
    {
        oe => now;
        
        while ( oe.nextMsg() != 0 )
        { 
            oe.getString() => string key;
            oe.getInt() => int value;
            
            <<< "/lorkCraft/mineralBank.SC2Bank:", key, value >>>;
            
            spork ~ plopper.plop();
        }
    }
}

fun void listenForVespeneChanges()
{
    recv.event( "/lorkCraft/vespeneBank.SC2Bank, s i" ) @=> OscEvent oe;
    
    while ( true )
    {
        oe => now;
        
        while ( oe.nextMsg() != 0 )
        { 
            oe.getString() => string key;
            Std.atoi( oe.getString() ) => int value;
            
            <<< "/lorkCraft/vespeneBank.SC2Bank:", key, value >>>;
            
            spork ~ plopper.plopPlus();
        }
    }
}

fun void listenForSupplyChanges()
{
    recv.event( "/lorkCraft/supplyBank.SC2Bank, s s" ) @=> OscEvent oe;
    
    while ( true )
    {
        oe => now;
        
        while ( oe.nextMsg() != 0 )
        { 
            oe.getString() => string key;
            Std.atoi( oe.getString() ) => int value;
            
            <<< "/lorkCraft/supplyBank.SC2Bank:", key, value >>>;
        }
    }
}

fun int isProduction(string unit)
{
    return unit == "Hatchery" ||
    unit == "Gateway" ||
    unit == "Stargate" ||
    unit == "Robotics Facility" ||
    unit == "Factory" ||
    unit == "Starport" ||
    unit == "Barracks";
}

fun int isOffensive(string unit)
{
    return unit == "Marine" ||
    unit == "Marauder" ||
    unit == "Zergling" ||
    unit == "Roach" ||
    unit == "Zealot" ||
    unit == "Stalker" ||
    unit == "Sentry";
}

int nZergling;
int nRoach;
int nMarine;
int nMarauder;
int nZealot;
int nStalker;
int nSentry;

fun void listenForUnitsBuilt()
{
    recv.event( "/lorkCraft/unitsBuiltBank.SC2Bank, s i" ) @=> OscEvent oe;
    
    while ( true )
    {
        oe => now;
        
        while ( oe.nextMsg() != 0 )
        { 
            oe.getString() => string key;
            oe.getInt() => int value;
            
            <<< "/lorkCraft/unitsBuiltBank.SC2Bank:", key, value >>>;
            
            if(isProduction(key))
                bassDrone.setCompleted(value);
            
            if(isOffensive(key))
            {
                if(key == "Zergling")
                    value => nZergling;
                if(key == "Roach")
                    value => nRoach;
                if(key == "Marine")
                    value => nMarine;
                if(key == "Marauder")
                    value => nMarauder;
                if(key == "Zealot")
                    value => nZealot;
                if(key == "Stalker")
                    value => nStalker;
                if(key == "Sentry")
                    value => nSentry;
                <<< nZergling+nRoach+nMarine+nMarauder+nZealot+nStalker+nSentry >>>;
                arpeggio.setNumber(nZergling+nRoach+nMarine+nMarauder+nZealot+nStalker+nSentry);
            }
        }
    }
}

fun void listenForBuildingConstruction()
{
    recv.event( "/lorkCraft/buildingProductionBank.SC2Bank, s i" ) @=> OscEvent oe;
    
    while ( true )
    {
        oe => now;
        
        while ( oe.nextMsg() != 0 )
        { 
            oe.getString() => string key;
            oe.getInt() => int value;
            
            <<< "/lorkCraft/buildingProductionBank.SC2Bank:", key, value >>>;
            
            if(isProduction(key))
                bassDrone.setUnderConstruction(value);
        }
    }
}

spork ~ listenForMineralChanges();
spork ~ listenForVespeneChanges();
spork ~ listenForSupplyChanges();
spork ~ listenForUnitsBuilt();
spork ~ listenForBuildingConstruction();

10::day => now;

