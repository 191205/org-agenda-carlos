;;; -*- lexical-binding: t -*-

(if (not (boundp 'carlos/agenda_view_span))
    (setq carlos/agenda_view_span 2))

(setq org-carlos-agenda-custom-commands
      '(
        ("carlos/org-personal-agenda" "carlos personal panel"
         (
          (tags "+UNHOLD+TODO=\"WORKING\"|-HOLD+TODO=\"WORKING\""
                ((org-agenda-overriding-header "❖----------------Working----------------------❖")
                 (org-agenda-prefix-format "%l%t")
                 (org-agenda-sorting-strategy '(category-keep))
                 (org-agenda-files carlos/personal-org-agenda-filelist)))
          (agenda "schedule"
                  ((org-agenda-overriding-header "❖----------------SCHEDULE----------------------❖")
                   (org-agenda-skip-function '(org-agenda-skip-entry-if 'regexp ".* TARGET .*\\|.* WORKING .*\\|.* IN-PROGRESS .*"))
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
                 ))))
        ("carlos/org-all-leju-todo" "carlos org all todo to pick"
         ((alltodo ""
                ((org-agenda-overriding-header "❖------------------------- TODO lists ----------------------------------❖")
                 (org-agenda-cmp-user-defined 'org-agenda-sort-all-todo)
                 (org-agenda-sorting-strategy '(user-defined-up))
                 (org-agenda-files (append  carlos/org-agenda-file-list ))
                 (org-agenda-skip-function 'carlos/org-agenda-filter-schedule-todo)))))
        ("carlos/org-all-personal-todo" "carlos org all todo to pick"
         ((alltodo ""
                ((org-agenda-overriding-header "❖------------------------- Personal All TODO lists ----------------------------------❖")
                 (org-agenda-cmp-user-defined 'org-agenda-sort-all-todo)
                 (org-agenda-sorting-strategy '(user-defined-up))
                 (org-agenda-files (append carlos/personal-org-agenda-filelist))
                 (org-agenda-skip-function 'carlos/org-agenda-filter-schedule-todo)))))
        ("carlos/org-agenda" "carlos work panel"
         (
          (tags "+UNHOLD+TODO=\"WORKING\"|-HOLD+TODO=\"WORKING\""
                ((org-agenda-overriding-header "❖----------------Working Panel----------------------❖")
                 (org-agenda-prefix-format "%l%t")
                 (org-agenda-sorting-strategy '(category-keep))
                 (org-agenda-files carlos/org-agenda-file-list)))
          (agenda "schedule"
                  ((org-agenda-overriding-header "❖----------------SCHEDULE----------------------❖")
                   (org-agenda-skip-function '(org-agenda-skip-entry-if 'regexp  ".* TARGET .*\\|.* WORKING .*\\|.* IN-PROGRESS .*" ))
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
                 ))))
        ("carlos/did-today" "carlos Did task panel"
         ((todo "DONE"
                ((org-agenda-overriding-header "❖------------------------- DONE lists ----------------------------------❖")
                 (org-agenda-files '("/Users/carlos/Documents/leju/leju_prj/LejuTodo.org" "/Users/carlos/Documents/leju/leju_prj/personal.org"))
                 (org-agenda-cmp-user-defined 'org-sort-done-entries)
                 (org-agenda-sorting-strategy '(user-defined-up))
                 (org-agenda-skip-function 'org-agenda-skip-if-not-Updated-today)))))))

(defun org-agenda-skip-if-not-Updated-today ()
  "If this function returns nil, the current match should not be skipped.
Otherwise, the function must return a position from where the search
should be continued."
  (ignore-errors
    (let* ((subtree-end (save-excursion (progn
                                        (org-next-visible-heading 1)
                                        (point)
                                        )))
          (now (float-time (carlos/parse-time (format-time-string "%Y-%m-%d"))))
          (updated_at_str (org-entry-get (point) org-expiry-updated-property-name))
          (updated_at (float-time (carlos/parse-time updated_at_str)))
          )
      (if (or (> now updated_at) (equal updated_at_str nil))
          (progn
            subtree-end)
        (progn
          nil)))))

(defun org-agenda-skip-if-scheduled-or-low-priority ()
  "If this function returns nil, the current match should not be skipped.
Otherwise, the function must return a position from where the search
should be continued."
  (ignore-errors
    (let ((subtree-end (save-excursion (progn
                                        (org-next-visible-heading 1)
                                        (point)
                                        )))
          (scheduled-time (org-entry-get nil "SCHEDULED"))
          (priority (org-entry-get nil "PRIORITY"))
          (todo-state (org-get-todo-state))
          (org-heading (org-get-heading))
          )
      ;; (message "heading:%s scheduled-time:%s priority:%s todo-state:%s" org-heading scheduled-time priority todo-state)
      (if (or scheduled-time (and (not (string-equal "A" priority))
                                  (not (string-equal "B" priority)))
              (or (string-equal "IN-PROGRESS" todo-state)
                  (string-equal "TARGET" todo-state)
                  (string-equal "WORKING" todo-state)))
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

(defun org-agenda-sort-all-todo (a b)
  (let* (
        (a-pos (get-text-property 0 'org-marker a))
        (b-pos (get-text-property 0 'org-marker b))
        (a-todo (org-entry-get a-pos "TODO"))
        (b-todo (org-entry-get b-pos "TODO"))
        (a-time-adjust-days 0)
        (b-time-adjust-days 0)
        )
    (let ((a-priority  (- 255 (string-to-char (org-entry-get a-pos "PRIORITY"))))
          (b-priority (- 255 (string-to-char (org-entry-get b-pos "PRIORITY"))))
          )
      (if (string-match "WORKING" a-todo)
          (progn
            ;; (setq a-priority (- 255 (string-to-char "B")))
            (setq a-time-adjust-days  -3650)))
      (if (string-match "WORKING" b-todo)
          (progn
            ;; (setq b-priority (- 255 (string-to-char "B")))
            (setq b-time-adjust-days -3650)))
      (let ((a-time (+ a-time-adjust-days (time-to-number-of-days (carlos/org-agenda-parsetime (or (org-entry-get a-pos org-expiry-updated-property-name) (org-entry-get a-pos "CREATED") "[2016-01-02 Sun 00:01]")))))
            (b-time (+ b-time-adjust-days (time-to-number-of-days (carlos/org-agenda-parsetime (or (org-entry-get b-pos org-expiry-updated-property-name) (org-entry-get b-pos "CREATED") "[2016-01-02 Sun 00:01]"))))))
        (cond
         ((equal a-priority b-priority) (progn
                                          (if (time-less-p a-time b-time)
                                              -1
                                            1)))
         ((> a-priority b-priority) -1)
         ((< a-priority b-priority) 1)
         (t nil))))))



(defun org-sort-agenda-items-sort-created (a b)
  (let (
        (a-pos (get-text-property 0 'org-marker a))
        (b-pos (get-text-property 0 'org-marker b))
        )
    (let ((a-priority  (- 255 (string-to-char (org-entry-get a-pos "PRIORITY"))))
          (b-priority (- 255 (string-to-char (org-entry-get b-pos "PRIORITY")))))
      (let ((a-time (+ 0 (time-to-number-of-days (carlos/org-agenda-parsetime (or (org-entry-get a-pos org-expiry-updated-property-name) (org-entry-get a-pos "CREATED") "[1970-01-02 Sun 00:01]")))))
            (b-time (+ 0 (time-to-number-of-days (carlos/org-agenda-parsetime (or (org-entry-get b-pos org-expiry-updated-property-name) (org-entry-get b-pos "CREATED") "[1970-01-02 Sun 00:01]"))))))
        ;; (if (string-match "D" (org-entry-get a-pos "PRIORITY"))
        ;;     (message "Debug sort agenda PRIORITY is:%sa a is:%s" (org-entry-get a-pos "PRIORITY") a))
        (cond
         ((equal a-priority b-priority) (progn
                                          (if (time-less-p a-time b-time)
                                              -1
                                            1)))
         ((> a-priority b-priority) -1)
         ((< a-priority b-priority) 1)
         (t nil))))))

(defun carlos/org-agenda-leju-show (&optional arg)
  (interactive )
  (progn
    (setq frame-title-format "DashBoard")
    (org-agenda arg "carlos/org-agenda")
    (toggle-truncate-lines nil)
    ;; (bh/org-agenda-to-appt)
    (when (< 1 (length (window-list)))
      (delete-other-windows))))

(defun carlos/org-all-todo-agenda-show (&optional arg)
  (interactive )
  (progn
    (message "Collecting Todo..." )
    (setq frame-title-format "carlos/org-all-todo")
    (if (or carlos/org-agenda-force-personal (and (carlos/is-home-network) (not carlos/org-agenda-force-leju)))
        (org-agenda arg "carlos/org-all-personal-todo")
      (org-agenda arg "carlos/org-all-leju-todo"))
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
