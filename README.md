# HexII - a compact binary representation (mixing Hex and ASCII)

because ASCII dump is usually useless,
unless there is an ASCII string,
in which case the HEX part is useless

Hex:
- ASCII chars are replaced as .<char>
- 00 is replaced by "  "
- FF is replaced by "##"
- other chars are returned as hex

Output:
- a hex ruler is shown at the top of the 'display'
- offsets don't contain superfluous 0
- offsets are removed identical starting characters if following the previous
- lines full of 00 are skipped
- offsets after a skip are fully written
- Last_Offset+1 is marked with "]"
  (because EOF could be absent)
