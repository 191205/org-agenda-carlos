;;; -*- lexical-binding: t -*-
(setq org-agenda-custom-commands
      '(
        ("carlos" "carlos work panel"
         (
          (tags "+UNHOLD+TODO=\"WORKING\"|-HOLD+LejuWork+TODO=\"WORKING\"|+Work+TODO=\"IN-PROGRESS\"|-HOLD+LejuWork+TODO=\"TARGET\""
                (
                 (org-agenda-overriding-header "❖----------------LONG-TREM & Working----------------------❖")
                 (org-agenda-prefix-format "%l%t")
                 (org-agenda-sorting-strategy '(category-keep))
                 (org-agenda-files carlos/leju-org-agenda-file-list)
                 )
                )
          (agenda "schedule"
                  (
                   (org-agenda-overriding-header "❖----------------SCHEDULE----------------------❖")
                   (org-agenda-skip-function '(org-agenda-skip-entry-if 'regexp"* DONE"))
                   (org-agenda-span 1)
                   (org-agenda-start-day "+0d")
                   (org-agenda--show-holidays-birthdays t)
                   (org-agenda-files carlos/leju-org-agenda-file-list)
                   ))
          (tags "-HOLD+LejuWork+TODO=\"TODO\"|-HOLD+LejuWork+TODO=\"WORKING\""
                (
                 (org-agenda-overriding-header "❖----------------TODO lists----------------------❖")
                 (org-agenda-cmp-user-defined 'org-sort-agenda-items-sort-created)
                 (org-agenda-sorting-strategy '(user-defined-up))
                 (org-agenda-files carlos/leju-org-agenda-file-list)
                 (org-agenda-skip-function 'carlos/org-agenda-filter-schedule-todo)
                 (org-agenda-before-sorting-filter-function 'carlos/org-agenda-before-sorting-filter-function)
                 )
                )
          ))
        ))
(provide 'org_agenda_carlos)
