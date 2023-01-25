// HEADS UP
// HEADS UP
// HEADS UP
// 
// This is a long render. LONG. On my laptop it clocks in at a 
// 2+ minute preview and a 44-minute render. 
// Unless you really, REALLY need to see each of these at the 
// same time, I recommend using the 
// shorter, smaller `openscad_pvc_test_elbow.scad` file that 
// tries to examine fewer than 35 objects.
//
// HEADS UP
// HEADS UP
// HEADS UP



include <../openscad_pvc.scad>


spacing = 80;

p = pvc_spec_lookup(schedule=40, dn="DN20");
p2 = pvc_spec_lookup(schedule=40, dn="DN10");


xdistribute(spacing=spacing) {
    zdistribute(spacing=spacing) {
        a = 15;
        pvc_elbow(p, a) show_anchors(std=false);
        pvc_elbow(p, a, ends=["socket", "socket"]);
        pvc_elbow(p, a, ends=["spigot", "spigot"]);
        pvc_elbow(p, a, ends=["mipt", "mipt"]);
        pvc_elbow(p, a, ends=["fipt", "fipt"]);
    }

    zdistribute(spacing=spacing) {
        a = 30;
        pvc_elbow(p, a) show_anchors(std=false);
        pvc_elbow(p, a, ends=["socket", "socket"]);
        pvc_elbow(p, a, ends=["spigot", "spigot"]);
        pvc_elbow(p, a, ends=["mipt", "mipt"]);
        pvc_elbow(p, a, ends=["fipt", "fipt"]);
    }

    zdistribute(spacing=spacing) {
        a = 45;
        pvc_elbow(p, a) show_anchors(std=false);
        pvc_elbow(p, a, ends=["socket", "socket"]);
        pvc_elbow(p, a, ends=["spigot", "spigot"]);
        pvc_elbow(p, a, ends=["mipt", "mipt"]);
        pvc_elbow(p, a, ends=["fipt", "fipt"]);
    }

    zdistribute(spacing=spacing) {
        a = 50;
        pvc_elbow(p, a) show_anchors(std=false);
        pvc_elbow(p, a, ends=["socket", "socket"]);
        pvc_elbow(p, a, ends=["spigot", "spigot"]);
        pvc_elbow(p, a, ends=["mipt", "mipt"]);
        pvc_elbow(p, a, ends=["fipt", "fipt"]);
    }

    zdistribute(spacing=spacing) {
        a = 70;
        pvc_elbow(p, a) show_anchors(std=false);
        pvc_elbow(p, a, ends=["socket", "socket"]);
        pvc_elbow(p, a, ends=["spigot", "spigot"]);
        pvc_elbow(p, a, ends=["mipt", "mipt"]);
        pvc_elbow(p, a, ends=["fipt", "fipt"]);
    }

    zdistribute(spacing=spacing) {
        a = 90;
        pvc_elbow(p, a, ends=["spigot", "socket"]) show_anchors(std=false);
        pvc_elbow(p, a, ends=["socket", "socket"]);
        pvc_elbow(p, a, ends=["spigot", "spigot"]);
        pvc_elbow(p, a, ends=["mipt", "mipt"]);
        pvc_elbow(p, a, ends=["fipt", "fipt"]);
    }

    zdistribute(spacing=spacing) {
        a = 120;
        pvc_elbow(p, a) show_anchors(std=false);
        pvc_elbow(p, a, ends=["socket", "socket"]);
        pvc_elbow(p, a, ends=["spigot", "spigot"]);
        pvc_elbow(p, a, ends=["mipt", "mipt"]);
        pvc_elbow(p, a, ends=["fipt", "fipt"]);
    }
}

