function yes_or_no {
    while true; do
        read -p "$* [y/n]: " yn
        case $yn in
            [Yy]*) return 0  ;;
            [Nn]*) echo "Aborted" ; return  1 ;;
        esac
    done
}

#yes_or_no "Download Anaconda 5.3?" && \
#bash Anaconda3-5.3.0-Linux-x86_64.sh -b -p $HOME/anaconda && \
#export PATH="$HOME/miniconda/bin:$PATH" && \
#echo 'export PATH="$HOME/anaconda/bin:$PATH"' >> ~/.bashrc && \
#echo "Installed Anaconda and added to path"