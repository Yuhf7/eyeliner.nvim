;; [on-key.fnl]
;; On-keypress mode

(local {: get-locations} (require :eyeliner.liner))
(local {: opts} (require :eyeliner.config))
(local {: ns-id : clear-eyeliner : apply-eyeliner : dim} (require :eyeliner.shared))
(local utils (require :eyeliner.utils))
(local {: iter} utils)

;; Returns the function that will run when the key is pressed
(fn handle-keypress [key]
  ;; Main function that is run when "f", "F", "t", "T" is pressed
  (fn on-key []
    (let [line (utils.get-current-line)
          [y x] (utils.get-cursor)
          dir (if (or (= key "f") (= key "t")) :right :left)
          to-apply (get-locations line x dir)]
      ;; Apply eyeliner right after pressing key
      (if opts.dim (dim y x dir))
      (apply-eyeliner y to-apply)
      ;; Draw fake cursor, since getcharstr() will move the real cursor away
      (utils.add-hl ns-id "Cursor" x)
      (vim.cmd ":redraw") ; :redraw to show Cursor highlight
      ;; Simulate normal "f" process
      (let [char (vim.fn.getcharstr)]
        (clear-eyeliner y)
        (.. key char))))

  on-key)

(fn enable []
  (if opts.debug (vim.notify "On-keypress mode enabled"))
  (each [_ key (ipairs ["f" "F" "t" "T"])]
    (vim.keymap.set ["n" "x" "o"]
                    key
                    (handle-keypress key)
                    {:expr true})))

(fn remove-keybinds []
  (each [_ key (ipairs ["f" "F" "t" "T"])]
     (vim.keymap.del ["n" "x" "o"] key)))


{: enable
 : remove-keybinds
 :handle_keypress handle-keypress}
