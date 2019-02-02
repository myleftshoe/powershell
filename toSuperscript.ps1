function toSuperscript($text) {
    $hash = @{}
    $hash.0 = "$([char]0x2070)"
    $hash.1 = "$([char]0x00B9)"
    $hash.2 = "$([char]0x00B2)"
    $hash.3 = "$([char]0x00B3)"
    $hash.4 = "$([char]0x2074)"
    $hash.5 = "$([char]0x2075)"
    $hash.6 = "$([char]0x2076)"
    $hash.7 = "$([char]0x2077)"
    $hash.8 = "$([char]0x2078)"
    $hash.9 = "$([char]0x2079)"

    Foreach ($key in $hash.Keys) {
        $text = $text.Replace($key, $hash.$key)
    }
    return $text
}
