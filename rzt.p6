#!/usr/bin/env perl6
use v6;
use JSON::Fast;
use Terminal::ANSIColor;
use Readline;

my Int @version = 1, 2, 1;
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

sub interactive(Str $message) {
    my Readline $readline = Readline.new;
    return $readline.readline(colored($message, "bold cyan"));
}

sub rzt-add(Str %tasks, Str $name, Str $task, Str $file) {
    %tasks{$name} = $task;
    spurt $file, to-json(%tasks);
    say colored("\"$name\"", "italic magenta") ~ " " ~ colored("added!", "bold green");
}

sub rzt-delete(Str %tasks, Str $name, Str $file) {
    if %tasks{$name}:exists {
        %tasks{$name}:delete;
        spurt $file, to-json(%tasks);
        say colored("\"$name\"", "italic magenta") ~ " " ~ colored("deleted!", "bold green");
    } else {
        error "\"$name\" does not exist";
    }
}

sub rzt-copy(Str %tasks, Str $name, Str $task, Str $file) {
    if %tasks{$name}:exists {
        %tasks{$task} = %tasks{$name};
        spurt $file, to-json(%tasks);
        say colored("\"$name\"", "italic magenta") ~ " " ~
            colored("copied to", "bold green") ~ " " ~
            colored("\"$task\"", "italic magenta") ~
            colored("!", "bold green");
    } else {
        error "\"$name\" does not exist"
    }
}

sub rzt-move(Str %tasks, Str $name, Str $task, Str $file) {
    if %tasks{$name}:exists {
        %tasks{$task} = %tasks{$name};
        %tasks{$name}:delete;
        spurt $file, to-json(%tasks);
        say colored("\"$name\"", "italic magenta") ~ " " ~
            colored("moved to", "bold green") ~ " " ~
            colored("\"$task\"", "italic magenta") ~
            colored("!", "bold green");
    } else {
        error "\"$name\" does not exist"
    }
}

multi sub MAIN( #= add, copy, or move
    Str $mode, #= mode
    Str $name, #= name of the task
    Str $task #= contents of the task for add, or destination for copy/move
) {
    given $mode {
        when "add" {
            rzt-add %tasks, $name, $task, $file;
        }
        when "copy" {
            rzt-copy %tasks, $name, $task, $file;
        }
        when "move" {
            rzt-move %tasks, $name, $task, $file;
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
            rzt-delete %tasks, $name, $file;
        }
    }
}

multi sub MAIN( #= list, version, add, delete, copy, or move
    Str $mode #= mode
) {
    given $mode {
        when "list" {
            my Int $i = 0;
            for %tasks.kv -> $key, $value {
                say colored($key, "italic magenta") ~ colored(":", "bold yellow") ~ " " ~ colored($value, "italic magenta");
                $i++;
            }
        }
        when "version" {
            say "rzt v$version";
        }
        when "add" {
            my Str $name = interactive "What is the task called? ";
            my Str $task = interactive "What is the task? ";
            rzt-add %tasks, $name, $task, $file;
        }
        when "delete" {
            my Str $name = interactive "What is the task called? ";
            my Str $task = interactive "What is the task? ";
            rzt-delete %tasks, $name, $file;
        }
        when "copy" {
            my Str $name = interactive "What task do you want to copy? ";
            my Str $task = interactive "What should the copy be called? ";
            rzt-copy %tasks, $name, $task, $file;
        }
        when "move" {
            my Str $name = interactive "What task do you want to move? ";
            my Str $task = interactive "What should the new task be called? ";
            rzt-move %tasks, $name, $task, $file;
        }
    }
}
