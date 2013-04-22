

Death death;
MarineArpeggio marine;
MarauderArpeggio marauder;
Plopper plopper;
BassDrone bassDrone;


// create and setup our OSC receiver
OscRecv recv;
6449 => int port;
if(me.args() >= 1)
    me.arg(0) => Std.atoi => port;
port => recv.port;
<<< "listening on port", port >>>;
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
 "Carrier",
 "Hellion",
 "Thor",
 "Immortal",
 "Colossus",
 "Sentry"
] @=> string offensiveUnits[];

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
            
            //<<< "/lorkCraft/unitsBuiltBank.SC2Bank:", key, value >>>;
            
            if(isProduction(key))
                bassDrone.setCompleted(value);
            
            if(isOffensive(key))
            {
                if(key == "Zergling")
				{
                    value => nZergling;
				}
  				else if(key == "Roach")
				{
                    value => nRoach;
				}
                if(key == "Marine")
				{
                    value => nMarine;
					marine.setNumber(nMarine);
				}
                if(key == "Marauder")
				{
                    value => nMarauder;
					marauder.setNumber(nMarauder);
				}
                if(key == "Zealot")
				{
                    value => nZealot;
				}
                if(key == "Stalker")
				{
                    value => nStalker;
				}
                if(key == "Sentry")
				{
                    value => nSentry;
				}
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
            
            marine.setTechLevel(value);
            marauder.setTechLevel(value);
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

