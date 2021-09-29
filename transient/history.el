((magit-commit nil)
 (magit-dispatch nil)
 (magit-log
  ("-n256"
   ("--" "scs/web-server/fleet.lisp")
   "--graph" "--decorate")
  ("-n256"
   ("--" "scs/interface/changes.lisp")
   "--graph" "--decorate")
  ("-n256"
   ("--" "scs/interface/export-import-st-days-data.lisp")
   "--graph" "--decorate"))
 (magit-merge
  ("--ff-only")))
