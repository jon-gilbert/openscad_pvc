include <../openscad_pvc.scad>

p = pvc_spec_lookup(schedule=40, dn="DN20");

l = 60;

pvc_corner(p) {
    attach("A", "B") pvc_pipe(p, l, spin=90)
        attach("A", "A")
            pvc_corner(p) {
                attach("B", "B") pvc_pipe(p, l, spin=180)
                    attach("A", "A")
                        pvc_corner(p) {
                            attach("B", "B") pvc_pipe(p, l, spin=180)
                                attach("A", "A")
                                    pvc_corner(p) {
                                        attach("B", "A") pvc_pipe(p, l);
                                        attach("C", "B") pvc_pipe(p, l);
                                    }
                            attach("C", "B") pvc_pipe(p, l);
                        }
                attach("C", "B") pvc_pipe(p, l);
            }
    attach("B", "B") pvc_pipe(p, l, spin=180)
        attach("A", "C")
            pvc_corner(p) {
                attach("A", "A") pvc_pipe(p, l, spin=180)
                    attach("B", "B")
                        pvc_corner(p) {
                            attach("A", "A")
                                pvc_pipe(p, l, spin=-90)
                                    attach("B", "A")
                                        pvc_corner(p)
                                            attach("C", "A")
                                                pvc_pipe(p, l, spin=90)
                                                    attach("B", "A")
                                                        pvc_corner(p)
                                                            attach("C", "A")
                                                                pvc_pipe(p, l);
                        }
            }
}
