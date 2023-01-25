include <../openscad_pvc.scad>

p = pvc_spec_lookup(schedule=40, dn="DN20");
p2 = pvc_spec_lookup(schedule=40, dn="DN10");

spacing = 80;

//pvc_tee(p, ends=["spigot", "spigot", "spigot"]);

/*
diff("_rem__full")
    pvc_part_component(p, "fipt")
        attach(BOTTOM, "_j_right")
            pvc_part_component(p, "socket");
*/

ydistribute(spacing=30) {
    xdistribute(spacing=30) {
        back_half()
            pvc_part_component(p, "spigot");
        back_half()
            pvc_part_component(p, "socket");
        back_half()
            pvc_part_component(p, "mipt");
        back_half()
            pvc_part_component(p, "fipt");
        
    }
    
    xdistribute(spacing=30) {
        diff("_rem__full") 
            back_half()
                pvc_part_component(p, "spigot");
        diff("_rem__full") 
            back_half()
                pvc_part_component(p, "socket");
        diff("_rem__full") 
            back_half()
                pvc_part_component(p, "mipt");
        diff("_rem__full") 
            back_half()
                pvc_part_component(p, "fipt");
        
    }
    
}

