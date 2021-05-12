rule dfir_orc {
    strings:
        $dummy = "This is a dummy rule not supposed to match anything but the binary embedding it!"
    condition :
        $dummy
}