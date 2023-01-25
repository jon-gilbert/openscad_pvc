include <../openscad_pvc.scad>


echo(is_even(0));
echo(is_odd(0));

p = pvc_spec_lookup(schedule=40, dn="DN20");
p2 = pvc_spec_lookup(schedule=40, dn="DN10");

spacing = 80;

xdistribute(spacing=spacing) {

/*
    back_half()
        pvc_pipe(p, 50, ends=["spigot"])
            attach("A", "B")
                pvc_pipe(p, 50, sizeup=true, ends=[undef, "spigot"]); 

    back_half()
        pvc_pipe(p, 50, ends=["mipt"])
            attach("A", "B")
                pvc_pipe(p, 50, ends=[undef, "spigot"]); 
*/
    
/*
    left_half(s=400)
    ydistribute(spacing=spacing) {
        pvc_pipe(p, 50) show_anchors(std=false);
        pvc_pipe(p, 50, ends=["mipt", "mipt"]);
        pvc_pipe(p, 50, ends=["spigot", "spigot"]);
        //pvc_pipe(p, 50, ends=["fipt", "fipt"]);
        //pvc_pipe(p, 50, ends=["socket", "socket"]);
        #pvc_pipe_internal_bore(p, 50); 
    }

    left_half(s=400)
    ydistribute(spacing=spacing) {
        pvc_pipe(p, 50, sizeup=true) show_anchors(std=false);
        pvc_pipe(p, 50, sizeup=true, ends=["mipt", "mipt"]);
        pvc_pipe(p, 50, sizeup=true, ends=["spigot", "spigot"]);
        pvc_pipe(p, 50, sizeup=true, ends=["fipt", "fipt"]);
        pvc_pipe(p, 50, sizeup=true, ends=["socket", "socket"]);
        #pvc_pipe_internal_bore(p, 50); 
    }
*/

    left_half( s=400 ) {
        ydistribute(spacing=spacing) {
            pvc_pipe(p, 50, ends=[undef, "mipt"])
                attach(TOP, BOTTOM, overlap=-3)
                    pvc_pipe(p, 50, ends=["fipt", undef]);

            pvc_pipe(p, 50, ends=[undef, "mipt"])
                attach("B", "A", overlap=-3)
                    pvc_pipe(p, 50, ends=["fipt", undef]);

            pvc_pipe(p, 50, ends=[undef, "mipt"])
                attach("B", "A")
                    pvc_pipe(p, 50, ends=["fipt", undef]);
        }
    }

    left_half( s=400 ) {
        ydistribute(spacing=spacing) {
            pvc_pipe(p, 50, ends=[undef, "spigot"])
                attach(TOP, BOTTOM, overlap=-3)
                    pvc_pipe(p, 50, ends=["socket", undef]);

            pvc_pipe(p, 50, ends=[undef, "spigot"])
                attach("B", "A", overlap=-3)
                    pvc_pipe(p, 50, ends=["socket", undef]);

            pvc_pipe(p, 50, ends=[undef, "spigot"])
                attach("B", "A")
                    pvc_pipe(p, 50, ends=["socket", undef]);
        }
    }
}

