(define-skeleton markdown-skeleton
  "" ""
  (let* ((path (split-string default-directory "/"))
        (directory (nth (- (length path) 2) path)))
    (concat directory "\n"
            (make-string (length directory)
                         ?=) "\n\n"))

  _

  "SYNOPSIS\n"
  "--------\n\n"

  "DESCRIPTION\n"
  "-----------\n\n"

  "AUTHOR\n"
  "------\n\n"

  "COPYRIGHT\n"
  "---------\n\n"

  "Copyright (C) " (format-time-string "%Y") "  Wojciech Siewierski

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.\n"
  )

(define-auto-insert "\\.md$" 'markdown-skeleton)
