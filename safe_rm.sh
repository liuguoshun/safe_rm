#!/bin/sh
sh_path=`pwd`

function check_args(){
    arr=($@)
    if [[ "${arr[0]}" == -* ]]
    then
        unset arr[0]
    fi

    if ((${#arr[@]} > 0))
    then
        lsof_text=`lsof -Fn`
        exit_code=0
        for fname in ${arr[@]}
        do
            current_path=`pwd`
            fname=`echo $fname|sed 's#\*#\\\*#g'`
            dir_path=$(cd "$(dirname $fname)";pwd)
            if [ $dir_path == '/' ]
            then
                abs_path=$dir_path$(basename $fname)
            else
                abs_path=$dir_path'/'$(basename $fname)
            fi
            
            cd $current_path
            
            if ((`echo $lsof_text | egrep -o " [n]{0,1}${abs_path}\S*"| wc -l` >0))
            then
                echo $fname" is opend by other process"
                exit_code=1
            fi
            
        done
        return $exit_code

    else
        echo "need files to delete"
        exit 1
    fi

}

check_args $@
if (($? == 1))
then
    echo "rm will not execute"
    exit 1
else
    echo "rm will execute"
    cd $sh_path
    #echo "command:rm $@"
    /bin/rm $@
fi
