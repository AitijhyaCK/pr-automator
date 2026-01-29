#!/bin/bash

# =========================
# Input handling
# =========================
if [ -n "$1" ]; then
  INPUT="$1"
else
  INPUT="$(cat)"
fi

TICKET=$(printf "%s" "$INPUT" | sed -n '1p' | tr -d '\r')
TEAM=$(printf "%s" "$INPUT" | sed -n '2p' | tr -d '\r')
XML=$(printf "%s" "$INPUT" | sed '1,2d')

# Fallback team
if [ -z "$TEAM" ]; then
  TEAM="New Home Build"
fi

# =========================
# UI helpers
# =========================
LINE="────────────────────────────────────────"
BLUE="\033[0;34m"
GREEN="\033[0;32m"
DIM="\033[2m"
RESET="\033[0m"

info() { printf " • %s\n" "$1"; }
ok()   { printf " ${GREEN}✔${RESET} %s\n" "$1"; }

echo
echo -e "${DIM}${LINE}${RESET}"
echo -e "${BLUE} PR Automator • Generate PR Description${RESET}"
echo -e "${DIM}${LINE}${RESET}"
echo

info "Ticket : PBD-$TICKET"
info "Team   : $TEAM"
echo

info "Processing package.xml…"

# =========================
# XML parsing
# =========================
ROWS=$(
  printf "%s\n" "$XML" | awk '
    /<types>/ { members=""; type=""; inTypes=1; next }
    inTypes && /<members>/ {
      gsub(/.*<members>|<\/members>.*/,"",$0)
      members = (members ? members" " : "") "`"$0"`"
      next
    }
    inTypes && /<name>/ {
      gsub(/.*<name>|<\/name>.*/,"",$0)
      type=$0
      next
    }
    inTypes && /<\/types>/ {
      comp=type
      if (type=="CustomField") comp="Field"
      else if (type=="FlexiPage") comp="Lightning Record Page"
      else if (type=="PermissionSet") comp="Permission Set"
      else if (type=="ApexClass") comp="Apex Class"
      else if (type=="LightningComponentBundle") comp="LWC"
      else if (type=="Flow") comp="Flow"
      else if (type=="ValidationRule") comp="Validation Rule"
      else if (type=="UserAccessPolicy") comp="User Access Policy"
      else if (type=="RecordType") comp="Record Type"
      else if (type=="ReportType") comp="Report Type"
      printf("| %-25s | %s |\n", comp, members)
      inTypes=0
    }
  '
)

ok "Components parsed"

# =========================
# PR description output
# =========================
OUTPUT="## List of Changed Components

| Component Type          | Component API Name                 |
|-------------------------|-------------------------------------|
$ROWS

---

## Team Information
- Team: **$TEAM**

---

**Org / Environment used for testing:**  

- [X] Dev  
- [ ] QA  
- [ ] UAT  

---

## Linked Work Items
- Jira Ticket: [PBD-$TICKET](https://homeenergysolutions.atlassian.net/browse/PBD-$TICKET)
"

printf "%b" "$OUTPUT" | pbcopy

ok "PR description copied to clipboard"
echo
echo -e "${GREEN} Done 🎉${RESET}"
echo -e "${DIM}${LINE}${RESET}"
echo
