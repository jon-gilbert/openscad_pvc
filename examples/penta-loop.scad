include <../openscad_pvc.scad>

p = pvc_spec_lookup(schedule=40, dn="DN20");

pvc_elbow(p, 72, orient=BACK)
    attach("A", "B") pvc_pipe(p, 50, spin=180)
        attach("A", "B") pvc_elbow(p, 72)
            attach("A", "B") pvc_pipe(p, 50, spin=180)
                attach("A", "B") pvc_elbow(p, 72)
                    attach("A", "B") pvc_pipe(p, 50, spin=180)
                        attach("A", "B") pvc_elbow(p, 72)
                            attach("A", "B") pvc_pipe(p, 50, spin=180)
                                attach("A", "B") pvc_elbow(p, 72)
                                    attach("A", "B") pvc_pipe(p, 50);
