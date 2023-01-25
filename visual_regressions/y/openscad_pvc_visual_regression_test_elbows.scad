include <../openscad_pvc.scad>

p = pvc_spec_lookup(schedule=40, dn="DN20");
p2 = pvc_spec_lookup(schedule=40, dn="DN10");

spacing = 80;

ydistribute(spacing=spacing) {
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
        pvc_elbow(p, a) show_anchors(std=false);
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

