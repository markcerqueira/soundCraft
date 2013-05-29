//-----------------------------------------------------------------------------
// name: vector3d.ck
// desc: vector3D class
//
// author: Ge Wang (ge@ccrma.stanford.edu)
//         adapted from Ge Wang's Vector3D C++ class
//   date: 2013
//-----------------------------------------------------------------------------


//-----------------------------------------------------------------------------
// name: class Vector3D
// desc: 3d vector; also can be used as slewing interpolator
//-----------------------------------------------------------------------------
public class Vector3D
{
    float x;
    float y;
    float z;
    
    // set values
    fun void set( float _x, float _y, float _z )
    { _x => x; _y => y; _z => z; }
    
    // get value
    fun float value() { return x; }
    // get goal
    fun float goal() { return y; }
    // get slew
    fun float slew() { return z; }
    
    // get/set value
    fun float value( float n ) { n => x; return x; }
    // get/set goal
    fun float goal( float n ) { n => y; return y; }
    // get/set slew
    fun float slew( float n ) { n => z; return z; }
    
    // update goal
    fun void update( float theGoal, float theSlew )
    {
        theGoal => goal;
        theSlew => slew;
    }
    
    // interpolate (spork this)
    fun void interp( dur dt )
    {
        // factor
        dt / second => float factor;
        // time loop
        while( true )
        {
            // update x
            (y - x) * z * factor + x => x;
            // advance time
            dt => now;
        }
    }
}
//-----------------------------------------------------------------------------
// end class Vector3D definition
//-----------------------------------------------------------------------------


// comment out to run test function
// test();


// test function
fun void test()
{
    // instantiate
    Vector3D v;
    // set initial value, gaol, slew
    v.set( 0, 100, .1 );
    // spork the interpolator
    spork ~ v.interp( 100::ms );
    
    // observe it
    while( true )
    {
        // print value
        <<< v.value() >>>;
        // every so often
        100::ms => now;
    }
}