# /bin/bash
# (C) Sergio Zygmunt 2018


# function to handle the command line arguments
function processArguments() {
    re='^[0-9]+$' # set up var for regex if not a number

    case $interactiveMode in
    true|false)
    ;;
    "")
    interactiveMode="false"
    ;;
    *)
    echo "something bad happened during processing of interactive mode"
    exit 1
    ;;
    esac

    case $clipboardAction in
    savethenprompt|saveThanPrompt|1) # gotta think of people who forget than and then
    checkClipboardCompatibility
    clipboardAction="savethenprompt"
    ;;
    overwrite|2) #
    checkClipboardCompatibility
    ;;
    ""|false|0)
    clipboardAction="false"
    ;;
    *)
    echo "something bad happened during processing of interactive mode"
    exit 1
    ;;
    esac

    if [ -z $numberOfUUIDs ]; # the -z evaluates if the variable is empty
    then 
    numberOfUUIDs="1"
    elif ! [[ $numberOfUUIDs =~ $re ]] ; then # if the user did not use number
        echo "error: You did not pass a number for the number of UUIDs" >&2; exit 1
    fi

    case $diagnosticsFlag in
    true|false)
    ;;
    "")
    diagnosticsFlag="false"
    ;;
    *)
    echo "something bad happened during processing of diagnostics flag"
    exit 1
    ;;
    esac

    if [ -z $separator ]; # the -z evaluates if the variable is empty
    then 
    separator="-"
    fi
}

function checkClipboardCompatibility {
    unameOut="$(uname -s)"
    case "${unameOut}" in
    Linux*)     machine=Linux
    ;;
    Darwin*)    machine=Mac
    ;;
    CYGWIN*)    machine=Cygwin
    ;;
    MINGW*)     machine=MinGw
    ;;
    *)          machine="UNKNOWN:${unameOut}"
    #thanks Stackoverflow user paxdiablo for the uname info -Sergio
esac
    if [ "${machine}" != "Mac" ]; then
        echo "My script does not support non-Mac yet. Sorry."
        echo "<3 Sergio."
        clipboardCompatibility="false"
    elif [ "${machine}" == "Mac" ]; then
        clipboardCompatibility="true"
    fi
}

function storeClipboard {  
    if [ "$clipboardAction" == "savethenprompt" ]; then
            if [ "$clipboardCompatibility" == "true" ] && [ "${machine}" == "Mac" ]; then
            clipboardContents="$(pbpaste)"
        fi
    fi
}

function restoreClipboard { 
    if [ "$clipboardAction" == "savethenprompt" ]; then
            echo "Your clipboard should now have the UUID string on it"
            echo "Press enter to restore your original clipboard"
            read null
            if [ "$clipboardCompatibility" == "true" ] && [ "${machine}" == "Mac" ]; then
            echo $clipboardContents | pbcopy
        fi
    fi
}

function writeOutputToClipboard {
    if [ "$clipboardAction" != "false" ]; then
        if [ "$clipboardCompatibility" == "true" ] && [ "${machine}" == "Mac" ]; then
            echo "Writing output to clipboard"
            echo $formattedOutput | pbcopy
        fi

    fi
}

function diagnostics {
    if [ "$diagnosticsFlag" == "true" ]; then # remember kids there has to be spaces in the if
    echo diagnosticsFlag  = "$diagnosticsFlag"
    echo interactiveMode  = "$interactiveMode"
    echo numberOfUUIDs    = "$numberOfUUIDs"
    echo clipboardAction  = "$clipboardAction"
    echo clipboardCompatibility  = "$clipboardCompatibility"
    echo machine          = "${machine}"
    echo clipboardContents = "$clipboardContents"
    echo separator        = "$separator"
    
    fi
}

function apiDiagnostics {
    if [ "$diagnosticsFlag" == "true" ]; then # remember kids there has to be spaces in the if
    echo apiOutput  = "$apiOutput"
    fi
}

function getUUIDs {
    apiInterface="https://www.uuidgenerator.net/api/version4/" # define which API to use
    # apiInterface="https://amionvpn.com" # define which API to use -- dummy site that will always return null
    
    apiFullCall="$apiInterface$numberOfUUIDs" # define full calls
    apiOutput="$(curl -s $apiFullCall | tr '\r\n' '_')" # some outputs, including this one, use \r\n as the return instead of just \n
}

function checkUUIDs {
    if [ -z $apiOutput ]; # the -z evaluates if the variable is empty
    then 
    echo "The API output returned null. Run with --diagnostics or -d to test your internet connection"
        if [ "$diagnosticsFlag" == "true" ]; # remember kids there has to be spaces in the if
        then
            echo "Since you've enabled diagnostics, I will check your connection to the internet"
                if [[ $(curl -s captive.apple.com) == *Success* ]]; then
                    echo "Your connection is online or it could be a proxy server"
                else
                echo "Your internet is not working"
                fi 
        fi
    exit 1
    fi
}

function processUUIDs {
    apiDiagnostics
    trCommand="tr -s '_' $separator" # defines command for the replacement of our temp separator
    formattedOutput="$(echo $apiOutput | $trCommand | rev | cut -c 2- | rev)" # run the command 
}

function processOutput {
    echo $formattedOutput
    writeOutputToClipboard
}

function interactiveMode {
    if [ "$interactiveMode" == "true" ]; then
    echo "You've opted to use interactive mode"
    echo "------------------------------------"
    echo "How many UUIDs do you want?"
    read numberOfUUIDs
    echo "What seperator should I use?"
    read separator
    echo "Finally, what should I do with your clipboard?"
    echo "Enter 1 to save your clipboard then offer to return it"
    echo "Enter 2 to overwrite your clipboard without saving it first"
    echo "Enter 0 not affect your clipbaord at all"
    read clipboardAction
    if [ "$clipboardAction" == "1" ]; then
        clipboardAction="savethenprompt"
    elif [ "$clipboardAction" == "2" ]; then
        clipboardAction="overwrite"
    else
        clipboardAction="false"
    fi

    processArguments
    fi
}

# main
while [[ $# -gt 0 ]]
do
key="$1"
case $key in
    -i|--interactive)
    interactiveMode="true"
    shift # past argument
    ;;
    -n|--number)
    numberOfUUIDs="$2"
    shift # past argument
    shift # past value
    ;;
    -s|--separator)
    separator="$2"
    shift
    shift
    ;;
    -d|--diagnostics)
    diagnosticsFlag="true"
    shift # past argument
    shift # past value
    ;;
    -c|--clipboard)
    clipboardAction="$2"
    shift # past argument
    shift
    ;;
    -cs)
    clipboardAction="savethenprompt"
    shift # past argument
    ;;
    -co)
    clipboardAction="overwrite"
    shift # past argument
    ;;
    *)
    echo "Something bad happened during the switch evaluation. Check your input."
    exit 1
    ;;
esac
done
processArguments "$interactiveMode" "$numberOfUUIDs" "$clipboardAction" "$diagnosticsFlag" "$separator"
interactiveMode
storeClipboard
diagnostics
getUUIDs "$numberOfUUIDs"
checkUUIDs
processUUIDs
processOutput
restoreClipboard