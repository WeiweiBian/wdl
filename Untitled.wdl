#工作流：先创建新目录，再创建一个空文件，最后在空文件中写入内容。
#声明task create_workdir所需的参数workdir_path
#call task create_workdir:传入task create_workdir所需参数workdir
#call task create_file:传入task create_file所需参数filedir，内容为task create_workdir的输出work_path
#call task write_file：传入task write_file所需参数workdir和filepath，其中filepath内容为task create_file的输出file_path

workflow myWorkflow {
    String workdir_path

    call create_workdir {
        input:
            workdir = workdir_path
    }

    call create_file {
        input:
            filedir = create_workdir.work_path
    }

    call write_file {
        input:
            workdir = workdir_path,
            filepath = create_file.file_path
    }
}

#创建目录，并在目录创建代表操作完成的workdir.SUCCESS文件，若目录已存在，只创建workdir.EXIST文件。
#输入：待创建目录路径
#输出：创建的目录路径（输入、输出内容其实完全相同）

#声明：变量workdir类型为字符串
#command：可执行的shell代码，可用{}或<<<>>>括起，建议用<<<>>>，区分于代码其他部分，提高可读性
#output：声明并赋值后，可作为其他task的输入
task create_workdir {
    String workdir
    command <<<
        if [ ! -d ${workdir} ]; then
            mkdir ${workdir}
            touch ${workdir}/workdir.SUCCESS
        else
            touch ${workdir}/workdir.EXIST
        fi
    >>>
    output {
        String work_path = "${workdir}"
    }
}

#创建空文件，并在文件所在目录创建代表操作完成的file.SUCCESS文件，若文件已存在，输出语句“File exist!”，并创建file.EXIST文件
#输入：文件所在目录（即task create_workdir的输出目录），文件路径（文件所在目录+文件名)
#输出：文件路径
task create_file {
    String filedir
    String filename = filedir + "/test1.txt"
    command <<<
        if [ ! -f ${filename} ]; then
            touch ${filename}
            touch ${filedir}/file.SUCCESS
        else
            echo "File exist!"
            touch ${filedir}/file.EXIST
        fi
    >>>
    output {
        String file_path = "${filename}"
    }
}

#向文件中写入内容，并在文件所在目录创建代表操作完成的write.SUCCESS文件，若文件不存在，输出语句“File not exist!”，并创建write.FAIL文件
#输入：文件路径
#输出：文件内容
task write_file {
    String workdir
    String filepath
    String file_content = "Tomorrow is another day."
    command <<<
        if [ -f ${filepath} ]; then
            echo "${file_content}" >${filepath}
            touch ${workdir}/write.SUCCESS
        else
            echo "File not exist!"
            touch ${workdir}/write.FAIL
        fi  
    >>>
    output {
        String file_txt = "${file_content}"
    }
}

