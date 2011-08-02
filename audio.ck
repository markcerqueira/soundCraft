// create our OSC receiver
OscRecv recv;
// use port 6449
6449 => recv.port;
// start listening (launch thread)
recv.listen();

SinOsc s => JCRev r => dac;

// create an address in the receiver, store in new variable
recv.event( "/plorkCraft/test, s s" ) @=> OscEvent oe;

// infinite event loop
while ( true )
{
    // wait for event to arrive
    oe => now;
    
    // grab the next message from the queue. 
    while ( oe.nextMsg() != 0 )
    { 
		oe.getString() => string key;
		Std.atoi( oe.getString() ) => int value;

        <<< "got (via OSC):", key, " ", value >>>;
        
        if ( key == "vespene" )
            value => s.freq;
        
        if ( key == "mineralsCollected" )
            value / 1000 => r.mix;
    }
}
