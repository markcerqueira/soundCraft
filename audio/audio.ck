
NRev reverb => dac;
0.05 => reverb.mix;
0.1 => reverb.gain;

Death death => reverb;
Arpeggio arpeggio[0];
Plopper plopper => reverb;
BassDrone bassDrone => reverb;

new MarineArpeggio @=> arpeggio["Marine"];
new MarauderArpeggio @=> arpeggio["Marauder"];
new MedivacArpeggio @=> arpeggio["Medivac"];
new ZealotArpeggio @=> arpeggio["Zealot"];
new StalkerArpeggio @=> arpeggio["Sentry"];
new SentryArpeggio @=> arpeggio["Stalker"];
new HighTemplarArpeggio @=> arpeggio["HighTemplar"];
new ArchonArpeggio @=> arpeggio["Archon"];

int nUnits[0];

// create and setup our OSC receiver
OscRecv recv;
6449 => int port;
if(me.args() >= 1) me.arg(0) => Std.atoi => port;
port => recv.port;
<<< "listening on port", port >>>;
recv.listen();

[
"Marine",
"Marauder",
"Zergling",
"Roach",
"Zealot",
"Stalker",
"Archon",
"HighTemplar",
"VoidRay",
"SiegeTank",
"Medivac",
"Carrier",
"Hellion",
"Thor",
"Immortal",
"Colossus",
"Sentry"
] @=> string offensiveUnits[];

for(int i; i < offensiveUnits.cap(); i++)
{
    offensiveUnits[i] => string unit;
    0 => nUnits[unit];
    if(arpeggio[unit] != null)
        arpeggio[unit].output() => reverb;
}


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
            
            //<<< "/lorkCraft/mineralBank.SC2Bank:", key, value >>>;
            
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
            
            //<<< "/lorkCraft/vespeneBank.SC2Bank:", key, value >>>;
            
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
            
            //<<< "/lorkCraft/supplyBank.SC2Bank:", key, value >>>;
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
    for(int i; i < offensiveUnits.cap(); i++)
    {
        if(unit == offensiveUnits[i])
            return true;
    }
    
    return false;
}

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
            
            //<<< "/lorkCraft/unitsBuiltBank.SC2Bank:", key, value >>>;
            
            if(isProduction(key))
            bassDrone.setCompleted(value);
            
            if(isOffensive(key))
            {
                value => nUnits[key];
                if(arpeggio[key] != null)
                    arpeggio[key].setNumber(nUnits[key]);
                //<<< nZergling+nRoach+nMarine+nMarauder+nZealot+nStalker+nSentry >>>;
                //arpeggio.setNumber(nZergling+nRoach+nMarine+nMarauder+nZealot+nStalker+nSentry);
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
            
            //<<< "/lorkCraft/buildingProductionBank.SC2Bank:", key, value >>>;
            
            if(isProduction(key))
            bassDrone.setUnderConstruction(value);
        }
    }
}


fun void listenForResearchCompleted()
{
    recv.event( "/lorkCraft/researchCompletedBank.SC2Bank, s i" ) @=> OscEvent oe;
    
    while ( true )
    {
        oe => now;
        
        while( oe.nextMsg() != 0 )
        { 
            oe.getString() => string key;
            oe.getInt() => int value;
            
            for(int i; i < offensiveUnits.cap(); i++)
            {
                if(arpeggio[offensiveUnits[i]] != null)
                    arpeggio[offensiveUnits[i]].setTechLevel(value);
            }
            bassDrone.setTechLevel(value);
        }
    }
}

fun void listenForUnitsAndStructuresLost()
{
    recv.event( "/lorkCraft/scoreBank.SC2Bank, s i" ) @=> OscEvent oe;
    int totalLost;
    
    while ( true )
    {
        oe => now;
        
        while( oe.nextMsg() != 0 )
        { 
            oe.getString() => string key;
            oe.getInt() => int value;
            
            //<<< "/lorkCraft/scoreBank.SC2Bank:", key, value >>>;
            
            if(key == "units_lost" && value > totalLost)
            {
                //<<< "STRIKE!", "" >>>;
                value => totalLost;
                death.strike();
            }
        }
    }
}

spork ~ listenForMineralChanges();
spork ~ listenForVespeneChanges();
spork ~ listenForSupplyChanges();
spork ~ listenForUnitsBuilt();
spork ~ listenForBuildingConstruction();
spork ~ listenForResearchCompleted();
spork ~ listenForUnitsAndStructuresLost();

10::day => now;

