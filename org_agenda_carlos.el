;;; -*- lexical-binding: t -*-
(setq org-carlos-agenda-custom-commands
      '(
        ("carlos/org-agenda" "carlos work panel"
         (
          (tags "+UNHOLD+TODO=\"WORKING\"|-HOLD+LejuWork+TODO=\"WORKING\"|+Work+TODO=\"IN-PROGRESS\"|-HOLD+LejuWork+TODO=\"TARGET\""
                (
                 (org-agenda-overriding-header "❖----------------LONG-TREM & Working----------------------❖")
                 (org-agenda-prefix-format "%l%t")
                 (org-agenda-sorting-strategy '(category-keep))
                 (org-agenda-files carlos/org-agenda-file-list)
                 )
                )
          (agenda "schedule"
                  (
                   (org-agenda-overriding-header "❖----------------SCHEDULE----------------------❖")
                   (org-agenda-skip-function '(org-agenda-skip-entry-if 'regexp"* DONE"))
                   (org-agenda-span 1)
                   (org-agenda-start-day "+0d")
                   (org-agenda--show-holidays-birthdays t)
                   (org-agenda-files carlos/org-agenda-file-list)
                   ))
          (tags "-HOLD+LejuWork+TODO=\"TODO\"|-HOLD+LejuWork+TODO=\"WORKING\""
                (
                 (org-agenda-overriding-header "❖----------------TODO lists----------------------❖")
                 (org-agenda-cmp-user-defined 'org-sort-agenda-items-sort-created)
                 (org-agenda-sorting-strategy '(user-defined-up))
                 (org-agenda-files carlos/org-agenda-file-list)
                 (org-agenda-skip-function 'carlos/org-agenda-filter-schedule-todo)
                 (org-agenda-before-sorting-filter-function 'carlos/org-agenda-before-sorting-filter-function)))))))

(defun carlos/org-agenda-filter-schedule-todo ()
  (let ((subtree-end (save-excursion (org-end-of-subtree t))))
    (if (equal nil (org-get-scheduled-time (point)) )
        nil
      subtree-end)))

(defun carlos/org-agenda-before-sorting-filter-function (src-str &optional index)
  "docstring"
  (interactive)
  (setq carlos/debug-text-perporty src-str)
  (concat src-str (or (org-entry-get (get-text-property 0 'org-marker src-str) "CREATED") "unknowtime")  ":")
  )

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
              -1
              ) nil)))))

(defun carlos/org-agenda-show (&optional arg)
  (interactive )
  (progn
    (setq frame-title-format "DashBoard")
    (org-agenda arg "carlos/org-agenda")
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
