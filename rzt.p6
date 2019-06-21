#!/usr/bin/env perl6
use v6;
use JSON::Fast;
use Terminal::ANSIColor;

my Int @version = 1, 1, 0;
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

sub error(Str $error) {
    $*ERR.say(colored("ERROR: $error", "bold red"));
    exit 1;
}

multi sub MAIN( #= add, copy, or move
    Str $mode, #= mode
    Str $name, #= name of the task
    Str $task #= contents of the task for add, or destination for copy/move
) {
    given $mode {
        when "add" {
            %tasks{$name} = $task;
            spurt $file, to-json(%tasks);
            say colored("\"$name\"", "italic magenta") ~ " " ~ colored("added!", "bold green");
        }
        when "copy" {
            if %tasks{$name}:exists {
                %tasks{$task} = %tasks{$name};
                spurt $file, to-json(%tasks);
            } else {
                error "\"$name\" does not exist"
            }
        }
        when "move" {
            if %tasks{$name}:exists {
                %tasks{$task} = %tasks{$name};
                %tasks{$name}:delete;
                spurt $file, to-json(%tasks);
            } else {
                error "\"$name\" does not exist"
            }
        }
    }
}
multi sub MAIN( #= list, or delete
    Str $mode, #= mode
    Str $name #= name of the task
) {
    given $mode {
        when "list" {
            if %tasks{$name}:exists {
                say colored(%tasks{$name}, "italic magenta");
            } else {
                error "\"$name\" does not exist";
            }
        }
        when "delete" {
            if %tasks{$name}:exists {
                %tasks{$name}:delete;
                spurt $file, to-json(%tasks);
                say colored("\"$name\"", "italic magenta") ~ " " ~ colored("deleted!", "bold green");
            } else {
                error "\"$name\" does not exist";
            }
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
