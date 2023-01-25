include <../openscad_pvc.scad>

p = pvc_spec_lookup(schedule=40, dn="DN20");
p2 = pvc_spec_lookup(schedule=40, dn="DN10");

spacing = 80;

//right_half()
//    pvc_tee(p, ends=["socket", "mipt", "socket"]);


/*diff("_rem__full")
    pvc_part_component(p, "socket", length=pvc_od(p)/2)
        attach(BOTTOM, "_j_right")
          pvc_part_component(p, "socket", length=pvc_od(p)/2);
*/

/*
ydistribute(spacing=spacing) {
    
    back_half(s=200)
    xdistribute(spacing=spacing) {
        t = "socket";
        pvc_endpoint(p, t);
        pvc_part_component(p, t); 
        diff("_rem__full")
            pvc_part_component(p, t)
                show_anchors(std=false);
    }
    
    back_half(s=200)
    xdistribute(spacing=spacing) {
        t = "spigot";
        pvc_endpoint(p, t);
        pvc_part_component(p, t); 
        diff("_rem__full")
            pvc_part_component(p, t)
                show_anchors(std=false);
    }
    
    back_half(s=200)
    xdistribute(spacing=spacing) {
        t = "fipt";
        pvc_endpoint(p, t);
        pvc_part_component(p, t); 
        diff("_rem__full")
            pvc_part_component(p, t)
                show_anchors(std=false);
    }
    
    back_half(s=200)
    xdistribute(spacing=spacing) {
        t = "mipt";
        pvc_endpoint(p, t);
        pvc_part_component(p, t); 
        diff("_rem__full")
            pvc_part_component(p, t)
                show_anchors(std=false);
    }
}
*/


ydistribute(spacing=spacing) {
    zdistribute(spacing=spacing) {
        pvc_tee(p) show_anchors(std=false);
        pvc_tee(p, ends=["socket", "socket", "socket"]);
        pvc_tee(p, ends=["spigot", "spigot", "spigot"]);
        pvc_tee(p, ends=["mipt", "mipt", "mipt", ]);
        pvc_tee(p, ends=["fipt", "fipt", "fipt"]);
    }
    

    zdistribute(spacing=spacing) {
        pvc_corner(p) show_anchors(std=false);
        pvc_corner(p, ends=["socket", "socket", "socket"]);
        pvc_corner(p, ends=["spigot", "spigot", "spigot"]);
        pvc_corner(p, ends=["mipt", "mipt", "mipt"]);
        pvc_corner(p, ends=["fipt", "fipt", "fipt"]);
    }
    
    zdistribute(spacing=spacing) {
        pvc_side_outlet_tee(p) show_anchors(std=false);
        pvc_side_outlet_tee(p, ends=["socket", "socket", "socket", "socket"]);
        pvc_side_outlet_tee(p, ends=["spigot", "spigot", "spigot", "spigot"]);
        pvc_side_outlet_tee(p, ends=["mipt", "mipt", "mipt", "mipt"]);
        pvc_side_outlet_tee(p, ends=["fipt", "fipt", "fipt", "fipt"]);            
    }
    pvc_cross(p) show_anchors(std=false);
    pvc_six_way_joint(p) show_anchors(std=false);


}


