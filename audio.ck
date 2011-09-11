// create and setup our OSC receiver
OscRecv recv;
6449 => recv.port;
recv.listen();

// set up our audios
SinOsc s => JCRev r => dac;

fun void listenForMineralChanges()
{    
    recv.event( "/lorkCraft/mineralBank.SC2Bank, s s" ) @=> OscEvent oe;
    
    while ( true )
    {
        oe => now;
        
        while ( oe.nextMsg() != 0 )
        { 
            oe.getString() => string key;
            Std.atoi( oe.getString() ) => int value;
            
            <<< "got (via OSC):", key, " ", value >>>;
            
            if ( key == "current_mineral_count" )
                value => s.freq;
        }
    }
}

fun void listenForVespeneChanges()
{
    recv.event( "/lorkCraft/vespeneBank.SC2Bank, s s" ) @=> OscEvent oe;
    
    while ( true )
    {
        oe => now;
        
        while ( oe.nextMsg() != 0 )
        { 
            oe.getString() => string key;
            Std.atoi( oe.getString() ) => int value;
            
            <<< "got (via OSC):", key, " ", value >>>;
            
            if ( key == "current_vespene_count" )
                value / 1000 => r.mix;
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
            
            <<< "got (via OSC):", key, " ", value >>>;
        }
    }
}

spork ~ listenForMineralChanges();
spork ~ listenForVespeneChanges();
spork ~ listenForSupplyChanges();

10::day => now;

