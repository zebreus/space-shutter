// From https://www.thingiverse.com/thing:3406724

$fn=100;

translate([-w/2-10,0,d+bpt+tpt])
rotate(a=180, v=[0,1,0])
box_top();
translate([w/2+10,0,0])
box_bottom();
             

//*************************************************//
//PARAMETERS
//*************************************************//
//BOX
//--------------------------------------------------
//inner box width + tolerances
w=75;
//inner box length + tolerances
h=25;
//inner box depth 
d=9;
//wall tickness
wt=3.0;
//bottom plate tickness
bpt=2.2;
//top plate tickness
tpt=2.4;
//top cutout depth
cd=3;
//top cutout tickness
cwt=1.5;
//--------------------------------------------------
//BOARD MOUNTING HOLES
//--------------------------------------------------
//position
cx=2.5;
cy=-3.5;
//holes size (radius)
chs_i=1.05;
chs_o=2;
//distancer height
dsth=7;
//holes distance h
chd_h=42.25;
//holes distance v
chd_v=17;
//--------------------------------------------------
//TOP PART MOUNTING HOLES
//--------------------------------------------------
//position
cx1=0;
cy1=0;
//holes size (radius)
chs_i1=5.25;
chs_o1=chs_i1+0.5;
//holes distance h
chd_h1=h-2*chs_i1-2;
//holes distance v
chd_v1=w-2*chs_i1-2;
//*************************************************//
//*************************************************//
//MODULES
//*************************************************//

//top box part          
module box_top()
{
        difference()
        {
            union()
            {
                difference()
                {
                    translate([ 0, 0, d+bpt-cd-0.2])     
                    rounded_cube( w+2*wt, h+2*wt, tpt+cd+0.2, 6);
                    
                    translate([ 0, 0,  d+bpt-cd-1])
                    rounded_cube( w+2*cwt+0.3, h+2*cwt+0.3, cd+1, 4);
                }
                /*************************/
                
                //add here...
                
                /*************************/
            }
            //TOP PART HOLES
            tph_t_cut();
            /*************************/
            
            //subtract here... 
            
            /*************************/ 
        }
}
//bottom box
module box_bottom()
{
    difference()
    {
        union()
        {
            difference()
            {
                rounded_cube( w+2*wt, h+2*wt, d+bpt, 6);
                
                translate([ 0, 0, -cd])
                difference()
                {
                    translate([ 0, 0,  d+bpt])
                    rounded_cube( w+2*wt+1, h+2*wt+1, cd+1, 4);

                    translate([ 0, 0,  d+bpt-1])
                    rounded_cube( w+2*cwt, h+2*cwt, cd+3, 4);
                }
                translate([ 0, 0, bpt])
                rounded_cube( w, h, d+bpt, 4);
            }
            //BOARD DISTANCER
            board_distancer();
            //TOP PLATE DISTANCER
            top_distancer();
            /*************************/
            
            //add here...
            
            /*************************/
        }
        
        //BOARD HOLES
        bh_cut();
        //TOP PART HOLES
        tph_b_cut();
        /*************************/
        
        // USB c port cut
        usb_c_tolerance = 3.5;
        usb_c_port_pos_height = 3.5;
        usb_c_port_pos_y = 8;
    
        mirror([1,0,0])
        translate([-w/2+1,h/2 - usb_c_port_pos_y,bpt + usb_c_port_pos_height])
        rotate([0,0,180])
        minkowski(){
        cube([30,9,3]);
            rotate([0,90,0])
        cylinder(r=usb_c_tolerance);
        }
        
        // ws2812
        
        translate([-27,-2.5,0.2]) {
          {
          translate([0, 1,1])
          cube([3,3,4]);
          translate([3-0.25, -0.25,0])
          cube([5.5,5.5,4]);
          translate([3, -2,1])
          cube([2,2,4]);
          translate([6, -2,1])
          cube([2,2,4]);
          translate([3, 5,1])
          cube([2,2,4]);
          translate([6, 5,1])
          cube([2,2,4]);
          }
          translate([11.5,0,0])
          {
          translate([0, 1,1])
          cube([3,3,4]);
          translate([3-0.25, -0.25,0])
          cube([5.5,5.5,4]);
          translate([3, -2,1])
          cube([2,2,4]);
          translate([6, -2,1])
          cube([2,2,4]);
          translate([3, 5,1])
          cube([2,2,4]);
          translate([6, 5,1])
          cube([2,2,4]);
          }
          translate([-2, -3,1.8])
          cube([27, 11, 4]);

        }
        
        // button
                translate([10,0,0]){
                    translate([0,7,0])
        button();
                    translate([0,-7,0])
        button();
                    }
                    
                    translate([15,0,0])
                    translate([0,-9,1.8])
                    cube([23,18,7])
                    ;
        
        
        //subtract here...
        
        /*************************/
  
    }
}

