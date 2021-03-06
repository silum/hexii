#! /bin/sh

set -e

ascii() {
    awk 'BEGIN { for (x = 0; x < 256; x++) printf "%c", x }'
}

xcmp() {
    cmp -s /dev/stdin /dev/stderr
}

xhexii() {
    ./hexii "$@" - |
    sed "s^$(printf '\033')\\[[0-9;]*[a-zA-Z]^^g"
}

# more nulls than read buffer
printf .
head -c 8196 /dev/zero |
xhexii |
xcmp 2<<!
       0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F

2000:             ]
!

# all ASCII chars
printf .
ascii |
xhexii |
xcmp 2<<'!'
      0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F

000:    01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
 10: 10 11 12 13 14 15 16 17 18 19 1A 1B 1C 1D 1E 1F
 20: 20 .! ." .# .$ .% .& .' .( .) .* .+ ., .- .. ./
 30: .0 .1 .2 .3 .4 .5 .6 .7 .8 .9 .: .; .< .= .> .?
 40: .@ .A .B .C .D .E .F .G .H .I .J .K .L .M .N .O
 50: .P .Q .R .S .T .U .V .W .X .Y .Z .[ .\ .] .^ ._
 60: .` .a .b .c .d .e .f .g .h .i .j .k .l .m .n .o
 70: .p .q .r .s .t .u .v .w .x .y .z .{ .| .} .~ 7F
 80: 80 81 82 83 84 85 86 87 88 89 8A 8B 8C 8D 8E 8F
 90: 90 91 92 93 94 95 96 97 98 99 9A 9B 9C 9D 9E 9F
 A0: A0 A1 A2 A3 A4 A5 A6 A7 A8 A9 AA AB AC AD AE AF
 B0: B0 B1 B2 B3 B4 B5 B6 B7 B8 B9 BA BB BC BD BE BF
 C0: C0 C1 C2 C3 C4 C5 C6 C7 C8 C9 CA CB CC CD CE CF
 D0: D0 D1 D2 D3 D4 D5 D6 D7 D8 D9 DA DB DC DD DE DF
 E0: E0 E1 E2 E3 E4 E5 E6 E7 E8 E9 EA EB EC ED EE EF
 F0: F0 F1 F2 F3 F4 F5 F6 F7 F8 F9 FA FB FC FD FE ##
100: ]
!

# columns
printf .
ascii |
xhexii -c11 |
xcmp 2<<'!'
      0  1  2  3  4  5  6  7  8  9  A

000:    01 02 03 04 05 06 07 08 09 0A
  B: 0B 0C 0D 0E 0F 10 11 12 13 14 15
 16: 16 17 18 19 1A 1B 1C 1D 1E 1F 20
 21: .! ." .# .$ .% .& .' .( .) .* .+
  C: ., .- .. ./ .0 .1 .2 .3 .4 .5 .6
 37: .7 .8 .9 .: .; .< .= .> .? .@ .A
 42: .B .C .D .E .F .G .H .I .J .K .L
  D: .M .N .O .P .Q .R .S .T .U .V .W
 58: .X .Y .Z .[ .\ .] .^ ._ .` .a .b
 63: .c .d .e .f .g .h .i .j .k .l .m
  E: .n .o .p .q .r .s .t .u .v .w .x
 79: .y .z .{ .| .} .~ 7F 80 81 82 83
 84: 84 85 86 87 88 89 8A 8B 8C 8D 8E
  F: 8F 90 91 92 93 94 95 96 97 98 99
 9A: 9A 9B 9C 9D 9E 9F A0 A1 A2 A3 A4
 A5: A5 A6 A7 A8 A9 AA AB AC AD AE AF
 B0: B0 B1 B2 B3 B4 B5 B6 B7 B8 B9 BA
  B: BB BC BD BE BF C0 C1 C2 C3 C4 C5
 C6: C6 C7 C8 C9 CA CB CC CD CE CF D0
 D1: D1 D2 D3 D4 D5 D6 D7 D8 D9 DA DB
  C: DC DD DE DF E0 E1 E2 E3 E4 E5 E6
 E7: E7 E8 E9 EA EB EC ED EE EF F0 F1
 F2: F2 F3 F4 F5 F6 F7 F8 F9 FA FB FC
  D: FD FE ## ]
!

printf .
ascii |
xhexii -c 42 |
xcmp 2<<'!'
      0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F 10 11 12 13 14 15 16 17 18 19 1A 1B 1C 1D 1E 1F 20 21 22 23 24 25 26 27 28 29

000:    01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F 10 11 12 13 14 15 16 17 18 19 1A 1B 1C 1D 1E 1F 20 .! ." .# .$ .% .& .' .( .)
 2A: .* .+ ., .- .. ./ .0 .1 .2 .3 .4 .5 .6 .7 .8 .9 .: .; .< .= .> .? .@ .A .B .C .D .E .F .G .H .I .J .K .L .M .N .O .P .Q .R .S
 54: .T .U .V .W .X .Y .Z .[ .\ .] .^ ._ .` .a .b .c .d .e .f .g .h .i .j .k .l .m .n .o .p .q .r .s .t .u .v .w .x .y .z .{ .| .}
 7E: .~ 7F 80 81 82 83 84 85 86 87 88 89 8A 8B 8C 8D 8E 8F 90 91 92 93 94 95 96 97 98 99 9A 9B 9C 9D 9E 9F A0 A1 A2 A3 A4 A5 A6 A7
 A8: A8 A9 AA AB AC AD AE AF B0 B1 B2 B3 B4 B5 B6 B7 B8 B9 BA BB BC BD BE BF C0 C1 C2 C3 C4 C5 C6 C7 C8 C9 CA CB CC CD CE CF D0 D1
 D2: D2 D3 D4 D5 D6 D7 D8 D9 DA DB DC DD DE DF E0 E1 E2 E3 E4 E5 E6 E7 E8 E9 EA EB EC ED EE EF F0 F1 F2 F3 F4 F5 F6 F7 F8 F9 FA FB
 FC: FC FD FE ## ]
!

# -fin-
