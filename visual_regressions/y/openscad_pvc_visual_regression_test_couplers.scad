include <../openscad_pvc.scad>

p = pvc_spec_lookup(schedule=40, dn="DN20");
p2 = pvc_spec_lookup(schedule=40, dn="DN10");

spacing = 80;

xdistribute(spacing=spacing) {

    ydistribute(spacing=spacing) {
        zdistribute(spacing=spacing) {
            pvc_coupling(p) show_anchors(std=false);
            pvc_coupling(p, ends=["socket", "socket"]);
            pvc_coupling(p, ends=["spigot", "spigot"]);
            pvc_coupling(p, ends=["mipt", "mipt"]);
            pvc_coupling(p, ends=["fipt", "fipt"]);
        }

        zdistribute(spacing=spacing) {
            pvc_adapter(p, p2) show_anchors(std=false);
            pvc_adapter(p, p2, ends=["socket", "socket"]);
            pvc_adapter(p, p2, ends=["spigot", "spigot"]);
            pvc_adapter(p, p2, ends=["mipt", "mipt"]);
            pvc_adapter(p, p2, ends=["fipt", "fipt"]);
        }

        zdistribute(spacing=spacing) {
            pvc_bushing(p, p2) show_anchors(std=false);
            pvc_bushing(p, p2);
            //pvc_bushing(p, p2, ends=["socket", "socket"]);
            //pvc_bushing(p, p2, ends=["spigot", "spigot"]);
            //pvc_bushing(p, p2, ends=["mipt", "mipt"]);
            //pvc_bushing(p, p2, ends=["fipt", "fipt"]);
        }
    }

    zdistribute(spacing=spacing) {
        pvc_nipple(p) show_anchors(std=false);
        pvc_nipple(p);
    }

    zdistribute(spacing=spacing) {
        pvc_flange(p) show_anchors(std=false);
        pvc_flange(p, ends=["socket"]);
        pvc_flange(p, ends=["spigot"]);
        pvc_flange(p, ends=["mipt"]);
        pvc_flange(p, ends=["fipt"]);
    }

}

