;;; -*- lexical-binding: t -*-

(if (not (boundp 'carlos/agenda_view_span))
    (setq carlos/agenda_view_span 2))

(setq org-carlos-agenda-custom-commands
      '(
        ("carlos/org-personal-agenda" "carlos personal panel"
         (
          (tags "+UNHOLD+TODO=\"WORKING\"|-HOLD+TODO=\"WORKING\"|-HOLD+TODO=\"IN-PROGRESS\"|-HOLD+TODO=\"TARGET\""
                ((org-agenda-overriding-header "❖----------------LONG-TREM & Working----------------------❖")
                 (org-agenda-prefix-format "%l%t") 
                 (org-agenda-sorting-strategy '(category-keep))
                 (org-agenda-files carlos/personal-org-agenda-filelist)))
          (agenda "schedule"
                  ((org-agenda-overriding-header "❖----------------SCHEDULE----------------------❖")
                   (org-agenda-skip-function '(org-agenda-skip-entry-if 'regexp"* DONE"))
                   (org-agenda-span (or carlos/agenda_view_span 2))
                   (org-agenda-start-day "+0d")
                   (org-agenda-start-on-weekday nil)
                   (org-agenda--show-holidays-birthdays t)
                   (org-agenda-entry-types '(:scheduled :deadline))
                   (org-agenda-files carlos/personal-org-agenda-filelist)))
          (alltodo  ""
                ((org-agenda-overriding-header "❖------------------------- TODO lists ----------------------------------❖")
                 (org-agenda-cmp-user-defined 'org-sort-agenda-items-sort-created)
                 (org-agenda-sorting-strategy '(user-defined-up))
                 (org-agenda-files carlos/personal-org-agenda-filelist)
                 (org-agenda-skip-function 'org-agenda-skip-if-scheduled-or-low-priority)
                 ;; (org-agenda-skip-entry-if '(scheduled deadline))
                 ;; (org-agenda-before-sorting-filter-function 'carlos/org-agenda-before-sorting-filter-function)
                 ))))
        ("carlos/org-all-todo" "carlos org all todo to pick"
         ((alltodo ""
                ((org-agenda-overriding-header "❖------------------------- TODO lists ----------------------------------❖")
                 (org-agenda-cmp-user-defined 'org-sort-agenda-items-sort-created)
                 (org-agenda-sorting-strategy '(user-defined-up))
                 (org-agenda-files (append  carlos/org-agenda-file-list carlos/personal-org-agenda-filelist))
                 (org-agenda-skip-function 'carlos/org-agenda-filter-schedule-todo)))))
        ("carlos/org-agenda" "carlos work panel"
         (
          (tags "+UNHOLD+TODO=\"WORKING\"|-HOLD+TODO=\"WORKING\"|-HOLD+TODO=\"IN-PROGRESS\"|-HOLD+TODO=\"TARGET\""
                ((org-agenda-overriding-header "❖----------------LONG-TREM & Working----------------------❖")
                 (org-agenda-prefix-format "%l%t")
                 (org-agenda-sorting-strategy '(category-keep))
                 (org-agenda-files carlos/org-agenda-file-list)))
          (agenda "schedule"
                  ((org-agenda-overriding-header "❖----------------SCHEDULE----------------------❖")
                   (org-agenda-skip-function '(org-agenda-skip-entry-if 'regexp"* DONE"))
                   (org-agenda-span (or carlos/agenda_view_span 2))
                   (org-agenda-start-day "+0d")
                   (org-agenda-start-on-weekday nil)
                   (org-agenda--show-holidays-birthdays t)
                   (org-agenda-entry-types '(:scheduled :deadline))
                   (org-agenda-files carlos/org-agenda-file-list)))
          (alltodo  ""
                ((org-agenda-overriding-header "❖------------------------- TODO lists ----------------------------------❖")
                 (org-agenda-cmp-user-defined 'org-sort-agenda-items-sort-created)
                 (org-agenda-sorting-strategy '(user-defined-up))
                 (org-agenda-files carlos/org-agenda-file-list)
                 (org-agenda-skip-function 'org-agenda-skip-if-scheduled-or-low-priority)
                 ;; (org-agenda-skip-entry-if '(scheduled deadline))
                 ;; (org-agenda-skip-entry-if 'scheduled)
                 ;; (org-agenda-before-sorting-filter-function 'carlos/org-agenda-before-sorting-filter-function)
                 ))))))

(defun org-agenda-skip-if-scheduled-or-low-priority ()
  "If this function returns nil, the current match should not be skipped.
Otherwise, the function must return a position from where the search
should be continued."
  (ignore-errors
    (let ((subtree-end (save-excursion (org-end-of-subtree t)))
          (scheduled-time (org-entry-get nil "SCHEDULED"))
          (priority (org-entry-get nil "PRIORITY")))
      (if (or scheduled-time (and (not (string-equal "A" priority))
                                 (not (string-equal "B" priority))))
          subtree-end
        nil))))

(defun carlos/org-agenda-filter-schedule-todo ()
  (ignore-errors
    (let ((subtree-end (save-excursion (org-end-of-subtree t)))
          (scheduled-time (org-entry-get nil "SCHEDULED"))
          )
      (if (or scheduled-time )
          subtree-end
        nil))))

(defun carlos/org-agenda-before-sorting-filter-function (src-str &optional index)
  "docstring"
  (interactive)
  (setq carlos/debug-text-perporty src-str)
  (let ((pom (get-text-property 0 'org-marker src-str)))
    (let ((scheduled (org-entry-get pom "SCHEDULED")))
      (concat src-str (or (org-entry-get pom "CREATED") "unknowtime") (and scheduled (concat " S->" scheduled )) ":"))))

(defun org-sort-agenda-items-sort-created (a b)
  (let (
        (a-pos (get-text-property 0 'org-marker a))
        (b-pos (get-text-property 0 'org-marker b))
        )
    (let ((a-priority (* (- 255 (string-to-char (org-entry-get a-pos "PRIORITY"))) 100000))
          (b-priority (* (- 255 (string-to-char (org-entry-get b-pos "PRIORITY"))) 100000)))
      (let ((a-time (+ a-priority (time-to-number-of-days (carlos/org-agenda-parsetime (or (org-entry-get a-pos "CREATED") "[1970-01-02 Sun 00:01]")))))
            (b-time (+ b-priority (time-to-number-of-days (carlos/org-agenda-parsetime (or (org-entry-get b-pos "CREATED") "[1970-01-02 Sun 00:01]"))))))
        (if (time-less-p b-time a-time)
            (progn
              -1)
          nil)))))

(defun carlos/org-agenda-show (&optional arg)
  (interactive )
  (progn
    (setq frame-title-format "DashBoard")
    (org-agenda arg "carlos/org-agenda")
    (toggle-truncate-lines nil)
    (when (< 1 (length (window-list)))
      (delete-other-windows))))

(defun carlos/org-all-todo-agenda-show (&optional arg)
  (interactive )
  (progn
    (setq frame-title-format "carlos/org-all-todo")
    (org-agenda arg "carlos/org-all-todo")
    (toggle-truncate-lines nil)
    (when (< 1 (length (window-list)))
      (delete-other-windows))))


(defun carlos/org-personal-agenda-show (&optional arg)
  (interactive )
  (progn
    (setq frame-title-format "Personal DashBoard")
    (org-agenda arg "carlos/org-personal-agenda")
    (toggle-truncate-lines nil)
    (when (< 1 (length (window-list)))
      (delete-other-windows))))


(defun carlos/org-agenda-parsetime (timestr)
  (let ((time1 (parse-time-string (or  timestr (format-time-string "%Y-%m-%d")))))
    (encode-time (or (nth 0 time1) 0) (or (nth 1 time1) 0) (or (nth 2 time1) 0) (nth 3 time1) (nth 4 time1) (nth 5 time1))))

(defun carlos/insert-heading-created-timestamp ()
  (save-excursion
    (org-return)
    (org-cycle)
    (if (and (boundp 'carlos/autoExpiry) carlos/autoExpiry)
        t
      (org-expiry-insert-created))))
(add-hook 'org-insert-heading-hook 'carlos/insert-heading-created-timestamp)

(provide 'org_agenda_carlos)
