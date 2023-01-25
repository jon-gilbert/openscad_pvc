include <openscad_pvc.scad>

module test_list_apply_defaults() {
    assert( list_apply_defaults( ["01"], ["01", "02"] )                         == ["01", "02"] );
    assert( list_apply_defaults( [undef], ["01", "02"] )                        == ["01", "02"] );
    assert( list_apply_defaults( [undef, "02"], ["01", "02"] )                  == ["01", "02"] );
    assert( list_apply_defaults( ["01", undef], ["01", "02"] )                  == ["01", "02"] );
    assert( list_apply_defaults( ["02", "03"], ["01", "02"] )                   == ["02", "03"] );
    assert( list_apply_defaults( ["02", "03", "04"], ["01", "02"] )             == ["02", "03", "04"] );
    assert( list_apply_defaults( [true], [true, true, false] )                  == [true, true, false] );
    assert( list_apply_defaults( [undef], [true, true, false] )                 == [true, true, false] );
    assert( list_apply_defaults( [true, undef, true], [true, true, false] )     == [true, true, true] );
}
test_list_apply_defaults();