module button() {
            {
                    rotate([0,0,90])
                    translate([-3,-3,0])
          {
    
          translate([0, 0,-4])
          %cube([6,6,4+1.4]);
          translate([0, -1,-1])
          cube([2,2,4]);
          translate([4, -1,-1])
          cube([2,2,4]);
          translate([0,5,-1])
          cube([2,2,4]);
          translate([4, 5,-1])
          cube([2,2,4]);
          }


        }
        }

/****************************************************/
module board_distancer()
{
    translate([cx,cy,0])
    {              
//        translate([+chd_h/2,chd_v/2,0])
//        cylinder(r=chs_o,h=bpt+dsth);
//        translate([-chd_h/2,chd_v/2,0])
//        cylinder(r=chs_o,h=bpt+dsth);
//        translate([+chd_h/2,-chd_v/2,0])
//        cylinder(r=chs_o,h=bpt+dsth);
//        translate([-chd_h/2,-chd_v/2,0])
//        cylinder(r=chs_o,h=bpt+dsth);
    }
}
module top_distancer()
{
    translate([cx1,cy1,0])
    {
      
        translate([0, 0, 0])   
        cylinder(r=chs_o1,h=d+bpt);
            translate([-chd_v1/2 -2, 0, 0])   
        cylinder(r=chs_o1,h=d+bpt);
    }
}
module bh_cut()
{
    translate([cx,cy,0])
    {  
//        translate([-chd_h/2,-chd_v/2,-1])
//        cylinder(r=chs_i,h=bpt+dsth+2);
//        translate([+chd_h/2,-chd_v/2,-1])
//        cylinder(r=chs_i,h=bpt+dsth+2);
//        translate([-chd_h/2,chd_v/2,-1])
//        cylinder(r=chs_i,h=bpt+dsth+2);
//        translate([+chd_h/2,chd_v/2,-1])
//        cylinder(r=chs_i,h=bpt+dsth+2);
        
//        translate([-chd_h/2,-chd_v/2,1.3])
//        fhex(5.5,3);
//        translate([+chd_h/2,-chd_v/2,1.3])
//        fhex(5.5,3);
//        translate([-chd_h/2,chd_v/2,1.3])
//        fhex(5.5,3);
//        translate([+chd_h/2,chd_v/2,1.3])
//        fhex(5.5,3);
        
        // Ultra sonic holes
//        translate([-26.5/2,0,-1])
//        cylinder(d=17, h= bpt+dsth+2);
//             translate([25/2,0,-1])
//        cylinder(d=17, h= bpt+dsth+2);
    }
}

module tph_t_cut()
{
    translate([cx1,cy1,0])
    {
  
    
         translate([chd_v1/2+2, 0, -3.4])   
        cylinder(r=chs_i1,h=d+bpt+tpt+3);
                 translate([0, 0, -3.4])   
        cylinder(r=chs_i1,h=d+bpt+tpt+3);
        
//        translate([-chd_v1/2, chd_h1/2, d+bpt+tpt-1.3]) 
//        fhex(5.5,3);
//        
//        translate([chd_v1/2, chd_h1/2, d+bpt+tpt-1.3])  
//        fhex(5.5,3);
//    
//        translate([-chd_v1/2, -chd_h1/2, d+bpt+tpt-1.3])   
//        fhex(5.5,3);
//        
//        translate([chd_v1/2, -chd_h1/2, d+bpt+tpt-1.3])   
//        fhex(5.5,3);
    
    }   
}
module tph_b_cut()
{
    translate([cx1,cy1,0])
    {

         translate([-chd_v1/2 -2, 0, 0 + d+bpt -2.2])   
        cylinder(r=chs_i1,h=3);
        translate([0, 0, 0 + d+bpt -2.2])   
        cylinder(r=chs_i1,h=3);
        
        
//        translate([-chd_v1/2, chd_h1/2, -1]) 
//        cylinder(r=3,h=4);
//        
//        translate([chd_v1/2, chd_h1/2, -1])  
//        cylinder(r=3,h=4);
//    
//        translate([-chd_v1/2, -chd_h1/2, -1])   
//        cylinder(r=3,h=4);
//        
//        translate([chd_v1/2, -chd_h1/2, -1])   
//        cylinder(r=3,h=4); 
    
    }   
}


module rounded_cube( x, y, z, r)
{
    translate([-x/2+r,-y/2+r,0])
    linear_extrude(height=z)
    minkowski() 
    {
        square([x-2*r,y-2*r],true);
        translate([x/2-r,y/2-r,0])
        circle(r);

    }
}

module fhex(wid,height)
{
    hull()
    {
        cube([wid/1.7,wid,height],center = true);
        rotate([0,0,120])cube([wid/1.7,wid,height],center = true);
        rotate([0,0,240])cube([wid/1.7,wid,height],center = true);
    }
}
