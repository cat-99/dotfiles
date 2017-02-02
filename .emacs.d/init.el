
;;; パスの設定
;; ~/.emacs.d ディレクトリ配下をロードパスに追加する
;; load-path に追加する関数を定義
(defun add-to-load-path (&rest paths)
  (let (path)
	(dolist (path paths paths)
	  (let ((default-directory
			  (expand-file-name (concat user-emacs-directory path))))
		(add-to-list 'load-path default-directory)
		(if (fboundp 'normal-top-level-add-subdirs-to-load-path)
			(normal-top-level-add-subdirs-to-load-path))))))


;; 引数のディレクトリとそのサブディレクトリを load-path に追加
(add-to-load-path "elisp" "elpa" "undohist")


;; auto-install の設定
(when (require 'auto-install nil t)
  ;; インストールディレクトリを指定する 初期値は ~/.emacs.d/auto-install/
  (setq auto-install-directory "~/.emacs.d/elisp/")
  ;; Emacswiki に登録されている elisp の名前を取得する
  ;; 久しぶりに開いたらエラーのため暫定対処
  ;; error in process filter: Could not create connection to www.emacswiki.org:443
;;  (auto-install-update-emacswiki-package-name t)
  ;; install-elisp の関数を利用可能にする
  (auto-install-compatibility-setup))             ; 互換性確保


(add-to-list 'exec-path "/opt/local/bin")
(add-to-list 'exec-path "/usr/local/bin")

(require 'cl)

;;; ターミナルコマンドの実行パスを追加
;; exec-pathリストにパスを追加する
(cl-loop for x in (reverse
                (split-string (substring (shell-command-to-string "echo $PATH") 0 -1) ":"))
      do (add-to-list 'exec-path x))


;; package.elの設定
(require 'package)
(add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/") t)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/") t)
(package-initialize)

;; migemo の設定

;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

(require 'migemo)
(setq migemo-command "/usr/local/bin/cmigemo")
(setq migemo-options '("-q" "--emacs"))
(setq migemo-dictionary "/usr/local/share/migemo/utf-8/migemo-dict")
(setq migemo-user-dictionary nil)
(setq migemo-coding-system 'utf-8-unix)
(setq migemo-regex-dictionary nil)
(load-library "migemo")
(migemo-init)


(require 'auto-complete)
(global-auto-complete-mode t)

(require 'anything-startup)

;;; anything
(when (require 'anything nil t)
  (setq
   ;; 候補を表示するまでの時間。デフォルトは0.5
   anything-idle-delay 0.3
   ;; タイプして再描画するまでの時間。デフォルトは0.1
   anything-input-idle-delay 0.2
   ;; 候補の最大表示数。デフォルトは50
   anything-candidate-number-limit 100
   ;; 候補が多い時に体感速度を早くする
   anything-quick-update t
   ;; 候補選択ショートカットをアルファベットに
   anything-enable-shortcuts 'alphabet)

  (when (require 'anything-config nil t)
	;; root権限でアクションを実行するときのコマンド
	;; デフォルトは "su"
	(setq anything-su-or-sudo "sudo"))

  (require 'anything-match-plugin nil t)

  (when (and (executable-find "cmigemo")
			 (require 'migemo nil t))
	(require 'anything-migemo nil t))

  (when (require 'anything-complete nil t)
	;; lispシンボルの補完候補の再検索時間
	(anything-lisp-complete-symbol-set-timer 150))

  (require 'anything-show-completion nil t)

  (when (require 'auto-install nil t)
	(require 'anything-auto-install nil t))

  (when (require 'descbinds-anything nil t)
	;; descbinds-anything を anything に置き換える
	(descbinds-anything-install)))

;;
;; helm
;;
(require 'helm-config)
(helm-mode 1)
(helm-migemo-mode 1)

;; C-hで前の文字削除
(define-key helm-map (kbd "C-h") 'delete-backward-char)
(define-key helm-find-files-map (kbd "C-h") 'delete-backward-char)

;; キーバインド
(define-key global-map (kbd "C-x b") 'helm-for-files)
(define-key global-map (kbd "C-x C-f") 'helm-find-files)
(define-key global-map (kbd "M-x")     'helm-M-x)
(define-key global-map (kbd "M-y")     'helm-show-kill-ring)

;; For find-file etc.
(define-key helm-read-file-map (kbd "TAB") 'helm-execute-persistent-action)
;; For helm-find-files etc.
(define-key helm-find-files-map (kbd "TAB") 'helm-execute-persistent-action)


;; サーバ
(require 'server)
(unless (server-running-p)
  (server-start))

;; emacs24では要らなくなったので無効化
;; ------------------------------------------------------------------------
;; @  color-theme.el

;; Emacsのカラーテーマ
;; http://code.google.com/p/gnuemacscolorthemetest/
;;(when (and (require 'color-theme nil t) (window-system))
;;  (color-theme-initialize)
;;  (color-theme-clarity))

;;(require 'color-theme)
;;  (color-theme-initialize)
;;  (color-theme-clarity)

;; 日本語化
(setq locale-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-buffer-file-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-language-environment "Japanese")
;; 極力UTF-8とする
(prefer-coding-system 'utf-8)

;; Windowsで英数と日本語にMeiryoを指定
;; Macで英数と日本語にRictyを指定
(let ((ws window-system))
  (cond ((eq ws 'w32)
         (set-face-attribute 'default nil
                             :family "Meiryo"  ;; 英数
                             :height 100)
         (set-fontset-font nil 'japanese-jisx0208 (font-spec :family "Meiryo")))  ;; 日本語
        ((eq ws 'ns)
         (set-face-attribute 'default nil
                             :family "Ricty"  ;; 英数
                             :height 160)
         (set-fontset-font nil 'japanese-jisx0208 (font-spec :family "Ricty")))))  ;; 日本語



;; Macのキーバインドを使う。optionをメタキーにする。
;;(mac-key-mode 1)
;;(setq mac-option-modifier 'meta)

;; Macのキーバインドを使う。commandをメタキーにする。
;;(mac-key-mode 1)
(setq mac-command-modifier 'meta)


;;;;;;;;;;;;;;;;            ;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;; 文字列操作 ;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;            ;;;;;;;;;;;;;;;;

;; 矩形編集
;; cua-mode の設定
(cua-mode t) ; cua-mode をオン
(setq cua-enable-cua-keys nil) ; CUAキーバインドを無効にする


;; リスト9 範囲指定していないとき、C-wで前の単語を削除
;(defadvice kill-region (around kill-word-or-kill-region activate)
;  (if (and (interactive-p) transient-mark-mode (not mark-active))
;      (backward-kill-word 1)
;    ad-do-it))

;; -------------------------------------------------------------------------
;; @expand region
;;(require 'expand-region)
;;(global-set-key (kbd "C-@") 'er/expand-region)
;;(global-set-key (kbd "C-M-@") 'er/contract-region) ;; リージョンを狭める

;; transient-mark-modeが nilでは動作しませんので注意
;;(transient-mark-mode t)


;; カーソル位置の単語を削除
;; http://dev.ariel-networks.com/wp/documents/aritcles/emacs/part16
(defun kill-word-at-point ()
  (interactive)
  (let ((char (char-to-string (char-after (point)))))
    (cond
     ((string= " " char) (delete-horizontal-space))
     ((string-match "[\t\n -@\[-`{-~]" char) (kill-word 1))
     (t (forward-char) (backward-word) (kill-word 1)))))
(global-set-key "\M-d" 'kill-word-at-point)


;; 単語の途中でも「M-@」で単語が選択できるように
(defun mark-word-at-point ()
  (interactive)
  (let ((char (char-to-string (char-after (point)))))
    (cond
     ((string= " " char) (delete-horizontal-space))
     ((string-match "[\t\n -@\[-`{-~]" char) (mark-word ))
     (t (forward-char) (backward-word) (mark-word 1)))))
(global-set-key "\M-@" 'mark-word-at-point)


;; -------------------------------------------------------------------------
;;; 選択範囲をisearch
(defadvice isearch-mode (around isearch-mode-default-string (forward &optional regexp op-fun recursive-edit word-p) activate)
  (if (and transient-mark-mode mark-active (not (eq (mark) (point))))
      (progn
        (isearch-update-ring (buffer-substring-no-properties (mark) (point)))
        (deactivate-mark)
        ad-do-it
        (if (not forward)
            (isearch-repeat-backward)
          (goto-char (mark))
          (isearch-repeat-forward)))
    ad-do-it))


;; C-h を backspace として使う
(keyboard-translate ?\C-h ?\C-?)

;; 別のキーバインドにヘルプを割り当てる
(define-key global-map (kbd "C-x ?") 'help-command)

;; バックスラッシュ
(define-key global-map (kbd "M-|") "\\")

;; M-y に anything-show-kill-ring を割り当てる
;(define-key global-map (kbd "M-y") 'anything-show-kill-ring)


;; Undo 履歴
(when (require 'undohist nil t)
  (undohist-initialize))

;; Undo の分岐履歴(C-x u で樹形図を見ながらアンドゥできる)
(when (require 'undo-tree nil t)
  (global-undo-tree-mode))


;;; Emacs24 だとエラーになる
;; redo+ の設定
;;(when (require 'redo+ nil t)
  ;; C-' に redo を割り当て
  ;;(global-set-key (kbd "C-'") 'redo)
  ;; 日本語キーボードの場合、C-. がよいかも
;;  (global-set-key (kbd "C-.") 'redo)
;;  )

;; ------------------------------------------------------------------------
;; @ redo+.el

;; redoできるようにする
;; http://www.emacswiki.org/emacs/redo+.el
(when (require 'redo+ nil t)
  (define-key global-map (kbd "C-_") 'redo))


;;;;;;;;;;;;;;;;                  ;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;; 検索・grep・置換 ;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;                  ;;;;;;;;;;;;;;;;

;;; 検索結果のリストアップ
;; 要color-moccur.el
(when (require 'anything-c-moccur nil t)
  (setq
   ;; anything-c-moccur用 'anything-idle-delay'
   anything-c-moccur-anything-idle-delay 0.1
   ;; バッファの情報をハイライトする
   anything-c-moccur-higligt-info-line-flag t
   ;; 現在選択中の候補の位置を他の window に表示する
   anything-c-moccur-enable-auto-look-flag t
   ;; 起動時にポイントの位置の単語を初期パターンにする
   anything-c-moccur-enable-initial-pattern t)
   ;; C-M-o に anything-c-moccur-occur-by-moccur を割り当てる
   (global-set-key (kbd "C-M-o") 'anything-c-moccur-occur-by-moccur))


;; color-moccur の設定
(when (require 'color-moccur nil t)
  ;; M-o に occur-by-moccur を割り当て
  (define-key global-map (kbd "M-o") 'occur-by-moccur)
  ;; スペース区切りで AND 検索
  (setq moccur-split-word t)
  ;; ディレクトリ検索のとき除外するファイル
  (add-to-list 'dmoccur-exclusion-mask "\\.DS_Store")
  (add-to-list 'dmoccur-exclusion-mask "^#.+#$")
  ;; Migemo を利用できる環境であれば Migemo を使う
  (when (and (executable-find "cmigemo")
			 (require 'migemo nil t))
	(setq moccur-use-migemo t)))


;; 検索結果を直接編集
(require 'moccur-edit nil t)

;; grep
(define-key global-map (kbd "M-C-g") 'grep)

;; 再帰的にgrep
;; -rオプションを追加して常に再帰的にgrepするようにします。grep-findなどを使い分けなくてもすみます。
;; 2011-02-18
(require 'grep)
(setq grep-command-before-query "grep -nH -r -e ")
(defun grep-default-command ()
  (if current-prefix-arg
      (let ((grep-command-before-target
             (concat grep-command-before-query
                     (shell-quote-argument (grep-tag-default)))))
        (cons (if buffer-file-name
                  (concat grep-command-before-target
                          " *."
                          (file-name-extension buffer-file-name))
                (concat grep-command-before-target " ."))
              (+ (length grep-command-before-target) 1)))
    (car grep-command)))
(setq grep-command (cons (concat grep-command-before-query " .")
                         (+ (length grep-command-before-query) 1)))


;; grep の結果を直接編集
(require 'wgrep nil t)

; ag
(setq default-process-coding-system 'utf-8-unix)  ; ag 検索結果のエンコード指定
(require 'ag)
(setq ag-highlight-search t)  ; 検索キーワードをハイライト
(setq ag-reuse-buffers t)     ; 検索用バッファを使い回す (検索ごとに新バッファを作らない)

; wgrep
(add-hook 'ag-mode-hook '(lambda ()
                           (require 'wgrep-ag)
                           (setq wgrep-auto-save-buffer t)  ; 編集完了と同時に保存
                           (setq wgrep-enable-key "r")      ; "r" キーで編集モードに
                           (wgrep-ag-setup)))

;; ---------------------------------------------------------
;; helm-swoop
;;----------------------------------------------------------

(require 'helm-swoop)

;; キーバインドはお好みで
(global-set-key (kbd "M-i") 'helm-swoop)
(global-set-key (kbd "M-I") 'helm-swoop-back-to-last-point)
(global-set-key (kbd "C-c M-i") 'helm-multi-swoop)
(global-set-key (kbd "C-x M-i") 'helm-multi-swoop-all)

;; isearch実行中にhelm-swoopに移行
(define-key isearch-mode-map (kbd "M-i") 'helm-swoop-from-isearch)
;; helm-swoop実行中にhelm-multi-swoop-allに移行
(define-key helm-swoop-map (kbd "M-i") 'helm-multi-swoop-all-from-helm-swoop)

;; Save buffer when helm-multi-swoop-edit complete
(setq helm-multi-swoop-edit-save t)

;; 値がtの場合はウィンドウ内に分割、nilなら別のウィンドウを使用
(setq helm-swoop-split-with-multiple-windows nil)

;; ウィンドウ分割方向 'split-window-vertically or 'split-window-horizontally
(setq helm-swoop-split-direction 'split-window-vertically)

;; nilなら一覧のテキストカラーを失う代わりに、起動スピードをほんの少し上げる
(setq helm-swoop-speed-or-color t)



;;;;;;;;;;;;;;;;         ;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;; 移動系  ;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;         ;;;;;;;;;;;;;;;;

;; sequential-command.el
(require 'sequential-command-config)
(sequential-command-setup-keys)


;; point-undo.el
;; カーソル位置を戻す
(require 'point-undo)
(define-key global-map (kbd "<f7>") 'point-undo)
(define-key global-map (kbd "S-<f7>") 'point-redo)

;; 最後の編集箇所にジャンプする
(require 'goto-chg)
(define-key global-map (kbd "<f8>") 'goto-last-change)
(define-key global-map (kbd "S-<f8>") 'goto-last-change-reverse)

;; M-g で指定行へジャンプ
(global-set-key "\M-g" 'goto-line)

;; ファイルを開いた時、最後にカーソルのあった場所に移動
(load "saveplace")
(setq-default save-place t)

;; dired-mode で C-i で上位のディレクトリに移動
(define-key dired-mode-map (kbd "C-i") 'dired-up-directory)

;; マウスのホイールスクロールスピードを調節
;; (連続して回しているととんでもない早さになってしまう。特にLogicoolのマウス)
(global-set-key [wheel-up] '(lambda () "" (interactive) (scroll-down 1)))
(global-set-key [wheel-down] '(lambda () "" (interactive) (scroll-up 1)))
(global-set-key [double-wheel-up] '(lambda () "" (interactive) (scroll-down 2)))
(global-set-key [double-wheel-down] '(lambda () "" (interactive) (scroll-up 2)))
(global-set-key [triple-wheel-up] '(lambda () "" (interactive) (scroll-down 3)))
(global-set-key [triple-wheel-down] '(lambda () "" (interactive) (scroll-up 3)))


;; 1行ずつスムーズにスクロールする
;; (setq scroll-step 1)


;;;;;;;;;;;;;;;;      ;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;; diff ;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;      ;;;;;;;;;;;;;;;;

;;;
;;; diff を見易くする
;;; http://www.clear-code.com/blog/2012/4/3.html

;; diffの表示方法を変更
(defun diff-mode-setup-faces ()
  ;; 追加された行は緑で表示
  (set-face-attribute 'diff-added nil
                      :foreground "white" :background "dark green")
  ;; 削除された行は赤で表示
  (set-face-attribute 'diff-removed nil
                      :foreground "white" :background "dark red")
  ;; 文字単位での変更箇所は色を反転して強調
  (set-face-attribute 'diff-refine-change nil
                      :foreground nil :background nil
                      :weight 'bold :inverse-video t))
(add-hook 'diff-mode-hook 'diff-mode-setup-faces)

;; diffを表示したらすぐに文字単位での強調表示も行う
(defun diff-mode-refine-automatically ()
  (diff-auto-refine-mode t))
(add-hook 'diff-mode-hook 'diff-mode-refine-automatically)

;; diff関連の設定
(defun magit-setup-diff ()
  ;; diffを表示しているときに文字単位での変更箇所も強調表示する
  ;; 'allではなくtにすると現在選択中のhunkのみ強調表示する
  (setq magit-diff-refine-hunk 'all)
  ;; diff用のfaceを設定する
  (diff-mode-setup-faces)
  ;; diffの表示設定が上書きされてしまうのでハイライトを無効にする
  (set-face-attribute 'magit-item-highlight nil :inherit nil))
(add-hook 'magit-mode-hook 'magit-setup-diff)



;; 英語翻訳
;; http://blog.shibayu36.org/entry/2016/05/29/123342
(require 'google-translate)
(require 'google-translate-default-ui)

(defvar google-translate-english-chars "[:ascii:]"
  "これらの文字が含まれているときは英語とみなす")
(defun google-translate-enja-or-jaen (&optional string)
  "regionか現在位置の単語を翻訳する。C-u付きでquery指定も可能"
  (interactive)
  (setq string
        (cond ((stringp string) string)
              (current-prefix-arg
               (read-string "Google Translate: "))
              ((use-region-p)
               (buffer-substring (region-beginning) (region-end)))
              (t
               (thing-at-point 'word))))
  (let* ((asciip (string-match
                  (format "\\`[%s]+\\'" google-translate-english-chars)
                  string)))
    (run-at-time 0.1 nil 'deactivate-mark)
    (google-translate-translate
     (if asciip "en" "ja")
     (if asciip "ja" "en")
     string)))

;;(push '("\*Google Translate\*" :height 0.5 :stick t) popwin:special-display-config)

(global-set-key (kbd "C-M-t") 'google-translate-enja-or-jaen)



;;;;;;;;;;;;;;;;         ;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;; 表示系  ;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;         ;;;;;;;;;;;;;;;;

;; テーマの設定
;(load-theme 'desert t t)
;(enable-theme 'desert)


;; モードラインの背景色を設定します。
;;  (set-face-background 'mode-line "MediumPurple2")
  (set-face-background 'mode-line "gray")
;; モードラインの文字の色を設定します。
;;  (set-face-foreground 'mode-line "white")
  (set-face-foreground 'mode-line "black")


;; 行番号表示
(global-linum-mode t)
(setq linum-format "%4d ")

;; タイトルバーにファイルのフルパス表示
(setq frame-title-format
      (format "%%f - @Emacs"))

;; カーソルの点滅を止める
(blink-cursor-mode 0)

;; 改行後にインデント
(global-set-key "\C-m" 'newline-and-indent)

;;; ツールバーを非表示
;; M-x tool-bar-mode で表示非表示を切り替えられる
(tool-bar-mode -1)

;; 何文字目にいるか表示
(column-number-mode 1)

;; 括弧の範囲内を強調表示
;;(show-paren-mode t)
;;(setq show-paren-delay 0)
;;(setq show-paren-style 'expression)

;; 括弧の範囲色
;;(set-face-background 'show-paren-match-face "#500")

;; フレームの透明度
;;(set-frame-parameter (selected-frame) 'alpha '(0.85)) tmp

;; ---------------------------------------------------------
;; elscreen
;; C-t C-c 新しいelscreenを作る
;; C-t C-k 現在のelscreenを削除する
;; C-t M-k 現在のelscreenをバッファごと削除する
;; C-t K   ほかの全elscreenを削除する！
;; C-t C-n 次のelscreenを選択
;; C-t C-p 前のelscreenを選択
;; C-t C-a 直前に選択したelscreenを選択
;; C-t C-f 新しいelscreenでファイルを開く
;; C-t b   新しいelscreenでバッファを開く
;; C-t d   新しいelscreenでdiredを開く

;;; プレフィクスキーはC-t
(setq elscreen-prefix-key (kbd "C-t"))
(elscreen-start)
;;; タブの先頭に[X]を表示しない
(setq elscreen-tab-display-kill-screen nil)
;;; header-lineの先頭に[<->]を表示しない
(setq elscreen-tab-display-control nil)
;;; バッファ名・モード名からタブに表示させる内容を決定する(デフォルト設定)
(setq elscreen-buffer-to-nickname-alist
      '(("^dired-mode$" .
         (lambda ()
           (format "Dired(%s)" dired-directory)))
        ("^Info-mode$" .
         (lambda ()
           (format "Info(%s)" (file-name-nondirectory Info-current-file))))
        ("^mew-draft-mode$" .
         (lambda ()
           (format "Mew(%s)" (buffer-name (current-buffer)))))
        ("^mew-" . "Mew")
        ("^irchat-" . "IRChat")
        ("^liece-" . "Liece")
        ("^lookup-" . "Lookup")))
(setq elscreen-mode-to-nickname-alist
      '(("[Ss]hell" . "shell")
        ("compilation" . "compile")
        ("-telnet" . "telnet")
        ("dict" . "OnlineDict")
        ("*WL:Message*" . "Wanderlust")))


;; メモ書き・ToDo管理
;; howmメモ保存の場所
(setq howm-directory (concat user-emacs-directory "howm"))
;; howm-menuの言語を日本語に
(setq howm-menu-lang 'ja)
;; howmメモを1日1ファイルにする
(setq howm-file-name-format "%Y/%m/%Y-%m-%d.howm")
;; howm-mode を読み込む
(when (require 'howm-mode nil t)
  ;; C-c,,で howm-menu を起動
  (define-key global-map (kbd "C-c ,,") 'howm-menu))



;; minibuffer用
(define-key minibuffer-local-completion-map "\C-w" 'backward-kill-word)

;; -------------------------------------------------------------------------
;; @ minimap
;; デフォルトは無効。M-x minimap-mode で有効になる。
(require 'minimap)


;; CSS設定
;; インデント幅4
(setq cssm-indent-level 4)
;; インデントをCスタイルにする
(setq cssm-indent-function #'cssm-c-style-indenter)

;; タブキー
(setq default-tab-width 4)
(setq indent-line-function 'indent-relative-maybe)

;; 行末の空白を強調表示
(setq-default show-trailing-whitespace t)
(set-face-background 'trailing-whitespace "#b14770")

;; yes or no を y or n
(fset 'yes-or-no-p 'y-or-n-p)

;; バックアップとオートセーブファイルを ~/.emacs.d/backups/ へ集める
;;(add-to-list 'backup-directory-alist
;;			 (cons "." "~/.emacs.d/backups/"))
;;(setq auto-save-file-name-transforms
;;	  `((".*" ,(expand-file-name "~/emacs.d/backups/") t)))

;; バックアップを残さない
(setq make-backup-files nil)

;; コメント挿入を multi-line にする。(デフォルトは indent ちな M-; でコメント挿入)
(setq comment-style 'multi-line)

;; 表示サイズ、位置
(setq default-frame-alist
      (append
       '((width            . 170)     ; フレームの幅(文字数)
         (height           . 51)      ; フレームの高さ(文字数)
         (top              . 70)      ; フレームのY位置(ピクセル)
         (left             . 413)     ; フレームのX位置(ピクセル)
        )
 default-frame-alist))

;; C-x C-f のファイル指定で候補が表示されないので一時的にコメントアウト
;; popwin
;;(require 'popwin)
;;(setq display-buffer-function 'popwin:display-buffer)


;(define-key global-map (kbd "\C-x b") 'anything)


;; js-mode の基本設定
(defun js-indent-hook ()
  ;; インデント幅を4にする
  (setq js-indent-level 2
		js-expr-indent-offset 2
		indent-tabs-mode nil t)
  ;; switch文のcaseラベルをインデントする関数を定義する
  (defun my-js-indent-line ()
	(interactive)
	(let* ((parse-status (save-excursion (syntax-ppss (point-at-bol))))
		   (offset (- (current-column) (current-indentation)))
		   (indentation (js--proper-indentation parse-status)))
	  (back-to-indentation)
	  (if (looking-at "case\\s-")
		  (indent-line-to (+ indentation 2))
		(js-indent-line))
	  (when (> offset 0) (forward-char offset))))
  ;; caseラベルのインデント処理をセットする
  (set (make-local-variable 'indent-line-function) 'my-js-indent-line)
  ;; ここまでcaseラベルを調整する設定
  )

;; js-mode の起動時に hook を追加
(add-hook 'js-mode-hook 'js-indent-hook)

;; js2-mode のインデントの修正
(add-hook 'js2-mode-hook 'js-indent-hook)


;; php-mode の設定
(when (require 'php-mode nil t)
  (add-to-list 'auto-mode-alist '("\\.ctp\\'" . php-mode))
  (setq php-search-url "http://jp.php.net/ja/")
  (setq php-manual-url "http://jp.php.net/manual/ja/"))

;; php-mode のインデント設定
(defun php-indent-hook ()
  (setq indent-tabs-mode nil)
  (setq c-basic-offset 4)
  ;;(c-set-offset 'case-lable '+)  ;switch文のcaseラベル
  (c-set-offset 'arglist-intro '+) ;配列の最初の要素が改行した場所
  (c-set-offset 'arglist-close 0)) ;配列の閉じ括弧

(add-hook 'php-mode-hook 'php-indent-hook)

;; php-mode の補完を強化する
(defun php-completion-hook ()
  (when (require 'php-completion nil t)
	(php-completion-mode t)
	(define-key php-mode-map (kbd "C-o") 'phpcmp-complete)

	(when (require 'auto-complete nil t)
	  (make-variable-buffer-local 'ac-sources)
	  (add-to-list 'ac-sources 'ac-source-php-completion)
	  (auto-complete-mode t))))

(add-hook 'php-mode-hook 'php-completion-hook)


;; Ruby
;; 括弧の自動挿入
(require 'ruby-electric nil t)
;; end に対応する行のハイライト
(when (require 'ruby-block nil t)
  (setq ruby-block-hilight-toggle t))
;; インタラクティブRubyを利用する
(autoload 'run-ruby "inf-ruby"
  "Run an inferior Ruby process")
(autoload 'inf-ruby-keys "inf-ruby"
  "Set local key defs for inf-ruby in ruby-mode")

;; ruby-mode-hook 用の関数を定義
(defun ruby-mode-hooks ()
  (inf-ruby-keys)
  (ruby-electric-mode t)
  (ruby-block-mode t))
;; ruby-mode-hook に追加
(add-hook 'ruby-mode-hook 'ruby-mode-hooks)


;;; Flymake の設定
(require 'flymake)
;; Ruby
(defun flymake-ruby-init ()
  (list "ruby" (list "-c" (flymake-init-create-temp-buffer-copy
						   'flymake-create-temp-inplace))))

(add-to-list 'flymake-allowed-file-name-masks
			 '("\\.rb\\'" flymake-ruby-init))

(add-to-list 'flymake-err-line-patterns
			 '("\\(.*\\):(\\([0-9]+\\)): \\(.*\\)" 1 2 nil 3))


;; Python
(when (require 'flymake-python nil t)
  ;; flake8 を利用する
  (setq flymake-python-syntax-checker "flake8")
  ;; pep8 を利用する
  ;;(setq flymake-python-syntax-checker "pep8")
  )


;; gtags-mode のキーバインドを有効化する
(setq gtags-suggested-key-mapping t)  ;無効化する場合はコメントアウト
(require 'gtags nil t)
(setq gtags-mode t)


;; GNU global(gtags)の設定
;;(when (locate-library "gtags") (require 'gtags))
;;(global-set-key "\M-t" 'gtags-find-tag)     ;関数の定義元へ
;;(global-set-key "\M-r" 'gtags-find-rtag)    ;関数の参照先へ
;;(global-set-key "\M-s" 'gtags-find-symbol)  ;変数の定義元/参照先へ
;;(global-set-key "\M-p" 'gtags-find-pattern)
;;(global-set-key "\M-f" 'gtags-find-file)    ;ファイルにジャンプ
;;(global-set-key [?\C-,] 'gtags-pop-stack)   ;前のバッファに戻る
;;(add-hook 'c-mode-common-hook
;;          '(lambda ()
;;             (gtags-mode 1)
;;             (gtags-make-complete-list)))



;; ctags.el の設定
(require 'ctags nil t)
(setq tags-revert-without-query t)
;; ctags を呼び出すコマンドライン。パスが通っていればフルパスでなくてもよい
;; etags互換タグを利用する場合はコメントを外す
;;(setq ctags-command "ctags -e -R ")
;; anything-exuberant-ctags.el を利用しない場合はコメントアウトする
(setq ctags-command "ctags -R --fields=\"+afikKlmnsSzt\" ")
(global-set-key (kbd "<F5>") 'ctags-create-or-update-tags-table)


;; Anything から TAGS を利用しやすくするコマンド作成
(when (and (require 'anything-exuberant-ctags nil t)
		   (require 'anything-gtags nil t))
  ;; anything-for-tags 用のソースを定義
  (setq anything-for-tags
		(list anything-c-source-imenu
			  anything-c-source-gtags-select
			  ;; etags を利用しない場合はコメントを外す
			  ;;anything-c-source-etags-select
			  anything-c-source-exuberant-ctags-select
			  ))

  ;; anything-for-tags コマンドを作成
  (defun anything-for-tags ()
	"preconfigured `anything' for anything-for-tags."
	(interactive)
	(anything anything-for-tags
			  (thing-at-point 'symbol)
			  nil nil nil "*anything for tags*"))

  ;; M-t に anything-for-tags を割り当て
  (define-key global-map (kbd "M-t") 'anything-for-tags))



;; 現在の関数名を常に表示する
(which-function-mode 1)
;; すべてのメジャーモードにたいしてwhich-func-mode を適用する
;(setq which-func-modes t)
;; 画面上部に表示する場合は下の2行が必要
;(delete (assoc 'which-func-mode mode-line-format) mode-line-format)
;(setq-default header-line-format '(which-func-mode ("" which-func-format)))



;; 背景色の変更
;;(custom-set-faces
 ;; custom-set-faces was added by Custom. tmp
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
;; '(default ((t (:background "#2F322F")))))  Tmp



;;
;; highlight
;;______________________________________________________________________

;; highlight current line
;;(require 'highlight-current-line)
;;(highlight-current-line-on t)
;;(set-face-background 'highlight-current-line-face "#000000")

;; 現在行のハイライト
(defface my-hl-line-face
  ;; 背景が dark ならば背景色を紺に
  '((((class color) (background dark))
	 (:background "dark slate gray" t))
	 ;;(:background "NavyBlue" t))
	;; 背景が light ならば背景色を緑に
	(((class color) (background light))
	 (:background "ForestGreen" t))
	 ;;(:background "LigthGoldenrodYellow" t))
	(t (:bold t)))
  "hl-line's my face")
(setq hl-line-face 'my-hl-line-face)
(global-hl-line-mode t)


;; paren-mode: 対応する括弧を強調して表示する
(setq show-paren-delay 0.125) ; 表示までの秒数。初期値は0.125
(show-paren-mode t) ; 有効化
;; parenのスタイル: expression は括弧内も強調表示
;;(setq show-paren-style 'expression)
;; フェイスを変更する
;;(set-face-background 'show-paren-match-face nil)
;;(set-face-underline-p	 'show-paren-match-face "yellow")

;; test
;(set-face-attribute 'show-paren-match-face nil
; 					:background nil :foreground nil
; 					:underline "#fff00" :weight 'extra-bold)

;; highlight reagion
;; マークセットするときに選択部分に色が付くようになる
;;(setq transient-mark-mode t)

;; highlight edit characters
;;(require 'jaspace)
;;(setq jaspace-highlight-tabs t)
;;(add-hook 'mmm-mode-hook 'jaspace-mmm-mode-hook)

;;(setq whitespace-style
;;      '(tabs spaces space-mark))
;;(setq whitespace-space-regexp "\\( +\\|\u3000+\\)")
;;(setq whitespace-display-mappings
;;      '((space-mark ?\u3000 [?\u25a1])))
;;(require 'whitespace)
;;(global-whitespace-mode 1)

;; 改行、タブ、スペースを色付けする
;;(global-whitespace-mode 1)

;; 改行コードを表示
(setq eol-mnemonic-dos "(CRLF)")
(setq eol-mnemonic-mac "(CR)")
(setq eol-mnemonic-unix "(LF)")

;;====================================
;; 全角スペースとかに色を付ける
;;====================================
(defface my-face-b-1 '((t (:background "medium aquamarine"))) nil)
(defface my-face-b-1 '((t (:background "dark turquoise"))) nil)
(defface my-face-b-2 '((t (:background "gray26"))) nil)
(defface my-face-b-2 '((t (:background "SeaGreen"))) nil)
(defface my-face-u-1 '((t (:foreground "SteelBlue" :underline t))) nil)
(defvar my-face-b-1 'my-face-b-1)
(defvar my-face-b-2 'my-face-b-2)
(defvar my-face-u-1 'my-face-u-1)
(defadvice font-lock-mode (before my-font-lock-mode ())
			(font-lock-add-keywords
				 major-mode
					'(
						   ("　" 0 my-face-b-1 append)
						   ("\t" 0 my-face-b-2 append)
						   ("[ ]+$" 0 my-face-u-1 append)
		  )))
(ad-enable-advice 'font-lock-mode 'before 'my-font-lock-mode)
(ad-activate 'font-lock-mode)
(add-hook 'find-file-hooks '(lambda ()
							 (if font-lock-mode
							   nil
							   (font-lock-mode t))))



(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   (quote
	("ef36e983fa01515298c017d0902524862ec7d9b00c28922d6da093485821e1ba" "57d7e8b7b7e0a22dc07357f0c30d18b33ffcbb7bcd9013ab2c9f70748cfa4838" "52706f54fd3e769a0895d1786796450081b994378901d9c3fb032d3094788337" default)))
 '(package-selected-packages
   (quote
	(ace-isearch helm-swoop helm wgrep-ag wgrep-ack undo-tree redo+ minimap migemo js2-mode gruvbox-theme google-translate expand-region elscreen ag))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
