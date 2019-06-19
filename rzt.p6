#!/usr/bin/env perl6
use v6;
use JSON::Fast;
use Terminal::ANSIColor;

my Int @version = 1, 0, 1;
my Str $version = "@version[0].@version[1].@version[2]";
my Str $file;
if %*ENV<RZT_TASKS_FILE>:exists {
    $file = %*ENV<RZT_TASKS_FILE>;
} else {
    $file = "$*HOME/.rzt/tasks.json";
    unless $file.IO.e {
        mkdir "{%*ENV<HOME>}/.rzt" unless "{%*ENV<HOME>}/.rzt".IO.e;
        spurt $file, '{}';
    }
}
my Str %tasks = from-json(slurp($file)).Array;

multi sub MAIN( #= add
    Str $mode, #= mode
    Str $name, #= name of the task
    Str $content #= contents of the task
) {
    given $mode {
        when "add" {
            %tasks.append($name, $content);
            spurt $file, to-json(%tasks);
            say colored("\"$name\"", "italic magenta") ~ " " ~ colored("added!", "bold green");
        }
    }
}
multi sub MAIN( #= list, or delete
    Str $mode, #= mode
    Str $name #= name of the task
) {
    given $mode {
        when "list" {
            say colored(%tasks{$name}, "italic magenta");
        }
        when "delete" {
            %tasks{$name}:delete;
            spurt $file, to-json(%tasks);
            say colored("\"$name\"", "italic magenta") ~ " " ~ colored("deleted!", "bold green");
        }
    }
}
multi sub MAIN( #= list, or version
    Str $mode #= mode
) {
    given $mode {
        when "list" {
            my Int $i = 0;
            for %tasks.kv -> $key, $value {
                say colored("$key", "italic magenta") ~ colored(":", "bold yellow") ~ " " ~ colored("$value", "italic magenta");
                $i++;
            }
        }
        when "version" {
            say "rzt v$version";
        }
    }
}