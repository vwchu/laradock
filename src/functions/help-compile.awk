#!/usr/bin/env awk

function ltrim(s) { sub(/^[ \t\r\n]+/, "", s); return s }
function rtrim(s) { sub(/[ \t\r\n]+$/, "", s); return s }
function trim(s)  { return rtrim(ltrim(s)); }
function endblock() {
  if (output == 1) {
    output = 0;
    print last "')";
  }
}

BEGIN {
  output = 0;
  last = "";
}

toupper($0) ~ /^(DESCRIPTION|ARGUMENT|OPTION|ENVIRONMENT|OPTIONBREAK).*$/ {
  endblock();

  if (toupper($0) ~ /^DESCRIPTION/) {
    command = "set_description"
  } else if (toupper($0) ~ /^ARGUMENT/) {
    command = "set_argument"
  } else if (toupper($0) ~ /^OPTIONBREAK/) {
    command = "set_option_break"
  } else if (toupper($0) ~ /^OPTION/) {
    command = "set_option"
  } else if (toupper($0) ~ /^ENVIRONMENT/) {
    command = "set_environment"
  }

  if (match($0, /^(DESCRIPTION|ARGUMENT|OPTION|OPTIONBREAK|ENVIRONMENT)[ ]*\((.*)\)$/, matches)) {
    printf "%s %s < <(echo '", command, trim(matches[2]);
  } else {
    printf "%s < <(echo '", command;
  }

  output = 1;
  last = "";
  next
}

output {
  if (length(last) > 0) {
    sub(/$/, " ", last);
  }
  printf "%s", last;
  last = trim($0);
}

END {
  endblock();
}
