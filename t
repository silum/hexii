#! /bin/sh

set -e

ascii() {
    awk 'BEGIN { for (x = 0; x < 256; x++) printf "%c", x }'
}

simple() {
    printf "min: "
    printf '\000'
    printf "	&\n"
    printf "max: "
    printf '\377'
}

xcmp() {
    printf .
    cmp -s /dev/stdin /dev/stderr
}

xhexii() {
    ./hexii "$@" - |
    sed "s^$(printf '\033')\\[[0-9;]*[a-zA-Z]^^g"
}

# more nulls than read buffer
head -c 8196 /dev/zero |
xhexii |
xcmp 2<<!
       0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F

2000:             ]
!

# all ASCII chars
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

# ansi
simple |
./hexii -a - |
xcmp 2<<'!'
  [0;33m  0[0m[0;33m  1[0m[0;33m  2[0m[0;33m  3[0m[0;33m  4[0m[0;33m  5[0m[0;33m  6[0m[0;33m  7[0m[0;33m  8[0m[0;33m  9[0m[0;33m  A[0m[0;33m  B[0m[0;33m  C[0m[0;33m  D[0m[0;33m  E[0m[0;33m  F[0m

[0;33m0:[0m [0;36m.m[0m [0;36m.i[0m [0;36m.n[0m [0;36m.:[0m 20    09 [0;36m.&[0m 0A [0;36m.m[0m [0;36m.a[0m [0;36m.x[0m [0;36m.:[0m 20 [0;31m##[0m [1;37m][0m
!

simple |
./hexii -A - |
xcmp 2<<'!'
    0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F

0: .m .i .n .: 20    09 .& 0A .m .a .x .: 20 ## ]
!

# columns
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

# space as hex
simple |
xhexii -h |
xcmp 2<<'!'
    0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F

0: .m .i .n .: 20    09 .& 0A .m .a .x .: 20 ## ]
!

simple |
xhexii -H |
xcmp 2<<'!'
    0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F

0: .m .i .n .: .     09 .& 0A .m .a .x .: .  ## ]
!

simple |
xhexii -hH |
xcmp 2<<'!'
    0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F

0: .m .i .n .: .     09 .& 0A .m .a .x .: .  ## ]
!

simple |
xhexii -Hh |
xcmp 2<<'!'
    0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F

0: .m .i .n .: 20    09 .& 0A .m .a .x .: 20 ## ]
!

simple |
xhexii -q |
xcmp 2<<'!'
    0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F

0: .m .i .n .: 20    09 .& 0A .m .a .x .: 20 ## ]
!

simple |
xhexii -qv |
xcmp 2<<'!'
    0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F

0: .m .i .n .: 20 00 09 .& 0A .m .a .x .: 20 FF ]
!

# suppress nulls
head -c 100 /dev/zero |
xhexii -s |
xcmp 2<<'!'
     0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F

60:             ]
!

head -c 100 /dev/zero |
xhexii -S |
xcmp 2<<'!'
     0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F

00:                                                
10:                                                
20:                                                
30:                                                
40:                                                
50:                                                
60:             ]
!

head -c 100 /dev/zero |
xhexii -sS |
xcmp 2<<'!'
     0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F

00:                                                
10:                                                
20:                                                
30:                                                
40:                                                
50:                                                
60:             ]
!

head -c 100 /dev/zero |
xhexii -Ss |
xcmp 2<<'!'
     0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F

60:             ]
!

simple |
xhexii -v |
xcmp 2<<'!'
    0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F

0: .m .i .n .: 20 00 09 .& 0A .m .a .x .: 20 FF ]
!

simple |
xhexii -vq |
xcmp 2<<'!'
    0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F

0: .m .i .n .: 20    09 .& 0A .m .a .x .: 20 ## ]
!

# hex case
ascii |
xhexii -x |
xcmp 2<<'!'
      0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F

000:    01 02 03 04 05 06 07 08 09 0a 0b 0c 0d 0e 0f
 10: 10 11 12 13 14 15 16 17 18 19 1a 1b 1c 1d 1e 1f
 20: 20 .! ." .# .$ .% .& .' .( .) .* .+ ., .- .. ./
 30: .0 .1 .2 .3 .4 .5 .6 .7 .8 .9 .: .; .< .= .> .?
 40: .@ .A .B .C .D .E .F .G .H .I .J .K .L .M .N .O
 50: .P .Q .R .S .T .U .V .W .X .Y .Z .[ .\ .] .^ ._
 60: .` .a .b .c .d .e .f .g .h .i .j .k .l .m .n .o
 70: .p .q .r .s .t .u .v .w .x .y .z .{ .| .} .~ 7f
 80: 80 81 82 83 84 85 86 87 88 89 8a 8b 8c 8d 8e 8f
 90: 90 91 92 93 94 95 96 97 98 99 9a 9b 9c 9d 9e 9f
 A0: a0 a1 a2 a3 a4 a5 a6 a7 a8 a9 aa ab ac ad ae af
 B0: b0 b1 b2 b3 b4 b5 b6 b7 b8 b9 ba bb bc bd be bf
 C0: c0 c1 c2 c3 c4 c5 c6 c7 c8 c9 ca cb cc cd ce cf
 D0: d0 d1 d2 d3 d4 d5 d6 d7 d8 d9 da db dc dd de df
 E0: e0 e1 e2 e3 e4 e5 e6 e7 e8 e9 ea eb ec ed ee ef
 F0: f0 f1 f2 f3 f4 f5 f6 f7 f8 f9 fa fb fc fd fe ##
100: ]
!

ascii |
xhexii -X |
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

ascii |
xhexii -Xx |
xcmp 2<<'!'
      0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F

000:    01 02 03 04 05 06 07 08 09 0a 0b 0c 0d 0e 0f
 10: 10 11 12 13 14 15 16 17 18 19 1a 1b 1c 1d 1e 1f
 20: 20 .! ." .# .$ .% .& .' .( .) .* .+ ., .- .. ./
 30: .0 .1 .2 .3 .4 .5 .6 .7 .8 .9 .: .; .< .= .> .?
 40: .@ .A .B .C .D .E .F .G .H .I .J .K .L .M .N .O
 50: .P .Q .R .S .T .U .V .W .X .Y .Z .[ .\ .] .^ ._
 60: .` .a .b .c .d .e .f .g .h .i .j .k .l .m .n .o
 70: .p .q .r .s .t .u .v .w .x .y .z .{ .| .} .~ 7f
 80: 80 81 82 83 84 85 86 87 88 89 8a 8b 8c 8d 8e 8f
 90: 90 91 92 93 94 95 96 97 98 99 9a 9b 9c 9d 9e 9f
 A0: a0 a1 a2 a3 a4 a5 a6 a7 a8 a9 aa ab ac ad ae af
 B0: b0 b1 b2 b3 b4 b5 b6 b7 b8 b9 ba bb bc bd be bf
 C0: c0 c1 c2 c3 c4 c5 c6 c7 c8 c9 ca cb cc cd ce cf
 D0: d0 d1 d2 d3 d4 d5 d6 d7 d8 d9 da db dc dd de df
 E0: e0 e1 e2 e3 e4 e5 e6 e7 e8 e9 ea eb ec ed ee ef
 F0: f0 f1 f2 f3 f4 f5 f6 f7 f8 f9 fa fb fc fd fe ##
100: ]
!

ascii |
xhexii -xX |
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

# usage
./hexii 2>&1 |
xcmp 2<<!
usage: ./hexii [-aAhHqsSvxX] [-c num] FILE
       ./hexii -V
!

# -fin-
