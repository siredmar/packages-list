#!/bin/bash
set -e
helpFunction()
{
   echo ""
   echo "Usage: $0 <type>> "
   echo "Possible types are:"
   echo -e "\t-a |--all Package list for apt"
   echo -e "\t-s |--system Package list for native system repositories like apt or apk"
   echo -e "\t-p2|--python2 Package list for python2"
   echo -e "\t-p3|--python3 Package list for python3"
   echo -e "\t-n |--npm Package list for npm"
   echo -e "\t-r |--rust Package list for rust"
   echo -e "\t-g |--golang Package list for golang"
   echo -e "\t-o |--output Output file, default: ./packages"
   echo -e "\t-p |--product Product string to contain to the report, default: none"
   echo -e "\t-v |--version Version string to contain to the report, default: none"
   echo -e "If none is set, none will be used by default."
   exit 1 # Exit script after printing help
}

alpine=0
debian_based=0

CheckOs()
{
    if [ -x "$(command -v lsb_release)" ]; then
        debian_based=1
    fi
    if [ -f "/etc/alpine-release" ]; then
        alpine=1
    fi
}

CleanFile()
{
    if [ -f "$outputfile" ]; then
        rm $outputfile
    fi
}

Python2Packages()
{
    echo -e "\n###############################################" >> $1
    echo Python2 packages >> $1 
    pip freeze >> $1 | true
}

Python3Packages()
{
    echo -e "\n###############################################" >> $1
    echo Python3 packages >> $1
    pip3 freeze >> $1 | true
}

ApkPackages()
{
    if [ "$alpine" -eq 1 ]; then
        echo -e  "\n###############################################" >> $1
        echo Apk packages >> $1
        apk info -vv | sort >> $1 | true
    fi
}

AptPackages()
{
    if [ "$debian_based" -eq 1 ]; then
        echo -e  "\n###############################################" >> $1
        echo Apt packages >> $1
        dpkg-query --showformat='${Package}==${Version}\n' --show >> $1 | true
    fi
}

NpmPackages()
{
    echo -e "\n###############################################" >> $1
    echo NPM packages >> $1
    npm list -g >> $1 | true
}

RustPackages()
{
    echo -e "\n###############################################" >> $1
    echo Rust packages >> $1
    cargo install --list >> $1 | true
}

GolangPackages()
{
    echo -e "\n###############################################" >> $1
    echo Golang packages >> $1
    cd $GOPATH/src && go list ./... >> $1 | true
}

outputfile="./packages"
version="none"
product="none"
parameterPython2=0
parameterPython3=0
parameterApt=0
parameterApk=0
parameterNpm=0
parameterRust=0
parameterGolang=0

while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -p2|--python2)
    parameterPython2=1
    shift # past argument
    ;;
    -p3|--python3)
    parameterPython3=1
    shift # past argument
    ;;
    -a|--all)
    parameterPython2=1
    parameterPython3=1
    parameterApt=1
    parameterApk=1
    parameterNpm=1
    parameterRust=1
    parameterGolang=1
    shift # past argument
    ;;
    -s|--system)
    parameterApt=1
    parameterApk=1
    shift # past argument
    ;;
    -n|--npm)
    parameterNpm=1
    shift # past argument
    ;;
    -r |--rust)
    parameterRust=1
    shift # past argument
    ;;
    -g|--golang)
    parameterGolang=1
    shift # past argument
    ;;
    -o|--output)
    outputfile="$2"
    shift # past argument
    shift # past value
    ;;
    -v|--version)
    version="$2"
    shift # past argument
    shift # past value
    ;;
    -p|--product)
    product="$2"
    shift # past argument
    shift # past value
    ;;
    *)    # unknown option
    echo Unknown argument: $key
    helpFunction
    ;;
esac
done

CheckOs
CleanFile

echo "Packages list for '$product' version: $version" >> $outputfile

if [ "$parameterPython2" -eq 1 ]; then
   Python2Packages $outputfile
fi

if [ "$parameterPython3" -eq "1" ]; then
   Python3Packages $outputfile
fi

if [ "$parameterApt" -eq "1" ]; then
   AptPackages $outputfile
fi

if [ "$parameterApk" -eq "1" ]; then
   ApkPackages $outputfile
fi

if [ "$parameterNpm" -eq "1" ]; then
   NpmPackages $outputfile
fi

if [ "$parameterRust" -eq "1" ]; then
   RustPackages $outputfile
fi

if [ "$parameterGolang" -eq "1" ]; then
   GolangPackages $outputfile
fi
