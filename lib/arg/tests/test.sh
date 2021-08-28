#! /bin/sh
#
# Test various argument combinations; arg permutations generated with:
#
# ```py
# from itertools import permutations
#
# arg = ["-", "--", "-b", "-f", "-f x", "arg"]
#
# print('    "" \\')
# for len in range(1, 4):
#     for each in permutations(arg, len):
#         print(f'    "{" ".join(each)}" \\')
#
# arg = ["--", "---", "--b", "--f", "--f x", "arg"]
#
# print('    "" \\')
# for len in range(1, 3):
#     for each in permutations(arg, len):
#         print(f'    "{" ".join(each)}" \\')
# ```
#
# Some variations have been manually added to catch the odd corner case.

set -e

retval=0
fin() { exit $retval; }
trap fin EXIT

run() {
    printf "% 16s: " "'$*'"
    ./prog $*
}

for t in test_argv0_set test_argv0_unset
do
    printf .
    ./$t 2> /dev/null ||
    {
        echo "FAIL: $t"
        retval=1
    }
done

# prog
while read -r
do
    printf .
    args=$(echo "$REPLY" | cut -d"'" -f2)
    [ "$REPLY" = "$(run "$args")" ] ||
    {
       echo "FAIL: '$REPLY'"
       retval=1
    }
