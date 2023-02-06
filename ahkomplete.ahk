#NoEnv
#Warn
#SingleInstance Force
SetWorkingDir %A_ScriptDir%   
global originalClip
!/::
  ahkomplete(0)
return

^Rbutton::
  ahkomplete(1)
return

ahkomplete(clickBefore) {
    ;clickBefore - if 1 then it does a click where the mouse cursor is before doing its thing

    ;init variables
    groupNum := 0
    group := ""
    itemNum := 0

    ;save the last thing you had in clipboard
    global originalClip := clipboard
    clipwait, 1
    sleep, 100

    if (clickBefore = 1){
        click
    }

    ;read "rows"
    FileRead, data, data.txt
    Rows := StrSplit(data, "/`r`n")

    for index, element in Rows {
        ;split rows
        details:= StrSplit(element,"|")

        ;sets group and item numbers so they are usable as shortcuts to address them in menu by   
        if (group != details[1]) {
          groupNum := groupNum + 1
          itemNum:= 0
        }
        itemNum := itemNum + 1
        
        group := details[1]     ; Menu item
        item := details[2]      ; subMenu item
        value := details[3]     ; pasted value
        options := details[4]   ; parsing options
       
        if (group != "") {
            ;bind function with a value, this is so its calleable from menu
            print := Func("paste").Bind(value)
           
            ; Comments
            ; item is disabled in the context menu 
            if (options = "i") {
                if (item = "" and value = "") {
                    groupNum := groupNum - 1
                } else if (item != "" and value = "") {
                    itemNum := itemNum -1
                }
            } else if (options = "c") {
                ;at the Menu level
                if (item = "" and value = "") {
                    Menu ContextMenu, Add, %group%, % print
                    groupNum := groupNum - 1
                    Menu ContextMenu, disable, %group%
                } else if (item != "" and value = "") {  ;at subMenu level
                    Menu %groupNum%. %group% , Add, %item%, % print 
                    itemNum := itemNum -1         
                    Menu %groupNum%. %group% , Disable, %item%
                } 
            } else if (options = "") { 
                ; if there is no subMenu               
                if (item = "") {
                    Menu ContextMenu, Add, &%groupNum%. %group%, % print
                } else {      
                    Menu %groupNum%. %group% , Add, &%itemNum%. %item%, % print
                    Menu ContextMenu, Add, &%groupNum%. %group%, :%groupNum%. %group%    
                    
                }
            }                    
        }   
    }
    Menu ContextMenu, Show
    Menu ContextMenu, DeleteAll ;Throw away the menu and make a new one each time 
                                ;so you dont have to reload script when you edit the content 
}

paste(out) {
    clipboard = %out%    
    clipwait,1
    sleep, 100
    SendInput ^v
    ;return the thing you had in clipboard before
    sleep,100
    clipboard = %originalClip%
    clipwait,1
    sleep,100
}





