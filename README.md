# org-agenda-carlos
carlos customize org agendas for GTD

## key binding

(global-set-key (kbd "<f5>") 'carlos/org-agenda-show)

## org file lists

(setq carlos/org-agenda-file-list '("path/of/orgfile"))

## customize org agenda command

append the customize commands to origin org agendas command, need to set in emacs init stage

(setq org-agenda-custom-commands (append org-agenda-custom-commands org-agenda-custom-commands))


## quick capture note

```
(setq org-capture-templates
      '(
        ("ll" "Leju 日常" entry (file+datetree "path/orgfile/store/note/also/in/carlos/org-genda-file-list")
         "* TODO [#A] [Leju 日常] %?\n:PROPERTIES:\n:CREATED:  %U\n:END:\n")
        ))      
```
