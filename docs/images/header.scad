include <openscad_pvc.scad>

$fn = 80;
p = pvc_spec_lookup(schedule=40, dn="DN10");
p2 = pvc_spec_lookup(schedule=40, dn="DN25");
s = 40;
ydistribute(spacing=s) {
    xdistribute(spacing=s) {
        pvc_adapter(p, p2, orient=LEFT);
        
        pvc_bushing(p2, p);
        
        pvc_cap(p);
        
        pvc_corner(p);
        
        pvc_coupling(p);
        
        pvc_cross(p);
        
        pvc_elbow(p, 45);
    }
    
    xdistribute(spacing=s) {
        pvc_flange(p);
        
        pvc_nipple(p);

        pvc_elbow(p, 90);
        
        pvc_plug(p);
        
        pvc_six_way_joint(p);
        
        pvc_tee(p);
        
        pvc_wye(p);
    }
    
    pvc_pipe(p, 250, orient=RIGHT);
}
