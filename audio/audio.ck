
8 => int NUM_CHANNELS;
dac.channels() => int numOut;

NRev reverb[NUM_CHANNELS];
NukeFilter nuke;

Death death;
Arpeggio arpeggio[0];
Plopper plopper;
BassDrone bassDrone[2];

for(int i; i < NUM_CHANNELS; i++)
{
    reverb[i] => nuke.input(i);
    nuke.output(i) => dac.chan(i%numOut);
    death => reverb[i];
    plopper => reverb[i];
    bassDrone[0] => reverb[i];
    bassDrone[1] => reverb[i];
    
    0.05 => reverb[i].mix;
    0.1 => reverb[i].gain;
}

new MarineArpeggio @=> arpeggio["Marine"];
new MarauderArpeggio @=> arpeggio["Marauder"];
new MedivacArpeggio @=> arpeggio["Medivac"];
new ZealotArpeggio @=> arpeggio["Zealot"];
new StalkerArpeggio @=> arpeggio["Sentry"];
new SentryArpeggio @=> arpeggio["Stalker"];
new HighTemplarArpeggio @=> arpeggio["HighTemplar"];
new ArchonArpeggio @=> arpeggio["Archon"];
new GhostArpeggio @=> arpeggio["Ghost"];
new VoidRayArpeggio @=> arpeggio["VoidRay"];

int nUnits[0];

// create and setup our OSC receiver
OscRecv player[2];

6449 => int port1;
if(me.args() >= 1) me.arg(0) => Std.atoi => port1;
port1 => player[0].port;
<<< "listening for player 1 on port", port1 >>>;
player[0].listen();

// create and setup our OSC receiver
6450 => int port2;
if(me.args() >= 2) me.arg(1) => Std.atoi => port2;
port2 => player[1].port;
<<< "listening for player 2 on port", port2 >>>;
player[1].listen();

string offensiveUnits[0];

[
 [ "Marine", "Marauder", "SiegeTank", "Medivac", "Hellion", "Thor", "Ghost", "Battlecruiser", "VikingFighter", "Banshee" ],
 [ "Zealot", "Stalker", "Archon", "HighTemplar", "VoidRay", "Carrier", "Immortal", "Colossus", "Sentry", "Tempest", "Oracle", "Phoenix" ]
] @=> string playerUnits[][];

for(int i; i < playerUnits.cap(); i++)
{
    for(int j; j < playerUnits[i].cap(); j++)
    {
        offensiveUnits << playerUnits[i][j];
    }
}

for(int i; i < offensiveUnits.cap(); i++)
{
    offensiveUnits[i] => string unit;
    0 => nUnits[unit];
    
    if(arpeggio[unit] != null)
    {
        for(int j; j < NUM_CHANNELS; j++)
        {
            arpeggio[unit].output(j) => reverb[j];
        }
    }
}

0 => int numNukes;

fun void listenForMineralChanges(int p)
{    
    player[p].event( "/lorkCraft/mineralBank.SC2Bank, si" ) @=> OscEvent oe;
    
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

fun void listenForVespeneChanges(int p)
{
    player[p].event( "/lorkCraft/vespeneBank.SC2Bank, si" ) @=> OscEvent oe;
    
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

fun void listenForSupplyChanges(int p)
{
    player[p].event( "/lorkCraft/supplyBank.SC2Bank, ss" ) @=> OscEvent oe;
    
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

fun int isOffensive(string unit)
{
    for(int i; i < offensiveUnits.cap(); i++)
    {
        if(unit == offensiveUnits[i])
            return true;
    }
    
    return false;
}

fun void listenForUnitsBuilt(int p)
{
    player[p].event( "/lorkCraft/unitsBuiltBank.SC2Bank, si" ) @=> OscEvent oe;
    
    while ( true )
    {
        oe => now;
        
        while ( oe.nextMsg() != 0 )
        { 
            oe.getString() => string key;
            oe.getInt() => int value;
            
            //<<< "/lorkCraft/unitsBuiltBank.SC2Bank:", key, value >>>;
            
            if(isProduction(key))
                bassDrone[p].setCompleted(value);
            
            if(isOffensive(key))
            {
                value => nUnits[key];
                if(arpeggio[key] != null)
                    arpeggio[key].setNumber(nUnits[key]);
            }
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

fun void listenForBuildingConstruction(int p)
{
    player[p].event( "/lorkCraft/buildingProductionBank.SC2Bank, si" ) @=> OscEvent oe;
    
    while ( true )
    {
        oe => now;
        
        while ( oe.nextMsg() != 0 )
        { 
            oe.getString() => string key;
            oe.getInt() => int value;
            
            //<<< "/lorkCraft/buildingProductionBank.SC2Bank:", key, value >>>;
            
            if(isProduction(key))
                bassDrone[p].setUnderConstruction(value);
        }
    }
}


fun void listenForResearchCompleted(int p)
{
    player[p].event( "/lorkCraft/researchCompletedBank.SC2Bank, si" ) @=> OscEvent oe;
    
    while ( true )
    {
        oe => now;
        
        while( oe.nextMsg() != 0 )
        { 
            oe.getString() => string key;
            oe.getInt() => int value;
            
            for(int i; i < playerUnits[p].cap(); i++)
            {
                if(arpeggio[playerUnits[p][i]] != null)
                    arpeggio[playerUnits[p][i]].setTechLevel(value);
            }
            bassDrone[p].setTechLevel(value);
        }
    }
}

fun void listenForUnitsAndStructuresLost(int p)
{
    player[p].event( "/lorkCraft/scoreBank.SC2Bank, si" ) @=> OscEvent oe;
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
                while(totalLost < value)
                {
                    totalLost++;
                    spork ~ death.strike(Std.rand2f(50, 300)::ms);
                }
            }
        }
    }
}

fun void listenForAbilities(int p)
{
    player[p].event( "/lorkCraft/abilitiesUsedBank.SC2Bank, ss" ) @=> OscEvent oe;
    
    while ( true )
    {
        oe => now;
        
        while( oe.nextMsg() != 0 )
        { 
            oe.getString() => string unit;
            oe.getString() => string ability;
            
            //<<< "/lorkCraft/abilitiesUsedBank.SC2Bank:", unit, ability >>>;
            if(ability == "TacNukeStrike")
            {
                //<<< "/lorkCraft/abilitiesUsedBank.SC2Bank:", unit, ability >>>;
                nuke.nukeCalled();
            }
        }
    }
}

for(int p; p < 2; p++)
{
    spork ~ listenForMineralChanges(p);
    spork ~ listenForVespeneChanges(p);
    //spork ~ listenForSupplyChanges();
    spork ~ listenForUnitsBuilt(p);
    spork ~ listenForBuildingConstruction(p);
    spork ~ listenForResearchCompleted(p);
    spork ~ listenForUnitsAndStructuresLost(p);
    spork ~ listenForAbilities(p);
}

10::day => now;

