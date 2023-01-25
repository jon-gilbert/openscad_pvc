include <../openscad_pvc.scad>

spacing = 80;

p = pvc_spec_lookup(schedule=40, dn="DN20");
p2 = pvc_spec_lookup(schedule=40, dn="DN10");

xdistribute(spacing=spacing) {
    zdistribute(spacing=spacing) {
        pvc_endpoint(p) show_anchors();
        pvc_endpoint(p, type="spigot");
        pvc_endpoint(p, type="socket");
        pvc_endpoint(p, type="mipt");
        pvc_endpoint(p, type="fipt");
    }

    zdistribute(spacing=spacing) {
        pvc_endpoint_negative(p) show_anchors();
        pvc_endpoint_negative(p, type="spigot");
        pvc_endpoint_negative(p, type="socket");
        pvc_endpoint_negative(p, type="mipt");
        pvc_endpoint_negative(p, type="fipt");
    }

    zdistribute(spacing=spacing) {
        pvc_part_component(p) show_anchors();
        pvc_part_component(p, end="spigot");
        pvc_part_component(p, end="socket");
        pvc_part_component(p, end="mipt");
        pvc_part_component(p, end="fipt");
    }

    zdistribute(spacing=spacing) {
        #diff("_rem__full") 
            pvc_endpoint(p) 
                show_anchors();
        diff("_rem__full") 
            pvc_endpoint(p, type="spigot")
                show_anchors();
        diff("_rem__full") 
            pvc_endpoint(p, type="socket")
                show_anchors();
        diff("_rem__full") 
            pvc_endpoint(p, type="mipt")
                show_anchors();
        diff("_rem__full") 
            pvc_endpoint(p, type="fipt")
                show_anchors();
    }

    zdistribute(spacing=spacing) {
        diff("_rem__full") 
            pvc_part_component(p) 
                show_anchors();
        diff("_rem__full") 
            pvc_part_component(p, end="spigot")
                show_anchors();
        diff("_rem__full") 
            pvc_part_component(p, end="socket")
                    show_anchors();
        diff("_rem__full") 
            pvc_part_component(p, end="mipt")
                show_anchors();
        diff("_rem__full") 
            pvc_part_component(p, end="fipt")
                show_anchors();
    }

}

