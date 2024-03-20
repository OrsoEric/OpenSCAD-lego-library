/*      
        Even More Customizable Straight LEGO Technic Beam
        Based on Customizable Straight LEGO Technic Beam
         and Parametric LEGO Technic Beam by "projunk" and "stevemedwin"
        
        www.thingiverse.com/thing:203935
        
        Also uploaded to Prusaprinters.org at https://www.prusaprinters.org/prints/33038-even-more-customizable-straight-beam-for-legotm-te
        
        Modified by Sam Kass
        November 2015

		Modified by Orso Eric (2024-03)	
		https://github.com/OrsoEric/OpenSCAD-lego-library
*/

// user parameters

//Hole sequence
//o for round hole
//+ for plus-shaped hole
//capital O for sideways hole
//capital P for sideways plus
//and x for blank spot.
//eg. lego_beam("+xPOo");

cn_lego_pitch_stud = 8.0;
cn_lego_drill_small = 4.9/2;
cn_lego_drill_large = 6.1/2;
cn_lego_height_beam = 7.8;
cn_lego_drill_depth_indent = 0.85;
cn_lego_width_beam = 7.3; 
cn_lego_drill_axel = 2.0;

n_lego_resolution = 100;

module body( in_length_stud, in_height = cn_lego_height_beam )
{
    translate([0, cn_lego_width_beam/2, 0]) 
    hull()
	{
        cylinder(r=cn_lego_width_beam/2, h=in_height,$fn=n_lego_resolution);    
        translate([(in_length_stud-1)*cn_lego_pitch_stud, 0, 0]) 
            cylinder(r=cn_lego_width_beam/2, h=in_height, $fn=n_lego_resolution);
    }
}

module hole( in_height = cn_lego_height_beam )
{
    union()
	{
        //core
        cylinder(r=cn_lego_drill_small,h=in_height,$fn=n_lego_resolution);
        
        //top countersink
        translate([0,0,cn_lego_height_beam-cn_lego_drill_depth_indent]) 
            cylinder(r=cn_lego_drill_large,h=cn_lego_drill_depth_indent,$fn=n_lego_resolution);
        
        //bottom countersink
        translate([0,0,0]) 
            cylinder(r=cn_lego_drill_large,h=cn_lego_drill_depth_indent,$fn=n_lego_resolution);
        
        translate([0,0,cn_lego_drill_depth_indent])
            cylinder(h=(cn_lego_drill_large - cn_lego_drill_small), r1=cn_lego_drill_large, r2=cn_lego_drill_small,$fn=n_lego_resolution);
    }
}

module plus( in_height = cn_lego_height_beam )
{

    union()
	{
        translate([-cn_lego_drill_axel/2, -cn_lego_drill_small, 0]) 
            cube([cn_lego_drill_axel, cn_lego_drill_small*2, in_height]);
        translate([-cn_lego_drill_small, -cn_lego_drill_axel/2, 0]) 
            cube([cn_lego_drill_small*2, cn_lego_drill_axel, in_height]);
    }
}

module lego_beam( is_holes, in_height = cn_lego_height_beam  )
{
	//number of studs
	in_length = len(is_holes);

	if (in_length > 0)
	{
		//Center the beam
		translate([0,cn_lego_pitch_stud,0])
		rotate([90,0,0])
		difference()
		{
			body( in_length, in_height );
			for (i = [1:in_length])
			{
				if (is_holes[i-1] == "+")
					translate([(i-1)*cn_lego_pitch_stud, cn_lego_width_beam/2, 0])
						plus( in_height );
				else if (is_holes[i-1] == "o")
					translate([(i-1)*cn_lego_pitch_stud, cn_lego_width_beam/2, 0])
						hole( in_height );
				else if (is_holes[i-1] == "O")
					rotate([90,0,0])
					translate([(i-1)*cn_lego_pitch_stud, cn_lego_width_beam/2,-cn_lego_pitch_stud+cn_lego_drill_depth_indent/2])
						hole( in_height );
				else if (is_holes[i-1] == "P")
					rotate([90,0,0])
					translate([(i-1)*cn_lego_pitch_stud, cn_lego_width_beam/2,-cn_lego_pitch_stud+cn_lego_drill_depth_indent/2])
						plus( in_height );
				else 
				{
					//no drill, leave a blank space
				}
			}
		}
	}
}

//Get an array of string, each will become a beam
//E.g. lego_plate(["o+Po", "oPOo", "oP+o"]);
// o+Po
// oPOo
// oP+o
module lego_plate( ias_pattern )
{
	//number of beams side to side
	in_width_stud = len(ias_pattern);

    for (cnt = [0:in_width_stud-1])
    {
        translate([0,cn_lego_pitch_stud*cnt,-0.5*cn_lego_width_beam])
            lego_beam(ias_pattern[cnt], cn_lego_pitch_stud);
    }
}

//Same as lego_plate, but slices along width, not length
//It's easier to make patterns on plates this way
//E.g. lego_plate(["ooo", "+PP", "PO+","ooo"]);
module lego_plate_alternate(ias_pattern)
{
    // number of beams side to side
    in_width_stud = len(ias_pattern[0]); // assuming all strings are of the same length
	in_length_stud = len(ias_pattern);
	echo("Length: ",in_length_stud, "cn_lego_width_beam: ", in_width_stud);
    for (cnt = [0:in_width_stud-1])
    {
        ac_array = [for(i = [0:in_length_stud-1]) ias_pattern[i][cnt]];
		echo( "Beam:", cnt, "Pattern:", ac_array );
        translate([0,cn_lego_pitch_stud*cnt,-0.5*cn_lego_width_beam])
            lego_beam(ac_array, cn_lego_pitch_stud);
    }
}

//lego_plate_alternate(["ooo", "+++", "POP", "ooo"]);
