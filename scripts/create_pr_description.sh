#!/bin/bash

INPUT="$1"

TICKET=$(printf "%s" "$INPUT" | head -n1 | tr -d '\r')
XML=$(printf "%s" "$INPUT" | tail -n +2)

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
      inTypes=0; members=""; type=""
    }
  '
)

OUTPUT="## List of Changed Components

| Component Type          | Component API Name                 |
|-------------------------|-------------------------------------|
$ROWS

---

## Team Information
- Team: **New Home Build**

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