done <<!
              '': ./prog 0 args:
             '-': ./prog 1 args: '-'
            '--': ./prog 0 args:
            '-b': ./prog -b 0 args:
            '-f': ./prog -f(no arg) 0 args:
           '-bf': ./prog -b -f(no arg) 0 args:
           '-fb': ./prog -f(b) 0 args:
           '-ff': ./prog -f(f) 0 args:
          '-f x': ./prog -f(x) 0 args:
           'arg': ./prog 1 args: 'arg'
          '- --': ./prog 2 args: '-' '--'
          '- -b': ./prog 2 args: '-' '-b'
          '- -f': ./prog 2 args: '-' '-f'
        '- -f x': ./prog 3 args: '-' '-f' 'x'
         '- arg': ./prog 2 args: '-' 'arg'
          '-- -': ./prog 1 args: '-'
         '-- -b': ./prog 1 args: '-b'
         '-- -f': ./prog 1 args: '-f'
       '-- -f x': ./prog 2 args: '-f' 'x'
        '-- arg': ./prog 1 args: 'arg'
          '-b -': ./prog -b 1 args: '-'
         '-b --': ./prog -b 0 args:
         '-b -f': ./prog -b -f(no arg) 0 args:
       '-b -f x': ./prog -b -f(x) 0 args:
        '-b arg': ./prog -b 1 args: 'arg'
          '-f -': ./prog -f(-) 0 args:
         '-f --': ./prog -f(--) 0 args:
         '-f -b': ./prog -f(-b) 0 args:
       '-f -f x': ./prog -f(-f) 1 args: 'x'
        '-f arg': ./prog -f(arg) 0 args:
        '-f x -': ./prog -f(x) 1 args: '-'
       '-f x --': ./prog -f(x) 0 args:
       '-f x -b': ./prog -f(x) -b 0 args:
       '-f x -f': ./prog -f(x) -f(no arg) 0 args:
      '-f x arg': ./prog -f(x) 1 args: 'arg'
         'arg -': ./prog 2 args: 'arg' '-'
        'arg --': ./prog 2 args: 'arg' '--'
        'arg -b': ./prog 2 args: 'arg' '-b'
        'arg -f': ./prog 2 args: 'arg' '-f'
      'arg -f x': ./prog 3 args: 'arg' '-f' 'x'
       '- -- -b': ./prog 3 args: '-' '--' '-b'
       '- -- -f': ./prog 3 args: '-' '--' '-f'
     '- -- -f x': ./prog 4 args: '-' '--' '-f' 'x'
      '- -- arg': ./prog 3 args: '-' '--' 'arg'
       '- -b --': ./prog 3 args: '-' '-b' '--'
       '- -b -f': ./prog 3 args: '-' '-b' '-f'
     '- -b -f x': ./prog 4 args: '-' '-b' '-f' 'x'
      '- -b arg': ./prog 3 args: '-' '-b' 'arg'
       '- -f --': ./prog 3 args: '-' '-f' '--'
       '- -f -b': ./prog 3 args: '-' '-f' '-b'
     '- -f -f x': ./prog 4 args: '-' '-f' '-f' 'x'
      '- -f arg': ./prog 3 args: '-' '-f' 'arg'
     '- -f x --': ./prog 4 args: '-' '-f' 'x' '--'
     '- -f x -b': ./prog 4 args: '-' '-f' 'x' '-b'
     '- -f x -f': ./prog 4 args: '-' '-f' 'x' '-f'
    '- -f x arg': ./prog 4 args: '-' '-f' 'x' 'arg'
      '- arg --': ./prog 3 args: '-' 'arg' '--'
      '- arg -b': ./prog 3 args: '-' 'arg' '-b'
      '- arg -f': ./prog 3 args: '-' 'arg' '-f'
    '- arg -f x': ./prog 4 args: '-' 'arg' '-f' 'x'
       '-- - -b': ./prog 2 args: '-' '-b'
       '-- - -f': ./prog 2 args: '-' '-f'
     '-- - -f x': ./prog 3 args: '-' '-f' 'x'
      '-- - arg': ./prog 2 args: '-' 'arg'
       '-- -b -': ./prog 2 args: '-b' '-'
      '-- -b -f': ./prog 2 args: '-b' '-f'
    '-- -b -f x': ./prog 3 args: '-b' '-f' 'x'
     '-- -b arg': ./prog 2 args: '-b' 'arg'
       '-- -f -': ./prog 2 args: '-f' '-'
      '-- -f -b': ./prog 2 args: '-f' '-b'
    '-- -f -f x': ./prog 3 args: '-f' '-f' 'x'
     '-- -f arg': ./prog 2 args: '-f' 'arg'
     '-- -f x -': ./prog 3 args: '-f' 'x' '-'
    '-- -f x -b': ./prog 3 args: '-f' 'x' '-b'
    '-- -f x -f': ./prog 3 args: '-f' 'x' '-f'
   '-- -f x arg': ./prog 3 args: '-f' 'x' 'arg'
      '-- arg -': ./prog 2 args: 'arg' '-'
     '-- arg -b': ./prog 2 args: 'arg' '-b'
     '-- arg -f': ./prog 2 args: 'arg' '-f'
   '-- arg -f x': ./prog 3 args: 'arg' '-f' 'x'
       '-b - --': ./prog -b 2 args: '-' '--'
       '-b - -f': ./prog -b 2 args: '-' '-f'
     '-b - -f x': ./prog -b 3 args: '-' '-f' 'x'
      '-b - arg': ./prog -b 2 args: '-' 'arg'
       '-b -- -': ./prog -b 1 args: '-'
      '-b -- -f': ./prog -b 1 args: '-f'
    '-b -- -f x': ./prog -b 2 args: '-f' 'x'
     '-b -- arg': ./prog -b 1 args: 'arg'
       '-b -f -': ./prog -b -f(-) 0 args:
      '-b -f --': ./prog -b -f(--) 0 args:
    '-b -f -f x': ./prog -b -f(-f) 1 args: 'x'
     '-b -f arg': ./prog -b -f(arg) 0 args:
     '-b -f x -': ./prog -b -f(x) 1 args: '-'
    '-b -f x --': ./prog -b -f(x) 0 args:
    '-b -f x -f': ./prog -b -f(x) -f(no arg) 0 args:
   '-b -f x arg': ./prog -b -f(x) 1 args: 'arg'
      '-b arg -': ./prog -b 2 args: 'arg' '-'
     '-b arg --': ./prog -b 2 args: 'arg' '--'
     '-b arg -f': ./prog -b 2 args: 'arg' '-f'
   '-b arg -f x': ./prog -b 3 args: 'arg' '-f' 'x'
       '-f - --': ./prog -f(-) 0 args:
       '-f - -b': ./prog -f(-) -b 0 args:
     '-f - -f x': ./prog -f(-) -f(x) 0 args:
      '-f - arg': ./prog -f(-) 1 args: 'arg'
       '-f -- -': ./prog -f(--) 1 args: '-'
      '-f -- -b': ./prog -f(--) -b 0 args:
    '-f -- -f x': ./prog -f(--) -f(x) 0 args:
     '-f -- arg': ./prog -f(--) 1 args: 'arg'
       '-f -b -': ./prog -f(-b) 1 args: '-'
      '-f -b --': ./prog -f(-b) 0 args:
    '-f -b -f x': ./prog -f(-b) -f(x) 0 args:
     '-f -b arg': ./prog -f(-b) 1 args: 'arg'
     '-f -f x -': ./prog -f(-f) 2 args: 'x' '-'
    '-f -f x --': ./prog -f(-f) 2 args: 'x' '--'
    '-f -f x -b': ./prog -f(-f) 2 args: 'x' '-b'
   '-f -f x arg': ./prog -f(-f) 2 args: 'x' 'arg'
      '-f arg -': ./prog -f(arg) 1 args: '-'
     '-f arg --': ./prog -f(arg) 0 args:
     '-f arg -b': ./prog -f(arg) -b 0 args:
   '-f arg -f x': ./prog -f(arg) -f(x) 0 args:
     '-f x - --': ./prog -f(x) 2 args: '-' '--'
     '-f x - -b': ./prog -f(x) 2 args: '-' '-b'
     '-f x - -f': ./prog -f(x) 2 args: '-' '-f'
    '-f x - arg': ./prog -f(x) 2 args: '-' 'arg'
     '-f x -- -': ./prog -f(x) 1 args: '-'
    '-f x -- -b': ./prog -f(x) 1 args: '-b'
    '-f x -- -f': ./prog -f(x) 1 args: '-f'
   '-f x -- arg': ./prog -f(x) 1 args: 'arg'
     '-f x -b -': ./prog -f(x) -b 1 args: '-'
    '-f x -b --': ./prog -f(x) -b 0 args:
    '-f x -b -f': ./prog -f(x) -b -f(no arg) 0 args:
   '-f x -b arg': ./prog -f(x) -b 1 args: 'arg'
     '-f x -f -': ./prog -f(x) -f(-) 0 args:
    '-f x -f --': ./prog -f(x) -f(--) 0 args:
    '-f x -f -b': ./prog -f(x) -f(-b) 0 args:
   '-f x -f arg': ./prog -f(x) -f(arg) 0 args:
    '-f x arg -': ./prog -f(x) 2 args: 'arg' '-'
   '-f x arg --': ./prog -f(x) 2 args: 'arg' '--'
   '-f x arg -b': ./prog -f(x) 2 args: 'arg' '-b'
   '-f x arg -f': ./prog -f(x) 2 args: 'arg' '-f'
      'arg - --': ./prog 3 args: 'arg' '-' '--'
      'arg - -b': ./prog 3 args: 'arg' '-' '-b'
      'arg - -f': ./prog 3 args: 'arg' '-' '-f'
    'arg - -f x': ./prog 4 args: 'arg' '-' '-f' 'x'
      'arg -- -': ./prog 3 args: 'arg' '--' '-'
     'arg -- -b': ./prog 3 args: 'arg' '--' '-b'
     'arg -- -f': ./prog 3 args: 'arg' '--' '-f'
   'arg -- -f x': ./prog 4 args: 'arg' '--' '-f' 'x'
      'arg -b -': ./prog 3 args: 'arg' '-b' '-'
     'arg -b --': ./prog 3 args: 'arg' '-b' '--'
     'arg -b -f': ./prog 3 args: 'arg' '-b' '-f'
   'arg -b -f x': ./prog 4 args: 'arg' '-b' '-f' 'x'
      'arg -f -': ./prog 3 args: 'arg' '-f' '-'
     'arg -f --': ./prog 3 args: 'arg' '-f' '--'
     'arg -f -b': ./prog 3 args: 'arg' '-f' '-b'
   'arg -f -f x': ./prog 4 args: 'arg' '-f' '-f' 'x'
    'arg -f x -': ./prog 4 args: 'arg' '-f' 'x' '-'
   'arg -f x --': ./prog 4 args: 'arg' '-f' 'x' '--'
   'arg -f x -b': ./prog 4 args: 'arg' '-f' 'x' '-b'
   'arg -f x -f': ./prog 4 args: 'arg' '-f' 'x' '-f'
              '': ./prog 0 args:
           '---': ./prog badflag('-') badflag('-') 0 args:
           '--b': ./prog badflag('-') -b 0 args:
           '--f': ./prog badflag('-') -f(no arg) 0 args:
         '--f x': ./prog badflag('-') -f(x) 0 args:
        '--- --': ./prog badflag('-') badflag('-') 0 args:
       '--- --b': ./prog badflag('-') badflag('-') badflag('-') -b 0 args:
       '--- --f': ./prog badflag('-') badflag('-') badflag('-') -f(no arg) 0 args:
     '--- --f x': ./prog badflag('-') badflag('-') badflag('-') -f(x) 0 args:
       '--- arg': ./prog badflag('-') badflag('-') 1 args: 'arg'
        '--b --': ./prog badflag('-') -b 0 args:
       '--b ---': ./prog badflag('-') -b badflag('-') badflag('-') 0 args:
       '--b --f': ./prog badflag('-') -b badflag('-') -f(no arg) 0 args:
     '--b --f x': ./prog badflag('-') -b badflag('-') -f(x) 0 args:
       '--b arg': ./prog badflag('-') -b 1 args: 'arg'
        '--f --': ./prog badflag('-') -f(--) 0 args:
       '--f ---': ./prog badflag('-') -f(---) 0 args:
       '--f --b': ./prog badflag('-') -f(--b) 0 args:
     '--f --f x': ./prog badflag('-') -f(--f) 1 args: 'x'
       '--f arg': ./prog badflag('-') -f(arg) 0 args:
      '--f x --': ./prog badflag('-') -f(x) 0 args:
     '--f x ---': ./prog badflag('-') -f(x) badflag('-') badflag('-') 0 args:
     '--f x --b': ./prog badflag('-') -f(x) badflag('-') -b 0 args:
     '--f x --f': ./prog badflag('-') -f(x) badflag('-') -f(no arg) 0 args:
     '--f x arg': ./prog badflag('-') -f(x) 1 args: 'arg'
!

# -fin-
