#Requires AutoHotkey v2.0
#SingleInstance Force
#Warn

; 日本語配列に設定されたマシンで実行する。
; リモートデスクトップ接続の場合は接続先で実行する。
; 右Altの単独離し: 変換 / 左Altの単独離し: 無変換
; 右Shift: \ / 左Shiftを押しながら右Shift: _ / Ctrl+^: |

A_MenuMaskKey := "vkE8"
InstallKeybdHook()
InstallMouseHook()

altPressed := Map(0xA4, false, 0xA5, false)
altSolo := Map(0xA4, false, 0xA5, false)

; 入力は通過させ、文字列は収集しない。自分が送るキーも判定から除外する。
keyWatch := InputHook("V L0 I2")
keyWatch.KeyOpt("{All}", "N")
keyWatch.OnKeyDown := WatchKeyDown
keyWatch.OnKeyUp := WatchKeyUp
keyWatch.Start()

; Altなどとの組み合わせでは右Shiftの本来の機能を維持する。
#HotIf !GetKeyState("Ctrl", "P") && !GetKeyState("Alt", "P") && !GetKeyState("LWin", "P") && !GetKeyState("RWin", "P")
*RShift::SendText GetKeyState("LShift", "P") ? "_" : "\"
*RShift up::Return
#HotIf

; sc00Dは日本語配列の「^」位置。英語配列のキートップは「=」。
$^sc00D::SendText "|"

; Alt+クリック／ホイールも単独押しには数えず、そのまま通す。
; 単独押しの候補がある間だけ監視し、最初の操作で候補を取り消す。
; 通常のスクロールや取り消し後の連続入力ではホットキーを発火させない。
#HotIf GetKeyState("Alt", "P") && (altSolo[0xA4] || altSolo[0xA5])
~*LButton::CancelAltTaps()
~*RButton::CancelAltTaps()
~*MButton::CancelAltTaps()
~*XButton1::CancelAltTaps()
~*XButton2::CancelAltTaps()
~*WheelUp::CancelAltTaps()
~*WheelDown::CancelAltTaps()
~*WheelLeft::CancelAltTaps()
~*WheelRight::CancelAltTaps()
#HotIf

WatchKeyDown(input, vk, sc) {
    global altPressed, altSolo

    ; 別のキーを一度でも押したら、Altを離すまで単独押しの資格を失う。
    for altVk in altSolo {
        if vk != altVk
            altSolo[altVk] := false
    }

    ; 長押しの自動リピートでは単独押しの判定をやり直さない。
    if !altPressed.Has(vk) || altPressed[vk]
        return

    altPressed[vk] := true
    altSolo[vk] := !OtherKeyDown(vk)

    ; Alt単独でメニューへフォーカスが移るのを防ぐ。
    ; Blindで現在の修飾キーを維持するため、Alt+Tabなどはそのまま使える。
    SendInput "{Blind}{vkE8}"
}

WatchKeyUp(input, vk, sc) {
    global altPressed, altSolo

    if !altPressed.Has(vk)
        return

    sendConversion := altPressed[vk] && altSolo[vk] && !OtherKeyDown(vk)
    altPressed[vk] := false
    altSolo[vk] := false

    if sendConversion {
        ; 既存のremap_ime_for_vim.ahkのスキャンコード割り当ても有効にする。
        SendLevel 1
        SendEvent (vk = 0xA5 ? "{vk1Csc079}" : "{vk1Dsc07B}")
    }
}

OtherKeyDown(ownVk) {
    ; 先に押されていたCtrlなども検出し、離す順序による誤発火を防ぐ。
    ; 0x12は左右共通のAltなので、左右別の0xA4/0xA5で判定する。
    Loop 254 {
        if A_Index = ownVk || A_Index = 0x12
            continue

        keyName := Format("vk{:02X}", A_Index)
        ; リモート接続では未割り当てのvk9Eなどに押下状態が残ることがある。
        ; マウスボタン以外は、スキャンコードを持つキーだけを判定する。
        if A_Index > 6 && !GetKeySC(keyName)
            continue

        if GetKeyState(keyName, "P")
            return true
    }
    return false
}

CancelAltTaps() {
    global altSolo
    for vk in altSolo
        altSolo[vk] := false
}
